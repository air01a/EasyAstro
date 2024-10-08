import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';



class CatalogUpdater  {
  String localVersion = '0';
  String remoteVersion = '0';
  String remoteUrl;
  final Function(double) onValueChanged;
  late Directory directory;
 

  CatalogUpdater(this.remoteUrl, this.onValueChanged);

  Future<List<List<dynamic>>> readCsvFile(input) async {
      List<List<dynamic>> csvData = const CsvToListConverter(fieldDelimiter: ';').convert(input);
      
      if (csvData.isNotEmpty) {
        csvData.removeAt(0); // Remove header
      }

      return csvData;
  }

  // Download remote version
  Future<String> fetchRemoteVersion(String fileName) async {
    final response = await http.get(Uri.parse('$remoteUrl/$fileName'));
    if (response.statusCode == 200) {
        return response.body.trim();
    } else {
      throw Exception('Erreur lors du téléchargement de la version distante ${response.statusCode}' );
    }
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
      directory = await getApplicationCacheDirectory();
      localVersion = await readLocalVersion("version.txt");
      remoteVersion = await fetchRemoteVersion("version.txt");

      if (localVersion != remoteVersion) {
        return await downloadNewVersion();
 
      } else {
        File file=File("$directory/deepsky.lst");
        if (!await file.exists()) {
           return await downloadNewVersion();
        }
        return true;
      }
    } catch (e) {
      return false;
    }
  }


  Future<void> downloadAndSave(String fileName) async {
    var response = await http.get(Uri.parse('$remoteUrl/$fileName'));
    if (response.statusCode == 200) {
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Erreur lors du téléchargement du fichier ${response.statusCode}');
    }

  }

  // Update all files
  Future<bool> downloadNewVersion() async {
    onValueChanged(0);
    final directory = await getApplicationCacheDirectory();
    var  response = await http.get(Uri.parse('$remoteUrl/deepsky.lst'));
    String content;
    if (response.statusCode == 200) {
      content=response.body;

    } else {
      return false;
    }
    var catalog = await readCsvFile(response.body);
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
                return false;
              }
            } catch (e) {
              return false;
            }
        }
     }
    downloadAndSave('en.json');
    downloadAndSave('fr.json');
    final file = File('${directory.path}/deepsky.lst');
    await file.writeAsString(content);
    downloadAndSave('version.txt');
    return true;
  }


  String getCacheDirectory() {
    return directory.path;
  }
}
