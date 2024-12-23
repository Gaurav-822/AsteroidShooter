import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame_demo/game_pages/phase1/space_shooter_game.dart';

class GamePage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GameWidget(game: AstroidGame(context)));
  }
}
