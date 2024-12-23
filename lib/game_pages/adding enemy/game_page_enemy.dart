import 'package:flame/game.dart';
import 'package:flame_demo/game_pages/adding%20enemy/enemy_game.dart';
import 'package:flutter/material.dart';

class GamePageEnemy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GameWidget(game: EnemyGame(context)));
  }
}
