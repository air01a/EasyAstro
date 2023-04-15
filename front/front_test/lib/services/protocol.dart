
class CommunicationProtocol {

  Map<String,dynamic> analyseMessage(String message) {
      final ret = { 'refreshImage':false, 'showMessage':''};
      if (message[0]=='2') {
        ret['refreshImage']=true;
      } else {
        ret['showMessage']=message;
      }

      return ret;

  }
}
