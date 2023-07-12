class CommunicationProtocol {
  Map<String, dynamic> analyseMessage(String message) {
    final ret = {
      'refreshImage': false,
      'goto_success': false,
      'imageStacking': false,
      'showMessage': ''
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
        break;
    }
    ret['showMessage'] = message;
    return ret;
  }
}
