import 'package:flame/game.dart';
import 'package:flame_demo/game_pages/explosions/explosions_game.dart';
import 'package:flutter/material.dart';

class GamePageExplosions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GameWidget(game: ExplosionsGame(context)));
  }
}
