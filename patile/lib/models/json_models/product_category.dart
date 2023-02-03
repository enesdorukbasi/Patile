// ignore_for_file: non_constant_identifier_names, empty_catches

class Type {
  Type(
      {required this.pet_type, required this.categories, required this.brands});

  String pet_type;
  List<Categories> categories;
  List<Brand> brands;

  factory Type.fromJson(Map<String, dynamic> json) {
    var CList = json["categories"] as List;
    List<Categories> categoryList =
        CList.map((e) => Categories.fromJson(e)).toList();

    var bList = json["brands"] as List;
    List<Brand> brandList = bList.map((e) => Brand.fromJson(e)).toList();

    return Type(
      pet_type: json["pet_type"],
      categories: json["categories"] != null ? categoryList : <Categories>[],
      brands: json["brands"] != null ? brandList : <Brand>[],
    );
  }

  Map<String, dynamic> toJson() => {
        "pet_type": pet_type,
        "categories": List<dynamic>.from(categories.map((e) => e.toJson())),
        "brands": List<dynamic>.from(brands.map((e) => e.toJson())),
      };
}

class Categories {
  Categories({required this.category_name, required this.subcategories});

  String category_name;
  List<SubCategories> subcategories;

  factory Categories.fromJson(Map<String, dynamic> json) {
    List sCList = [];
    List<SubCategories> subCategoryList = [];
    try {
      sCList = json["subcategories"] as List;
      subCategoryList = sCList.map((e) => SubCategories.fromJson(e)).toList();
    } catch (e) {}

    return Categories(
      category_name: json["category_name"],
      subcategories:
          json["subcategories"] != null ? subCategoryList : <SubCategories>[],
    );
  }

  factory Categories.fromJsonCat(Map<String, dynamic> json) {
    List sCList = [];
    List<SubCategories> subCategoryList = [];
    try {
      sCList = json["subcategories"] as List;
      subCategoryList = sCList.map((e) => SubCategories.fromJson(e)).toList();
    } catch (ex) {}

    return Categories(
      category_name: json["category_name"],
      subcategories:
          json["subcategories"] != null ? subCategoryList : <SubCategories>[],
    );
  }
  Map<String, dynamic> toJson() => {
        "category_name": category_name,
        "subcategories":
            List<dynamic>.from(subcategories.map((e) => e.toJson())),
      };
}

class SubCategories {
  SubCategories({required this.subcategory_name});

  String subcategory_name;

  factory SubCategories.fromJson(Map<String, dynamic> json) => SubCategories(
        subcategory_name: json["subcategory_name"],
      );

  Map<String, dynamic> toJson() => {
        "subcategory_name": subcategory_name,
      };
}

class Brand {
  Brand({required this.brand_name});

  String brand_name;

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        brand_name: json["brand_name"],
      );

  Map<String, dynamic> toJson() => {
        "brand_name": brand_name,
      };
}
