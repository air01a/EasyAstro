class Product {
   final String name; 
   final String description; 
   final int price; 
   final String image; 
   int rating;
   Product(this.name, this.description, this.price, this.image, this.rating); 
   
   

   static List<Product> getProducts() {
      List<Product> items = <Product>[]; 
      items.add(
         Product(
            "Pixel", 
            "Pixel IS the most featureful phone ever", 
            800, 
            "pixel.jpg",
            0
         )
      );
      items.add(
         Product(
            "Laptop", 
            "Laptop is most productive development tool", 
            2000, 
            "laptop.jpg",
            0
         )
      ); 
      items.add(
         Product(
            "Tablet", 
            "Tablet is the most useful device ever for meeting", 
            1500, 
            "tablet.jpg",
            0
         )
      ); 
      items.add(
         Product( 
            "Pendrive", 
            "iPhone is the stylist phone ever", 
            100, 
            "pendrive.jpg",
            0
         )
      ); 
      items.add(
         Product(
            "Floppy Drive", 
            "iPhone is the stylist phone ever", 
            20, 
            "floppydisk.jpg", 
            0
         )
      ); 
      items.add(
         Product(
            "iPhone", 
            "iPhone is the stylist phone ever", 
            1000, 
            "iphone.jpg", 
            0
         )
      ); 
      return items; 
   }
}