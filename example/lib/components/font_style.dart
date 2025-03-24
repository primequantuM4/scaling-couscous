enum FontStyle {
  Bold(1),
  Italic(3),
  Underline(4),
  Strikethrough(9);

  final int code;
  const FontStyle(this.code);
}
