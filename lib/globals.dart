String logs = '';
String magic = '';


void printLog(Object s) {
  print(s);
  logs += '\n${s.toString()}s';
}