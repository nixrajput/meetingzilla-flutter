import 'package:flutter/material.dart';

const Color firstColor = Color(0xFF20BF55);
const Color secondColor = Color(0xFF01BAEF);
const Color accentColor = Color(0xFF3DB991);
const Color thirdColor = Color(0xFF6495ED);

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

MaterialColor materialAccentColor = MaterialColor(0xFF3DB991, accColor);
