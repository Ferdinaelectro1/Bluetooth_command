import 'package:bt_command/home_page.dart';
import 'package:bt_command/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:bt_command/provider_manage.dart';
import 'package:provider/provider.dart';

void main()
{
  return runApp(
    ChangeNotifierProvider(
      create: (context) => ProviderManage(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/' : (context) => const HomePage(),
        '/settingsPage' : (context) => SettingsPage()
      } 
    );
  }
}
