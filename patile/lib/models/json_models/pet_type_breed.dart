// ignore_for_file: non_constant_identifier_names

class Type {
  Type({required this.type_name, required this.breeds});

  String type_name;
  List<Breed> breeds;

  factory Type.fromJson(Map<String, dynamic> json) {
    var list = json["breeds"] as List;
    List<Breed> breedsList = list.map((e) => Breed.fromJson(e)).toList();

    return Type(
      type_name: json["type_name"],
      breeds: json["breeds"] != null ? breedsList : <Breed>[],
    );
  }

  Map<String, dynamic> toJson() => {
        "type_name": type_name,
        "breeds": List<dynamic>.from(breeds.map((e) => e.toJson())),
      };
}

class Breed {
  Breed({required this.breed_name});

  String breed_name;

  factory Breed.fromJson(Map<String, dynamic> json) => Breed(
        breed_name: json["breed_name"],
      );
  Map<String, dynamic> toJson() => {
        "breed_name": breed_name,
      };
}
