class Pokemon {
  final String name;
  final String hp;
  final String attack;
  final String defense;
  final String specialAttack;
  final String specialDefense;
  final String speed;
  final List<String> moves;
  final List<String> types;

  Pokemon({
    required this.name,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
    required this.moves,
    required this.types,
  });
}
