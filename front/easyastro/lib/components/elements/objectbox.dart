import 'package:flutter/material.dart';
import 'package:easyastro/components/elements/rating.dart';
import 'package:easyastro/models/catalogs.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easy_localization/easy_localization.dart';

class ObjectBox extends StatefulWidget {
  // final Function() onValueChanged;
  final RatingBox rating;
  final ObservableObject object;
  const ObjectBox({super.key, required this.object, required this.rating});

  @override
  State<ObjectBox> createState() => _ObjectBox();
}

class _ObjectBox extends State<ObjectBox> {
  Color getColor(bool isVisible, double height) {
    if (!isVisible) return Colors.red.shade800;
    if (height < 20) return Colors.orange.shade200;
    return Colors.green.shade900; //Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    Image currentImage;
    double imageSize;
    if (kIsWeb) {
      currentImage = Image.network(widget.object.image);
      //  imageSize=200;
    } else {
      currentImage = Image(image: AssetImage(widget.object.image));
      //   imageSize=MediaQuery.of(context).size.width*0.15;
      //imageSize=120;
    }
    imageSize = MediaQuery.of(context).size.width * 0.20;
    if (imageSize > 200) imageSize = 200;
    //final rbox = RatingBox(onValueChanged: onValueChanged, index: widget.item, initialValue: ObjectSelection().selection[widget.item].selected);
    return Container(
        padding: const EdgeInsets.all(2),
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: getColor(widget.object.visible, widget.object.height),
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
                            const Text("type").tr(args: [
                              widget.object.type.tr()
                            ]), //"Type: ${widget.object.type}"),
                            const Text("magnitude").tr(args: [
                              widget.object.magnitude.toString()
                            ]), //"Magnitude: ${widget.object.magnitude.toString()}"),
                          ],
                        ))),
                Container(
                    color: Theme.of(context).primaryColor,
                    child: widget.rating),
                ServerInfo().connected
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/capture',
                              arguments: {'object': widget.object.name});
                        },
                        child: const Icon(Icons.mode_standby, size: 48.0))
                    : const SizedBox(width: 0, height: 0)
              ]),
        ));
  }
}
