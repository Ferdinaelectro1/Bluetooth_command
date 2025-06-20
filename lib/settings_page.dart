import 'package:bt_command/provider_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  final _formController = TextEditingController();
  SettingsPage({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text("Bluetooth Name"),
            subtitle: const Text("Nom du device Bluetooth"),
            leading: const Icon(Icons.bluetooth),
            trailing: const Icon(Icons.chevron_right),
            onTap: (){
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Change Bluetooth Name"),
                    content: TextField(
                      decoration: const InputDecoration(hintText: "Enter new name"),
                      onSubmitted: (newName) {
                        Provider.of<ProviderManage>(context, listen: false).setDeviceName(newName);
                        Navigator.of(context).pop();
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          final newName = _formController.text;
                          Provider.of<ProviderManage>(context, listen: false).setDeviceName(newName);
                          Navigator.of(context).pop();
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}