class Player {
  final String id;
  final String name;
  final String color;
  Player({required this.id, required this.name, required this.color});
  factory Player.fromJson(Map<String, dynamic> j) =>
      Player(id: j['id'] ?? '', name: j['name'] ?? '', color: j['color'] ?? 'red');
}
