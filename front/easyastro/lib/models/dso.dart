import 'package:easyastro/models/skyobject.dart';

class DSO extends SkyObject {
  String name;
  int type;
  int phase;
  int color;
  DSO(super.pos, this.name, this.type, this.phase, this.color);
}
