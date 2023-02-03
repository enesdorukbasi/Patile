class ProductSqLite {
  final int id;
  final String firebaseProductId;
  final String userId;

  ProductSqLite(this.id, this.firebaseProductId, this.userId);

  factory ProductSqLite.fromJSON(json) =>
      ProductSqLite(json['id'], json['firebaseProductId'], json['userId']);
}
