import 'package:flame/game.dart';
import 'package:flame_demo/game_pages/sound/sound_game.dart';
import 'package:flutter/material.dart';

class GamePageSound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GameWidget(game: SoundGame(context)));
  }
}
