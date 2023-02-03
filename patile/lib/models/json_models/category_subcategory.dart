// ignore_for_file: non_constant_identifier_names

class Category {
  Category({required this.category_name, required this.subcategories});

  String category_name;
  List<SubCategories> subcategories;

  factory Category.fromJson(Map<String, dynamic> json) {
    var CList = json["subcategories"] as List;
    List<SubCategories> subCategoryList = CList.map((e) {
      return SubCategories.fromJson(e);
    }).toList();

    return Category(
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
        subcategory_name: json["subcategory_name"] ?? <SubCategories>[],
      );

  Map<String, dynamic> toJson() => {
        "subcategory_name": subcategory_name,
      };
}
