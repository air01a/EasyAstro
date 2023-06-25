
import 'package:easyastro/services/globals.dart';
import 'package:easyastro/services/api.dart';

class ProcessingHelper {
  final apiHelper = ApiBaseHelper();

  void changeProcessingParameters(int blacks, int whites, int midtones, double stretch, double r, double g, double b, double contrast) {
    Map<String, dynamic> params = {'blacks':blacks*256, 'whites':whites*256, 'midtones':midtones*256, 'stretch':stretch, 'r':r, 'g':g,'b':b, 'contrast':contrast};
    apiHelper.post(ServerInfo().host, "/telescope/processing/", params);

  }
}