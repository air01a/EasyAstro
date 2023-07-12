import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/services/network/api.dart';

class ProcessingHelper {
  final apiHelper = ApiBaseHelper();

  void changeProcessingParameters(
      int blacks,
      int whites,
      double midtones,
      double stretch,
      int stretchAlgo,
      double r,
      double g,
      double b,
      double contrast) {
    Map<String, dynamic> params = {
      'blacks': blacks * 256,
      'whites': whites * 256,
      'midtones': midtones,
      'stretch': stretch,
      'stretchAlgo': stretchAlgo,
      'r': r,
      'g': g,
      'b': b,
      'contrast': contrast
    };
    apiHelper.post(ServerInfo().host, "/telescope/processing", params);
  }
}
