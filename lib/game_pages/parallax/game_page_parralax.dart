import 'package:flame/game.dart';
import 'package:flame_demo/game_pages/parallax/parallax_game.dart';
import 'package:flutter/material.dart';

class GamePageParralax extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GameWidget(game: ParallaxGame(context)));
  }
}
