import 'package:flutter/material.dart';
import 'package:easyastro/services/database/localstoragehelper.dart';
import 'package:easyastro/astro/astrocalc.dart';
import 'package:easyastro/components/structure/pagestructure.dart';

class LoadSelection extends StatefulWidget {
  const LoadSelection({super.key, this.title, required this.callback});
  final Function(Map<String,dynamic>) callback;
  final String? title;

  @override
  State<LoadSelection> createState() => _LoadSelection();
}

class _LoadSelection extends State<LoadSelection> {
  Map<String, dynamic>? _items = <String, dynamic>{};
  final localStorage = LocalStorage('selection');


  @override
  void initState() {
    super.initState();
    localStorage.getAllSelections().then((value)=>{ if (value!=null) setState(() { _items = value;})});
    

  }

  void onClick(Map<String,dynamic> item){
    widget.callback(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PageStructure(
      body: ListView.builder(
        itemCount: _items!.keys.length,
        itemBuilder: (context, index) {
          final key = _items!.keys.elementAt(index);
          final item = _items![key]!;
          return GestureDetector(onTap:() => {onClick(item) },
          child:Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${item["date"]} - ${ConvertAngle.hourToString(item["hour"])}"),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      localStorage.deleteSelection(key);
                      _items!.remove(key);
                    });
                  })
              ])
            ));
        },
      ),
      showDrawer: false,
       title:"Selection stored"
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
