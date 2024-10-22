import 'package:flutter/material.dart';
import 'package:easyastro/components/elements/rating.dart';
import 'package:easyastro/models/catalogs.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easyastro/services/database/configmanager.dart';
import 'package:easyastro/components/elements/customcard.dart';
import 'dart:io';
class ObjectBox extends StatefulWidget {
  // final Function() onValueChanged;
  final RatingBox rating;
  final ObservableObject object;
  const ObjectBox({super.key, required this.object, required this.rating});

  @override
  State<ObjectBox> createState() => _ObjectBox();
}

class _ObjectBox extends State<ObjectBox> {

  late List<bool> azimuth;
  late int minHeight;

  Color getColor(bool isVisible, double height, double az, bool perturbedByMoon) {
    if (!isVisible) return Colors.red.shade800;
    
    if (!azimuth[(az/10).toInt()]) return Colors.pink.shade200;
    if (perturbedByMoon) return Colors.pink.shade200;
    if (height < minHeight) return Colors.orange.shade200;
    return Colors.green.shade900; //Theme.of(context).primaryColor;
  }

  String getComment(bool isVisible, double height, double az, bool perturbedByMoon) {
    if (!isVisible) return "not_visible";
    
    if (!azimuth[(az/10).toInt()]) return "not_visible_from_location";
    if (perturbedByMoon) return "perturbed_by_moon";
    if (height < minHeight) return "low_on_horizon";
    return "visible"; 
  }

  @override
  void initState() {

    super.initState();
    azimuth = List<bool>.from(ConfigManager().configuration?["azimuth"]?.value);
    int ?tminHeight = int.tryParse(ConfigManager().configuration?["minHeight"]?.value);
    if (tminHeight==null) {
      minHeight=20;
    } else {
      minHeight=tminHeight;
    }
  }
  @override
  Widget build(BuildContext context) {
    Image currentImage;
    double imageSize;
    if (kIsWeb) {
      currentImage = Image.network(widget.object.image);
      imageSize=140;
    } else {
      //currentImage = Image(image: AssetImage(widget.object.image));
      currentImage = Image.file(File(widget.object.image));
      imageSize=MediaQuery.of(context).size.width*0.2;
          if (imageSize>150) {
      imageSize = 150;
    }
    }


    Color blockColor = getColor(widget.object.visible, widget.object.height, widget.object.azimuth, widget.object.perturbedByMoon);
    String comment = getComment(widget.object.visible, widget.object.height, widget.object.azimuth, widget.object.perturbedByMoon).tr();

    return Container(
        padding: const EdgeInsets.all(8),
        child: CardWithTitle(
          blockColor: blockColor,
          title: comment,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: blockColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          color: Theme.of(context).primaryColor,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                    width: imageSize + 10,
                    height: imageSize + 10,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: currentImage.image,
                        ))),
                Expanded(
                    child: Container(
                        color: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(widget.object.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))
                                .tr(),
                            if (widget.object.rise != widget.object.set)
                              const Text("rise_set").tr(args: [
                                ConvertAngle.hourToString(widget.object.rise),
                                ConvertAngle.hourToString(widget.object.set)
                              ])
                            else
                              const Text("circumpolar")
                                  .tr(), //"Rise : ${ConvertAngle.hourToString(widget.object.rise)} - Set : ${ConvertAngle.hourToString(widget.object.set)} "),
                            const Text("culmination").tr(args: [
                              ConvertAngle.hourToString(widget.object.meridian)
                            ]), //"Culmination : ${ConvertAngle.hourToString(widget.object.meridian)}"),
                            ConfigManager().configuration?["showType"]?.value  
                                  ? const Text("type").tr(args: [
                                        widget.object.type.tr()
                                      ])
                                  : Container(), //"Type: ${widget.object.type}"),
                            ConfigManager().configuration?["showMag"]?.value  
                                  ? const Text("magnitude").tr(args: [
                                        widget.object.magnitude.toString()
                                      ])
                                  : Container(),
                            ConfigManager().configuration?["showAzAlt"]?.value  
                                  ? const Text("azalt").tr(args:[widget.object.azimuth.toInt().toString(), widget.object.height.toInt().toString()])
                                  : Container()
                           
                          ],
                        ))),
                Container(
                    color: Theme.of(context).primaryColor,
                    child: widget.rating),
                ServerInfo().connected
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/capture',
                              arguments: {'object': widget.object.name});
                        },
                        child: const Icon(Icons.mode_standby, size: 48.0))
                    : const SizedBox(width: 0, height: 0)
              ]),
        ));
  }
}
