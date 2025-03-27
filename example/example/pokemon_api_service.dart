import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'pokemon.dart';

const _apiBaseUrl = 'https://pokeapi.co/api/v2/pokemon';
const _maxMoves = 8;

class PokemonApiService {
  static Future<Pokemon> fetchPokemon(String name) async {
    final response = await http.get(Uri.parse('$_apiBaseUrl/$name'));

    if (response.statusCode != 200) {
      throw Exception('Pokémon not found!');
    }

    final data = jsonDecode(response.body);
    return _parsePokemonData(data);
  }

  static Pokemon _parsePokemonData(Map<String, dynamic> data) {
    final stats = data['stats'];

    return Pokemon(
      name: data['name'],
      hp: stats[0]['base_stat'].toString(),
      attack: stats[1]['base_stat'].toString(),
      defense: stats[2]['base_stat'].toString(),
      specialAttack: stats[3]['base_stat'].toString(),
      specialDefense: stats[4]['base_stat'].toString(),
      speed: stats[5]['base_stat'].toString(),
      moves: _extractMoves(data['moves']),
      types: _extractTypes(data['types']),
    );
  }

  static List<String> _extractMoves(List<dynamic> moves) {
    return moves
        .take(_maxMoves)
        .map((m) => m['move']['name'] as String)
        .toList();
  }

  static List<String> _extractTypes(List<dynamic> types) {
    return types.map((t) => t['type']['name'] as String).toList();
  }
}
