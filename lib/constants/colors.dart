import 'package:flutter/material.dart';

const Color firstColor = Color(0xFF20BF55);
const Color secondColor = Color(0xFF01BAEF);
const Color accentColor = Color(0xFF3DB991);
const Color thirdColor = Color(0xFF6495ED);
const Color lightBackgroundColor = Color(0xFFFAFAFA);
const Color darkBottomBarColor = Color(0xFF242424);
Color shadowColor = Color(0xFF000000).withOpacity(0.2);

Map<int, Color> accColor = {
  50: Color.fromRGBO(60, 185, 145, .1),
  100: Color.fromRGBO(60, 185, 145, .2),
  200: Color.fromRGBO(60, 185, 145, .3),
  300: Color.fromRGBO(60, 185, 145, .4),
  400: Color.fromRGBO(60, 185, 145, .5),
  500: Color.fromRGBO(60, 185, 145, .6),
  600: Color.fromRGBO(60, 185, 145, .7),
  700: Color.fromRGBO(60, 185, 145, .8),
  800: Color.fromRGBO(60, 185, 145, .9),
  900: Color.fromRGBO(60, 185, 145, 1),
};

Map<int, Color> dark = {
  50: Color.fromRGBO(18, 18, 18, .1),
  100: Color.fromRGBO(18, 18, 18, .2),
  200: Color.fromRGBO(18, 18, 18, .3),
  300: Color.fromRGBO(18, 18, 18, .4),
  400: Color.fromRGBO(18, 18, 18, .5),
  500: Color.fromRGBO(18, 18, 18, .6),
  600: Color.fromRGBO(18, 18, 18, .7),
  700: Color.fromRGBO(18, 18, 18, .8),
  800: Color.fromRGBO(18, 18, 18, .9),
  900: Color.fromRGBO(18, 18, 18, 1),
};

MaterialColor materialAccentColor = MaterialColor(0xFF3DB991, accColor);

MaterialColor materialDarkColor = MaterialColor(0xFF121212, dark);
