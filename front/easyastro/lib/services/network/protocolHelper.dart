import 'package:image/image.dart';
import 'package:flutter/material.dart';

class CommunicationProtocol {
  List<dynamic> splitStackMessage(String message) {
    List<dynamic> ret = [];

    var tab = message.split(';');
    ret.add(tab[0]);
    List<String> tab2 = tab[1].split(',');
    ret.add(int.parse(tab2[0]));
    ret.add(int.parse(tab2[1]));
    return ret;
  }

  Map<String, dynamic> analyseMessage(String message) {
    final ret = {
      'refreshImage': false,
      'goto_success': false,
      'imageStacking': false,
      'showMessage': '',
      'stacked': 0,
      'discarded': 0,
      'color': Colors.white
    };
    switch (message[0]) {
      case '2':
        {
          ret['refreshImage'] = true;
        }
        break;
      case '3':
        {
          ret['goto_success'] = true;
        }
        break;
      case '4':
        {
          ret['refreshImage'] = true;
          ret['imageStacking'] = true;
        }
        continue also5;
      also5:
      case '5':
        {
          List<dynamic> info = splitStackMessage(message);
          ret['stacked'] = info[1];
          ret['discarded'] = info[2];
          message = info[0];
          if (message[0] == '5') ret['colors'] = Colors.red;
        }
    }
    ret['showMessage'] = message;
    print(ret);
    return ret;
  }
}
