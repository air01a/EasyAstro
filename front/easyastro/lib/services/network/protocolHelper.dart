import 'package:flutter/material.dart';

class CommunicationProtocol {
  Map<String, dynamic> analyseMessage(Map<String, dynamic> message) {
    final ret = {
      'refreshImage': false,
      'displayMessage': true,
      'goto_success': false,
      'imageStacking': false,
      'showMessage': '',
      'stacked': 0,
      'discarded': 0,
      'color': Colors.white,
      'alert': false
    };
    switch (message['type']) {
      case 2:
        {
          ret['refreshImage'] = true;
          ret['displayMessage'] = false;
        }
        break;
      case 3:
        {
          ret['goto_success'] = true;
        }
        break;
      case 4:
        {
          ret['refreshImage'] = true;
          ret['imageStacking'] = true;
        }
        continue also5;
      also5:
      case 5:
        {
          //List<dynamic> info = splitStackMessage(message);
          ret['stacked'] = message['stacked'];
          ret['discarded'] = message['discarded'];
          if (message['type'] == '5') {
            ret['color'] = Colors.red;
            ret['alert'] = true;
          }
        }
        break;
      case 6:
        {
          ret['showMessage'] =
              "${message['message']} (error: ${message['error_rate'].toStringAsFixed(2)}°)";
        }
        break;
      case 9:
        {
          ret['showMessage'] = message['message'];
          ret['color'] = Colors.red;
          ret['alert'] = true;
        }
    }
    //ret['showMessage'] = message;
    if (ret['showMessage'] == '') ret['showMessage'] = message['message'];
    return ret;
  }
}
