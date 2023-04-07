import 'package:flutter/material.dart'; 
import 'package:front_test/models/products.dart'; 
import 'package:front_test/components/productlist.dart';
import 'package:front_test/components/productbox.dart';  
import 'package:front_test/components/pagestructure.dart';


class ProductDisplay extends StatelessWidget {
  ProductDisplay({super.key});
  final items = Product.getProducts();



  @override
  Widget build(BuildContext context) {
    return PageStructure(body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: ProductBox(item: items[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductPage(item: items[index]),
                ),
              );
            },
          );
  
        }));
  }
}
