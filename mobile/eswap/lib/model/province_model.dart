class Province {
  final String id;
  final String name;
  final String nameEn;
  final String codeName;

  Province(
      {required this.id,
      required this.name,
      required this.nameEn,
      required this.codeName});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'],
      codeName: json['codeName'],
    );
  }
}
