import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_demo/game_pages/adding%20enemy/enemy.dart';
import 'package:flame_demo/game_pages/adding%20enemy/player.dart';
import 'package:flutter/material.dart';

class EnemyGame extends FlameGame with PanDetector, HasCollisionDetection {
  late BuildContext context;

  EnemyGame(this.context);
  late Player player;
  late SpawnComponent enemySpawner;
  double timePassed = 0.0;
  int secondsPassed = 0;

  @override
  void update(double dt) {
    super.update(dt);

    timePassed += dt;
    if (timePassed >= 1.0) {
      secondsPassed++;
      timePassed = 0.0;

      // Stop the enemy spawner 10 seconds before the game ends
      if (secondsPassed >= 2 * 60 + 25) {
        enemySpawner.timer.stop();
      }

      // Adjust the enemy spawn period based on elapsed time if under 20 seconds
      if (secondsPassed < 2 * 60 + 25) {
        final spawnPeriod =
            1 / (1 + secondsPassed * 0.05); // Adjust difficulty factor
        enemySpawner.period = spawnPeriod;
      }
    }
  }

  @override
  Future<void> onLoad() async {
    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('stars_0.png'),
        ParallaxImageData('stars_1.png'),
        ParallaxImageData('stars_0.png'),
      ],
      baseVelocity: Vector2(0, -7),
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(0, 4),
    );
    add(parallax);

    player = Player();
    add(player);

    enemySpawner = SpawnComponent(
      factory: (index) => Enemy(),
      period: 1.0, // Initial period, will be updated in the update method
      area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize),
    );
    add(enemySpawner);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.global);
  }
}
