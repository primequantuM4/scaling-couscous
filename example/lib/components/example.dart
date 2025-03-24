import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'colors.dart';
import 'terminal_functions.dart';
import 'text_component_style.dart';
import 'text_field_component.dart';
import 'package:http/http.dart' as http;

class PokemonTUI {
  void displayCenteredText(String text) {
    final width = Terminal.getWidth();
    final height = Terminal.getHeight();

    stdout.write('\x1B[${height ~/ 2};${width ~/ 2}H');
    stdout.write('$text');
  }

  Future<void> clearScreenWithDelay(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
    stdout.write('\x1B[2J');
    stdout.write('\x1B[H');
  }

  void displayTypes() {
    final types = [
      "Normal",
      "Fire",
      "Water",
      "Electric",
      "Grass",
      "Ice",
      "Fighting",
      "Poison",
      "Ground",
      "Flying",
      "Psychic",
      "Bug",
      "Rock",
      "Ghost",
      "Dragon",
      "Dark",
      "Steel",
      "Fairy"
    ];

    final threshold = 3;

    for (int i = 0; i < types.length; i++) {
      final colorStyle = _getTypeColor(types[i]);
      stdout.write(colorStyle.render(types[i]));
      stdout.write('   ');
      if ((i + 1) % threshold == 0) stdout.writeln('\n');
    }
    stdout.write('\n');
  }

  TextComponentStyle _getTypeColor(String type) {
    final commonStyling = TextComponentStyle()
        .foreground(ColorRGB(255, 255, 255))
        .paddingLeft(2)
        .paddingRight(2)
        .bold();

    switch (type.toLowerCase()) {
      case 'normal':
        return commonStyling
            .foreground(ColorRGB(0, 0, 0))
            .background(ColorRGB(170, 170, 153));

      case 'fire':
        return commonStyling.background(ColorRGB(255, 68, 34));
      case 'water':
        return commonStyling.background(ColorRGB(51, 153, 255));
      case 'grass':
        return commonStyling.background(ColorRGB(119, 204, 85));
      case 'electric':
        return commonStyling
            .foreground(ColorRGB(0, 0, 0))
            .background(ColorRGB(255, 204, 51));
      case 'ice':
        return commonStyling.background(ColorRGB(102, 204, 255));
      case 'poison':
        return commonStyling.background(ColorRGB(170, 85, 153));
      case 'ground':
        return commonStyling.background(ColorRGB(221, 187, 85));
      case 'flying':
        return commonStyling.background(ColorRGB(136, 153, 255));
      case 'psychic':
        return commonStyling.background(ColorRGB(255, 85, 153));
      case 'bug':
        return commonStyling.background(ColorRGB(170, 187, 34));
      case 'rock':
        return commonStyling.background(ColorRGB(187, 170, 102));
      case 'ghost':
        return commonStyling.background(ColorRGB(102, 102, 182));
      case 'dragon':
        return commonStyling.background(ColorRGB(119, 102, 238));
      case 'dark':
        return commonStyling.background(ColorRGB(119, 85, 68));
      case 'steel':
        return commonStyling.background(ColorRGB(170, 170, 187));
      case 'fairy':
        return commonStyling.background(ColorRGB(238, 153, 238));
      case 'fighting':
        return commonStyling.background(ColorRGB(187, 85, 68));
      default:
        return TextComponentStyle().foreground(Colors.white);
    }
  }

  Future<void> start() async {
    Terminal.enterFullscreen();

    final TextComponentStyle pokemonStyle = TextComponentStyle()
        .foreground(ColorRGB(255, 203, 5))
        .background(ColorRGB(30, 100, 196))
        .paddingLeft(2)
        .paddingRight(2);

    final pokemonText = pokemonStyle.render('POKÉMON');

    displayCenteredText('$pokemonText');
    await clearScreenWithDelay(2);

    stdout.write('Pokemon Types:\n');
    displayTypes();

    stdout.write('\nWhat is your favorite Pokémon?\n');
    String? pokemon = await _getTextInput();

    stdout.write(
        '\nWhat are your favorite attacks? Choose from the following:\n');
    final attacks = [
      'Fire Blast',
      'Hydro Pump',
      'Thunderbolt',
      'Psychic',
      'Brick Break'
    ];
    final attackChoices = <String>[];

    for (var attack in attacks) {
      stdout.write('[$attack] (y/n): ');
      String? response = await _getTextInput();
      if (response?.toLowerCase() == 'y') {
        attackChoices.add(attack);
      }
    }

    // Final summary
    stdout.write('\nYou selected Pokémon: $pokemon\n');
    stdout.write('With the following attacks:\n');
    attackChoices.forEach((attack) => stdout.write('$attack\n'));
  }

  // Get text input from the user
  Future<String?> _getTextInput() async {
    final inputCompleter = Completer<String?>();

    final textField = TextfieldComponent(
      textStyle: TextComponentStyle().foreground(Colors.green),
      onSubmitted: (value) {
        inputCompleter.complete(value);
      },
    );

    textField.focused = true;

    // Listen for the user's input
    await inputCompleter.future;
    return textField.value;
  }
}

void main() {
  final tui = PokemonTUI();
  tui.start();
}
