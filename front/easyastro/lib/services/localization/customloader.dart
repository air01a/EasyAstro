import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class CustomAssetLoader extends AssetLoader {
  @override
  Future<Map<String,dynamic>?> load(String path, Locale locale) async{
      
      if (kIsWeb) {
        return jsonDecode(await rootBundle.loadString('assets/translations/${locale.languageCode}.json'));
      }

      var directory = await getApplicationCacheDirectory();
      final file = File('${directory.path}/${locale.languageCode}.json');
      if (await file.exists()) {
        return jsonDecode(await file.readAsString());
      } else {
          return jsonDecode(await rootBundle.loadString('assets/translations/${locale.languageCode}.json'));
      }
  }
}