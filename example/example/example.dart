import 'dart:async';

import 'package:example/components/checkbox.dart';
import 'package:example/components/spinner.dart';
import 'package:example/components/colors.dart';
import 'package:example/components/terminal_functions.dart';
import 'package:example/components/text_component_style.dart';
import 'package:example/components/text_field_component.dart';

import 'pokemon.dart';
import 'pokemon_api_service.dart';
import 'style_helper.dart';

const _typeDisplayColumns = 3;
const _clearScreenDelaySeconds = 2;

class PokemonTUI {
  Future<void> start() async {
    Terminal.enterFullscreen();
    await _showWelcomeScreen();
    _displayTypeChart();
    await _promptForPokemon();
  }

  Future<void> _showWelcomeScreen() async {
    Terminal.pauseInput();
    final style = TextComponentStyle()
        .foreground(ColorRGB(255, 203, 5))
        .background(ColorRGB(30, 100, 196))
        .paddingRight(2)
        .paddingLeft(2);
    Terminal.displayCentered(style.render('POKÉMON'));
    await Terminal.clearAfterDelay(_clearScreenDelaySeconds);
    Terminal.resumeInput();
  }

  void _displayTypeChart() {
    final commandStyle =
        TextComponentStyle().foreground(Colors.green).background(Colors.black);
    Terminal.writeLn(commandStyle.render("Press :q<Enter> to exit\n"));
    Terminal.writeLn('Pokemon Types:');
    const types = [
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

    for (int i = 0; i < types.length; i++) {
      Terminal.write(StyleHelper.typeStyle(types[i]).render(types[i]));
      String dat = '          ';
      Terminal.write(dat);
      if ((i + 1) % _typeDisplayColumns == 0) Terminal.writeLn('\n');
    }
    Terminal.writeLn('');
  }

  Future<void> _promptForPokemon() async {
    Terminal.writeLn('\nWhat is your favorite Pokémon?');

    final textFieldController = TextfieldComponent(
      onSubmitted: _handlePokemonInput,
      placeHolder: 'Pikachu',
      textStyle: TextComponentStyle().foreground(Colors.yellow),
    );

    textFieldController.focused = true;
  }

  Future<void> _handlePokemonInput(String input) async {
    final spinner = Spinner(color: ColorRGB(255, 255, 255));
    try {
      spinner.start(message: "Fetching Pokemon...");
      final pokemon = await PokemonApiService.fetchPokemon(input);
      spinner.stop(message: '');
      _displayPokemonDetails(pokemon);
      _promptForMoves(pokemon.moves);
    } catch (e) {
      spinner.stop(message: '');
      Terminal.writeLn('$e Press :q<Enter> to exit');
    }
  }

  void _displayPokemonDetails(Pokemon pokemon) {
    Terminal.writeLn('');
    _displayStats(pokemon);
    _displayTypes(pokemon.types);
  }

  void _displayStats(Pokemon pokemon) {
    final stats = {
      'HP': pokemon.hp,
      'Atk': pokemon.attack,
      'Def': pokemon.defense,
      'Sp.Atk': pokemon.specialAttack,
      'Sp.Def': pokemon.specialDefense,
      'Speed': pokemon.speed,
    };

    for (final entry in stats.entries) {
      final style = StyleHelper.randomColoredStyle();
      Terminal.write(style.render('${entry.key}: ${entry.value}'));
      Terminal.write(' ');
    }
  }

  void _displayTypes(List<String> types) {
    Terminal.writeLn('\n');
    Terminal.write('Type: ');
    for (final type in types) {
      Terminal.write(StyleHelper.typeStyle(type).render(type));
    }
    Terminal.writeLn('\n');
  }

  void _promptForMoves(List<String> moves) {
    Terminal.writeLn(
        'Choose your Pokémon moves (Use j/k to navigate, <Space> to select, <Enter> to confirm)');

    final checkbox = Checkbox(
      items: moves,
      onSubmitted: _displaySelectedMoves,
      onSelect: StyleHelper.randomColoredStyle(),
      onHover: StyleHelper.randomColoredStyle(),
    );
    checkbox.listening = true;
  }

  void _displaySelectedMoves(List<String> moves) {
    Terminal.writeLn('Moves selected:');
    for (final move in moves) {
      final style = StyleHelper.randomColoredStyle();
      Terminal.write(style.render(move));
      Terminal.write(' ');
    }
    Terminal.writeLn('\n That was my Demo! Press :q<Enter> to quit');
  }
}

void main() => PokemonTUI().start();
