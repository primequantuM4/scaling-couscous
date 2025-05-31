import 'package:example/components/colors.dart';
import 'package:example/components/text_component.dart';
import 'package:example/components/text_component_style.dart';
import 'package:example/components/text_field_component.dart';
import 'package:example/core/app.dart';
import 'package:example/core/row.dart';

void main() async {
  final tf1 = TextfieldComponent(placeHolder: "Name");
  final tf2 = TextfieldComponent(placeHolder: "Email");
  final tf3 = TextfieldComponent(placeHolder: "Password");

  App(children: [
    tf1,
    tf2,
    tf3,
    Row(
      children: [
        TextComponent(
          'Water',
          style: TextComponentStyle()
              .foreground(ColorRGB(255, 255, 255))
              .paddingTop(2)
              .paddingLeft(2)
              .paddingRight(2)
              .paddingBottom(2)
              .italic()
              .background(ColorRGB(51, 153, 255)),
        ),
        TextComponent(
          '',
          style: TextComponentStyle(),
        ),
        TextComponent(
          'Fire',
          style: TextComponentStyle()
              .foreground(ColorRGB(255, 255, 255))
              .paddingTop(2)
              .paddingLeft(2)
              .paddingRight(2)
              .paddingBottom(2)
              .background(ColorRGB(255, 68, 34)),
        ),
        TextComponent(
          'Ice',
          style: TextComponentStyle()
              .foreground(ColorRGB(255, 255, 255))
              .paddingTop(2)
              .paddingLeft(2)
              .paddingRight(2)
              .paddingBottom(2)
              .italic()
              .background(ColorRGB(102, 204, 255)),
        ),
        TextComponent(
          '',
          style: TextComponentStyle(),
        ),
        TextComponent(
          'Ghost',
          style: TextComponentStyle()
              .foreground(ColorRGB(255, 255, 255))
              .paddingTop(2)
              .paddingLeft(2)
              .paddingRight(2)
              .paddingBottom(2)
              .underline()
              .background(ColorRGB(102, 102, 182)),
        )
      ],
    ),
  ]).run();
}
