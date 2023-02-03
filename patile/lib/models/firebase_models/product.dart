import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id,
      productName,
      content,
      petType,
      category,
      subCategory,
      brand,
      price,
      imageOneUrl,
      imageTwoUrl,
      imageThreeUrl,
      publishedUserId;
  bool secondHand;
  int stockQuantity;

  Product({
    required this.id,
    required this.productName,
    required this.content,
    required this.petType,
    required this.category,
    required this.subCategory,
    required this.brand,
    required this.price,
    required this.imageOneUrl,
    required this.imageTwoUrl,
    required this.imageThreeUrl,
    required this.secondHand,
    required this.stockQuantity,
    required this.publishedUserId,
  });

  factory Product.createProductByDoc(DocumentSnapshot doc) {
    return Product(
        id: doc.id,
        productName: doc.get("productName"),
        content: doc.get("content"),
        petType: doc.get("petType"),
        category: doc.get("category"),
        subCategory: doc.get("subCategory"),
        brand: doc.get("brand"),
        price: doc.get("price"),
        imageOneUrl: doc.get("imageOneUrl"),
        imageTwoUrl: doc.get("imageTwoUrl"),
        imageThreeUrl: doc.get("imageThreeUrl"),
        secondHand: doc.get("secondHand"),
        stockQuantity: doc.get("stockQuantity"),
        publishedUserId: doc.get("publishedUserId"));
  }
}
