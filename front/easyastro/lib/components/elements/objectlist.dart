import 'package:flutter/material.dart';
import 'package:easyastro/components/elements/rating.dart';
import 'package:easyastro/services/database/globals.dart';
import 'package:easyastro/models/catalogs.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:easyastro/components/structure/pagestructure.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easyastro/components/graphics/azimutalgraph.dart';
import 'package:easy_localization/easy_localization.dart';

class ObjectPage extends StatefulWidget {
  final ObservableObject item;
  final int index;
  final Function(int, bool) onValueChanged;
  bool initialValue;
  ObjectPage(
      {super.key,
      required this.item,
      required this.index,
      required this.onValueChanged,
      required this.initialValue});
  @override
  State<ObjectPage> createState() => _ObjectPage();
}

class _ObjectPage extends State<ObjectPage> {
  Map<double, double> azimuthalChart = {};
  late RatingBox ratingBox;
  @override
  void initState() {
    super.initState();
    if (ObjectSelection().astro != null) {
      azimuthalChart = ObjectSelection().astro!.getAzimutalChart(widget.item.ra,
          widget.item.dec, ObjectSelection().astro!.getSiderealTime());
    }
    ratingBox = RatingBox(
        onValueChanged: widget.onValueChanged,
        index: widget.index,
        initialValue: widget.initialValue);
  }

  Widget title(String text) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(text.tr(),
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 17)));
  }

  @override
  Widget build(BuildContext context) {
    Image currentImage;
    Image? locationImage;
    if (kIsWeb) {
      currentImage = Image.network(widget.item.image);
      if (widget.item.location != '') {
        locationImage = Image.network(widget.item.location);
      }
    } else {
      currentImage = Image(image: AssetImage(widget.item.image));
      if (widget.item.location != '') {
        locationImage = Image(image: AssetImage(widget.item.location));
      }
    }

    final mediaQueryData = MediaQuery.of(context);

    // Récupère la taille de l'écran en pixels
    final screenSize = mediaQueryData.size;
    final screenWidth = screenSize.width;

    return PageStructure(
        body: Center(
            child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Container(
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.all(5),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                        child: Container(
                            width: 300.0,
                            height: 300.0,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: currentImage.image,
                                )))),
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                title(widget.item.name),

                                Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Text(
                                      "_${widget.item.name}",
                                      textAlign: TextAlign.center,
                                      maxLines: 10,
                                    ).tr()),
                                title("information"),
                                if (widget.item.rise != widget.item.set)
                                  Text('rise').tr(args: [
                                    ConvertAngle.hourToString(widget.item.rise)
                                  ])
                                else
                                  Text('circumpolar').tr(),
                                if (widget.item.rise !=
                                    widget.item
                                        .set) //"Rise : ${ConvertAngle.hourToString(widget.item.rise)}"),
                                  Text('set').tr(args: [
                                    ConvertAngle.hourToString(widget.item.set)
                                  ]), //"Set : ${ConvertAngle.hourToString(widget.item.set)}"),
                                Text('culmination').tr(args: [
                                  ConvertAngle.hourToString(
                                      widget.item.meridian)
                                ]), //"Culmination : ${ConvertAngle.hourToString(widget.item.meridian)}"),
                                Text('magnitude', textAlign: TextAlign.left)
                                    .tr(args: [
                                  widget.item.magnitude.toString()
                                ]), //"Magnitude : ${widget.item.magnitude.toString()}", textAlign: TextAlign.left),
                                Text('current_height',
                                        textAlign: TextAlign.left)
                                    .tr(args: [
                                  widget.item.height.toInt().toString()
                                ]), //"Current Height : ${widget.item.height.toInt().toString()}°", textAlign: TextAlign.left),
                                ratingBox,
                                if (locationImage != null) ...[
                                  title('location'),
                                  locationImage,
                                ],

                                ServerInfo().connected
                                    ? ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              '/capture',
                                              (Route<dynamic> route) => false,
                                              arguments: {
                                                'object': widget.item.name
                                              });
                                        },
                                        child: const Icon(Icons.mode_standby,
                                            size: 48.0))
                                    : const SizedBox(width: 0, height: 0),
                                title('azimut_graph'),
                                SizedBox(
                                    width: screenWidth * 0.8,
                                    height: screenWidth * 0.4,
                                    child: Center(
                                        child: AzimutalGraph(
                                            data: azimuthalChart)))
                              ],
                            )))
                  ]),
            ),
          ),
        )),
        showDrawer: false,
        title: widget.item.name);
  }
}
