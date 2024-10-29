import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter/foundation.dart' show kIsWeb;



class CatalogUpdater  {
  String localVersion = '0';
  String remoteVersion = '0';
  String remoteUrl;
  final Function(double) onValueChanged;
  late Directory directory;
 

  CatalogUpdater(this.remoteUrl, this.onValueChanged);

  Future<List<List<dynamic>>> readCsvFile(input) async {
      List<List<dynamic>> csvData = const CsvToListConverter(fieldDelimiter: ";", eol: "\n", textDelimiter: '"').convert(input);
      
      if (csvData.isNotEmpty) {
        csvData.removeAt(0); // Remove header
      }

      return csvData;
  }

  // Download remote version
  Future<String> fetchRemoteVersion(String fileName) async {
    final response = await http.get(Uri.parse('$remoteUrl/$fileName'));
    if (response.statusCode == 200) {
        return response.body;
    } else {
      throw Exception('Erreur lors du téléchargement de la version distante ${response.statusCode}' );
    }
  }


  Future<bool> fileExists(String filename) async{
      File file=File(filename);
      if (await file.exists()) {
        return true;
      }
      return false;
  }


  bool fileExistsSync(String filename) {
      File file=File(filename);
      if (file.existsSync()) {
        return true;
      }
      return false;
  }

  // Read local version
  Future<String> readLocalVersion(String fileName) async {
    
    final file = File('${directory.path}/$fileName');
    if (await file.exists()) {
      return file.readAsString();
    } else {
      return '0'; // Si le fichier n'existe pas encore
    }
  }

  // Compare version and start update
  Future<bool> checkAndUpdateVersion() async {
    try {

      if (kIsWeb) {

        return true;
      }

      directory = await getApplicationCacheDirectory();
      localVersion = await readLocalVersion("version.txt");
      remoteVersion = await fetchRemoteVersion("version.txt");


      if (localVersion != remoteVersion) {
        return await downloadNewVersion(false);
 
      } else {
        if (!await fileExists("${directory.path}/deepsky.lst")) {
           return await downloadNewVersion(false);
        }
        if (!await fileExists('${directory.path}/noerror')) {
          await downloadNewVersion(true);
        }
        return true;
      }
    } catch (e) {
      return false;
    }
  }


  Future<bool> downloadAndSave(String fileName) async {
    var response = await http.get(Uri.parse('$remoteUrl/$fileName'));
    if (response.statusCode == 200) {
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      return true;
    } else {
      return false;
    }
  }

  // Update all files
  Future<bool> downloadNewVersion(bool onlyRefresh) async {
    onValueChanged(0);
    String content;
    bool hasError=false;
    bool languageUpdated=false;

    if (onlyRefresh && await fileExists('${directory.path}/noerror')) {
      return true;
    }


    if (!onlyRefresh) {
      final fileLock = File('${directory.path}/noerror');
      if (await fileLock.exists()) {
        await fileLock.delete();
      }

      var  response = await http.get(Uri.parse('$remoteUrl/deepsky.lst'));
      if (response.statusCode == 200) {
        content=response.body;

      } else {
        return false;
      }
      final file = File('${directory.path}/deepsky.lst');
      await file.writeAsString(content);
      await downloadAndSave('en.json');
      await downloadAndSave('fr.json');
      languageUpdated=true;
    } else {
      content = await readLocalVersion("deepsky.lst");
    } 

    var catalog = await readCsvFile(content);
    int i=0;
     for (var row in catalog) {
        String imageName = row[13];
        if (imageName.isNotEmpty && !await File('${directory.path}/$imageName').exists()) {
          try { 

              var response = await http.get(Uri.parse("$remoteUrl/$imageName"));
              if (response.statusCode == 200) {
                // Enregistrer l'image dans le cache local
                File file = File('${directory.path}/$imageName');
                await file.writeAsBytes(response.bodyBytes);
                i+=1;
                onValueChanged(i/catalog.length);
              } else {
                hasError=true;
              }
            } catch (e) {
              i+=1;
              hasError=true;

            }
        }
     }


    if (!hasError && !await fileExists('${directory.path}/noerror')) {
      var f = File('${directory.path}/noerror');
      await f.create();
    }
    if (!onlyRefresh) {
      bool version=await downloadAndSave('version.txt');
      if (version && languageUpdated) {
         Restart.restartApp(

            );
      }
    }
    return true;
  }

  bool validateCatalog() {
    if (kIsWeb) {
      return true;
    }
    List<String> requiredFiles= ['deepsky.lst', 'en.json','fr.json'];
    for (var requiredFile in requiredFiles) {
      if (!fileExistsSync("${directory.path}/$requiredFile")) {
        return false;
      }
    }
    return true;
  }

  String getCacheDirectory() {
    return directory.path;
  }


}
