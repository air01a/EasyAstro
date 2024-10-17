import 'package:flutter/material.dart';
import 'package:easyastro/routes.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/theme/theme.dart' as my_theme;
import 'package:easyastro/services/database/configmanager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easyastro/screens/screencheck.dart';
import 'package:easyastro/services/localization/customloader.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  ServerInfo();
  ObjectSelection();
  ConfigManager();

  runApp(EasyLocalization(
      path:'assets/translations',
      supportedLocales: const [Locale('en', ''), Locale('fr', '')],
      assetLoader:CustomAssetLoader(),
      fallbackLocale: const Locale('en', ''),
      useOnlyLangCode: true,
      useFallbackTranslations: true,
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
