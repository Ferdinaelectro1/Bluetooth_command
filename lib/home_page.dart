import 'package:bt_command/bluetooth_manager.dart';
import 'package:provider/provider.dart';
import 'package:bt_command/provider_manage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> 
{
  bool _awaiting = false;
  static const Widget spaceBetweenButton = SizedBox(height: 10,);

/*   void scanneDevice()
  {
    //Débute du scannage
    FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
  
    //Ecoute de résultat
    StreamSubscription<List<ScanResult>> subscription = FlutterBluePlus.scanResults.listen((results)
    {
      for(ScanResult result in results)
      {
        setState(() {
          resultats.add("Device : ${result.device.remoteId}");
        });
      }
    });

    //Arrèter le scannage
    Future.delayed(Duration(seconds: 10),(){
      FlutterBluePlus.stopScan();
      subscription.cancel();
    });
  } */

  void errorCallback(String error) {
    setState(() {
      _awaiting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text("Erreur : $error"),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void sendCommande(String commande) async
  {
    setState(() {
      _awaiting = true;
    });
    await BluetoothManager.sendToDevice(deviceName: Provider.of<ProviderManage>(context,listen: false).deviceName,message: commande,onError: (error) => {
      errorCallback("Une erreur est survenue lors de l'envoi de la commande ")
    }
    ,);
    setState(() {
      _awaiting = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      elevation: 12,
      title: const Text("BLUETOOTH ROBOTIQUE",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,),),
    ),
    drawer: Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: const Text("Menu",style: TextStyle(fontSize: 30),)
          ),
          ListTile(
            onTap: (){
              Navigator.pushNamed(context,
               '/settingsPage'
              );
            },
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            subtitle: const Text("Configure settings"),
          )
        ],
      ),
    ),
    body: Column(
      children: [
        Text("Device Name : ${Provider.of<ProviderManage>(context,listen: false).deviceName}",style: const TextStyle(fontSize: 20),),
        spaceBetweenButton,
        CustomSendBox(buttonName: "Module 1",onPressedThis: (){
          sendCommande("module1\n");
        },),
        spaceBetweenButton,
        CustomSendBox(buttonName: "Module 2",onPressedThis: (){
          sendCommande("module2\n");
        },),
        spaceBetweenButton,
        CustomSendBox(buttonName: "Module 3",onPressedThis: (){
          sendCommande("module3\n");
        },),
        spaceBetweenButton,
        _awaiting ? CircularProgressIndicator() : const SizedBox.shrink(),
      ],
    )
  );
}

class CustomSendBox extends StatelessWidget
{
  final String buttonName;
  final void Function()? onPressedThis;

  const CustomSendBox({super.key,required this.buttonName,required this.onPressedThis});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: (){
            onPressedThis!();
          }, 
          child: Text(buttonName,style: TextStyle(fontSize: 25),)
        ),
      ],
    );
  }
}