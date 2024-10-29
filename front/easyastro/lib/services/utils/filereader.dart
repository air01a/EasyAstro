import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:easyastro/services/database/configmanager.dart';
import 'package:http/http.dart' as http;

Future<String> readFile(String filename) async {


    if (!kIsWeb) {
        String directory = (await getApplicationCacheDirectory()).path;
        final file = File("$directory/$filename");
        return  await file.readAsString();
    }

    final url = "${ConfigManager().configuration!['remoteCatalog']!.value}/$filename";
    final response = await http.get(Uri.parse(url));

    return response.body;
 
}

Future<String> readFileSource() async {
  if (!kIsWeb) {
    return (await getApplicationCacheDirectory()).path ;
  }
  return ConfigManager().configuration!['remoteCatalog']!.value;
}
