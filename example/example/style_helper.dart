import 'dart:math';

import 'package:example/components/colors.dart';
import 'package:example/components/text_component_style.dart';

final _backgroundColors = [
  ColorRGB(255, 99, 71),
  ColorRGB(255, 69, 0),
  ColorRGB(255, 140, 0),
  ColorRGB(70, 130, 180),
  ColorRGB(100, 149, 237),
  ColorRGB(0, 191, 255),
  ColorRGB(34, 139, 34),
  ColorRGB(60, 179, 113),
  ColorRGB(50, 205, 50),
  ColorRGB(255, 105, 180),
  ColorRGB(255, 182, 193),
  ColorRGB(219, 112, 147),
  ColorRGB(75, 0, 130),
  ColorRGB(138, 43, 226),
  ColorRGB(123, 104, 238)
];
final _random = Random();

class StyleHelper {
  static TextComponentStyle typeStyle(String type) {
    final commonStyling = TextComponentStyle()
        .foreground(ColorRGB(255, 255, 255))
        .paddingRight(2)
        .paddingLeft(2)
        .bold();

    switch (type.toLowerCase()) {
      case 'normal':
        return commonStyling
            .foreground(ColorRGB(255, 255, 255))
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

  static TextComponentStyle randomColoredStyle() {
    return TextComponentStyle()
        .foreground(ColorRGB(255, 255, 255))
        .background(
            _backgroundColors[_random.nextInt(_backgroundColors.length)])
        .paddingLeft(2)
        .paddingRight(2);
  }
}
