import 'package:flutter/material.dart';

typedef CloasLoadingScreen = bool Function();
typedef UpdateLoadingScreen = bool Function(String text);

@immutable
class LoaindScreenController{
  final CloasLoadingScreen close;
  final UpdateLoadingScreen update;

  const LoaindScreenController({required this.close,required this.update});
}