class Pokemon {
  String name;
  String description;
  String type;
  String imagePath = '';

  Pokemon({required this.name, required this.description, required this.type});

  set setImagePath(String newImagePath) {
    imagePath = newImagePath;
  }

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    var pokemonJson = json['pokemon'];
    return Pokemon(
      name: pokemonJson['name'],
      description: pokemonJson['description'],
      type: pokemonJson['type'],
    );
  }
}
