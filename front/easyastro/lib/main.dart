import 'package:flutter/material.dart';
import 'package:easyastro/routes.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/theme/theme.dart' as my_theme;
import 'package:easyastro/services/database/configmanager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easyastro/screens/screencheck.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  ServerInfo();
  ObjectSelection();
  ConfigManager();

  runApp(EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
      path:
          'assets/translations', // <-- change the path of the translation files
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: my_theme.Theme.dark(),
      routes: routes,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const CheckScreen());
      },
    );
  }
}
