import 'package:flame/game.dart';
import 'package:flame_demo/game_pages/player%20control/player_game.dart';
import 'package:flutter/material.dart';

class GamePagePlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GameWidget(game: PlayerGame(context)));
  }
}
