import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:convert';

class BluetoothManager {
  static final Map<String, BluetoothCharacteristic> _characteristicsCache = {};

  /// Envoie un message à un appareil Bluetooth par son nom
  static Future<void> sendToDevice({
    required String deviceName,
    required String message,
    Duration timeout = const Duration(seconds: 15),
    void Function(Exception error)? onError,
  }) async {
    try {
      // Vérifier l'état Bluetooth
      final currentState = await FlutterBluePlus.adapterState.first;
      if (currentState != BluetoothAdapterState.on) {
        await FlutterBluePlus.turnOn();
        await FlutterBluePlus.adapterState
            .firstWhere((state) => state == BluetoothAdapterState.on)
            .timeout(const Duration(seconds: 5));
      }

      final sppServiceUuid = Guid("00001101-0000-1000-8000-00805F9B34FB");
      final sppCharacteristicUuid = Guid("0000ffe1-0000-1000-8000-00805f9b34fb");

      BluetoothCharacteristic? writeCharacteristic;

      if (_characteristicsCache.containsKey(deviceName)) {
        writeCharacteristic = _characteristicsCache[deviceName];
        if (!writeCharacteristic!.device.isConnected) {
          await writeCharacteristic.device.connect();
        }
      } else {
        final device = await _findDeviceByName(deviceName, timeout: timeout);
        await device.connect(timeout: timeout);

        final services = await device.discoverServices();

        for (final service in services) {
          if (service.serviceUuid == sppServiceUuid) {
            for (final characteristic in service.characteristics) {
              if (characteristic.characteristicUuid == sppCharacteristicUuid) {
                writeCharacteristic = characteristic;
                _characteristicsCache[deviceName] = characteristic;
                break;
              }
            }
          }
        }

        if (writeCharacteristic == null) {
          await device.disconnect();
          throw Exception(
              "Caractéristique d'écriture introuvable pour $deviceName");
        }
      }

      await writeCharacteristic.write(utf8.encode(message));
    } catch (e) {
      // Nettoyer
      _characteristicsCache.remove(deviceName);
      await FlutterBluePlus.stopScan();

      // Appeler la fonction de gestion d'erreur si elle est fournie
      if (onError != null && e is Exception) {
        onError(e);
      } else {
        throw Exception("Erreur lors de l'envoi au périphérique $deviceName : $e");
      }
    }
  }

  /// Trouve un appareil Bluetooth par son nom
  static Future<BluetoothDevice> _findDeviceByName(
    String deviceName, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final completer = Completer<BluetoothDevice>();
    Timer? timeoutTimer;

    try {
      await FlutterBluePlus.startScan(timeout: timeout);

      StreamSubscription<List<ScanResult>>? subscription;
      subscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          final name = result.device.platformName;
          if (name == deviceName) {
            timeoutTimer?.cancel();
            FlutterBluePlus.stopScan();
            subscription?.cancel();
            completer.complete(result.device);
            return;
          }
        }
      });

      timeoutTimer = Timer(timeout, () {
        if (!completer.isCompleted) {
          FlutterBluePlus.stopScan();
          subscription?.cancel();
          completer.completeError(
              TimeoutException("Appareil '$deviceName' introuvable"));
        }
      });
    } catch (e) {
      FlutterBluePlus.stopScan();
      if (!completer.isCompleted) {
        completer.completeError(
            Exception("Erreur lors de la recherche de l'appareil : $e"));
      }
    }

    return completer.future;
  }

  /// Déconnecte un appareil et nettoie le cache
  static Future<void> disconnectDevice(String deviceName) async {
    if (_characteristicsCache.containsKey(deviceName)) {
      final characteristic = _characteristicsCache[deviceName]!;
      if (characteristic.device.isConnected) {
        await characteristic.device.disconnect();
      }
      _characteristicsCache.remove(deviceName);
    }
  }
}
