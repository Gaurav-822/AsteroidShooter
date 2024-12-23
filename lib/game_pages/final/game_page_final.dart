import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame_demo/game_pages/final/astroid_game.dart';

class GamePageFinal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GameWidget(game: AstroidGame(context)));
  }
}
