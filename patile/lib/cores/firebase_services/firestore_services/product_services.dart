import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patile/cores/firebase_services/storage_services/storage_service.dart';
import 'package:patile/models/firebase_models/product.dart';

class ProductFirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createProduct({
    required productName,
    required content,
    required petType,
    required category,
    required subCategory,
    required brand,
    required price,
    required imageOneUrl,
    required imageTwoUrl,
    required imageThreeUrl,
    required secondHand,
    required stockQuantity,
    required publishedUserId,
  }) async {
    await _firestore.collection("products").doc().set({
      "productName": productName,
      "content": content,
      "petType": petType,
      "category": category,
      "subCategory": subCategory,
      "brand": brand,
      "price": price,
      "imageOneUrl": imageOneUrl ?? "",
      "imageTwoUrl": imageTwoUrl ?? "",
      "imageThreeUrl": imageThreeUrl ?? "",
      "secondHand": secondHand,
      "stockQuantity": stockQuantity,
      "publishedUserId": publishedUserId
    });
  }

  deleteProduct(productId) async {
    DocumentSnapshot doc =
        await _firestore.collection("products").doc(productId).get();

    if (doc.exists) {
      Product product = Product.createProductByDoc(doc);

      if (product.imageOneUrl != "") {
        StorageService().productImageDelete(product.imageOneUrl);
      }
      if (product.imageTwoUrl != "") {
        StorageService().productImageDelete(product.imageTwoUrl);
      }
      if (product.imageThreeUrl != "") {
        StorageService().productImageDelete(product.imageThreeUrl);
      }

      doc.reference.delete();
    }
  }

  Future<List<Product>> getAllProducts() async {
    QuerySnapshot querySnapshot = await _firestore.collection("products").get();

    List<Product> products = querySnapshot.docs
        .map((DocumentSnapshot doc) => Product.createProductByDoc(doc))
        .toList();

    return products;
  }

  Future<void> editProduct(productId, Product product) async {
    DocumentSnapshot doc =
        await _firestore.collection("products").doc(productId).get();

    if (doc.exists) {
      Product oldProduct = Product.createProductByDoc(doc);

      if (product.imageOneUrl != "") {
        if (product.imageOneUrl != oldProduct.imageOneUrl) {
          if (oldProduct.imageOneUrl != "") {
            StorageService().productImageDelete(oldProduct.imageOneUrl);
            product.imageOneUrl = oldProduct.imageOneUrl;
          }
        }
      }
      if (product.imageTwoUrl != "") {
        if (product.imageTwoUrl != oldProduct.imageTwoUrl) {
          if (oldProduct.imageTwoUrl != "") {
            StorageService().productImageDelete(oldProduct.imageTwoUrl);
            product.imageTwoUrl = oldProduct.imageTwoUrl;
          }
        }
      }
      if (product.imageThreeUrl != "") {
        if (product.imageThreeUrl != oldProduct.imageThreeUrl) {
          if (oldProduct.imageThreeUrl != "") {
            StorageService().productImageDelete(oldProduct.imageThreeUrl);
            product.imageThreeUrl = oldProduct.imageThreeUrl;
          }
        }
      }

      doc.reference.update({
        "productName": product.productName,
        "content": product.content,
        "petType": product.petType,
        "category": product.category,
        "subCategory": product.subCategory,
        "brand": product.brand,
        "price": product.price,
        "imageOneUrl": product.imageOneUrl,
        "imageTwoUrl": product.imageTwoUrl,
        "imageThreeUrl": product.imageThreeUrl,
        "secondHand": product.secondHand,
        "stockQuantity": product.stockQuantity,
        "publishedUserId": product.publishedUserId
      });
    }
  }

  Future<List<Product>> getProductsByFilter(selectedPetType, selectedCategory,
      selectedSubCategory, selectedBrand, secondHand) async {
    QuerySnapshot querySnapshot = await _firestore.collection("products").get();

    List<Product> allProducts = querySnapshot.docs
        .map((DocumentSnapshot doc) => Product.createProductByDoc(doc))
        .toList();

    List<Product> filterProducts = allProducts
        .where((element) => element.petType.contains(selectedPetType))
        .where((element) => element.category.contains(selectedCategory))
        .where((element) => element.subCategory.contains(selectedSubCategory))
        .where((element) => element.brand.contains(selectedBrand))
        .where((element) => secondHand != null
            ? (element.secondHand == secondHand)
            : element.content.contains(""))
        .toList();

    return filterProducts;
  }

  Future<Product> getProductById(id) async {
    DocumentSnapshot doc =
        await _firestore.collection("products").doc(id).get();

    Product product = Product.createProductByDoc(doc);
    return product;
  }

  Future<List<Product>> getProductsByUserId(publishedUserId) async {
    QuerySnapshot querySnapshot = await _firestore.collection("products").get();

    List<Product> allProducts = querySnapshot.docs
        .map((DocumentSnapshot doc) => Product.createProductByDoc(doc))
        .toList();

    List<Product> filterProducts = allProducts
        .where((element) => element.publishedUserId == publishedUserId)
        .toList();

    return filterProducts;
  }
}
