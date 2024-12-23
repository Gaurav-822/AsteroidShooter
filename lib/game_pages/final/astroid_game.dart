import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_demo/game_pages/final/bullet.dart';
import 'package:flame_demo/game_pages/final/enemy.dart';
import 'package:flame_demo/game_pages/final/player.dart';
import 'package:flutter/material.dart';

class AstroidGame extends FlameGame with PanDetector, HasCollisionDetection {
  late BuildContext context;

  AstroidGame(this.context);
  late Player player;
  int secondsPassed = 0;
  double timePassed = 0.0;
  late SpawnComponent enemySpawner;
  bool isGameOver = false;
  late TextComponent gameOverText;

  Function? onGameOver;

  @override
  void update(double dt) {
    super.update(dt);

    // If game is over, stop updating and return
    if (isGameOver) return;

    timePassed += dt;
    if (timePassed >= 1.0) {
      secondsPassed++;
      timePassed = 0.0;

      // Stop the enemy spawner 10 seconds before the game ends
      if (secondsPassed >= 2 * 60 + 25) {
        enemySpawner.timer.stop();
      }

      // End the game after 30 seconds
      if (secondsPassed >= 2 * 60 + 35) {
        endGame(won: true);
      }

      // Adjust the enemy spawn period based on elapsed time if under 20 seconds
      if (secondsPassed < 2 * 60 + 25) {
        final spawnPeriod =
            1 / (1 + secondsPassed * 0.05); // Adjust difficulty factor
        enemySpawner.period = spawnPeriod;
      }
    }
  }

  void endGame({bool won = false}) async {
    isGameOver = true;
    stopBgmMusic();

    // Stop the enemy spawner timer
    enemySpawner.timer.stop();

    // To stop the timer on the game page
    if (onGameOver != null) {
      onGameOver!();
    }
  }

  void movePlayerOffScreen({bool won = true}) {
    final moveDuration = 2.5; // Duration for the player to move out of screen
    final startPosition = player.position.y;
    final endPosition = -player.height; // Move above the screen

    // Tween animation to move the player
    final moveAnimation = Tween<double>(begin: startPosition, end: endPosition);

    // Start a timer to perform the animation
    final startTime = DateTime.now();

    // Update method to animate the player's movement
    void animatePlayerPosition() {
      final elapsed =
          DateTime.now().difference(startTime).inMilliseconds / 1000;

      if (elapsed < moveDuration) {
        final newY = moveAnimation.transform(elapsed / moveDuration);
        player.position.y = newY;
        // Call this method again for the next frame
        Future.delayed(Duration(milliseconds: 16), animatePlayerPosition);
      } else {
        // Show Game Over text after the animation completes
        showGameOverScreen(won: won);
      }
    }

    // Start the animation
    animatePlayerPosition();
  }

  void showGameOverScreen({bool won = true}) {
    // Remove player, enemies, and bullets
    player.removeFromParent();

    for (var component in children.whereType<Enemy>()) {
      component.removeFromParent();
    }
    for (var component in children.whereType<Bullet>()) {
      component.removeFromParent();
    }

    // Show Game Over text
    gameOverText = TextComponent(
      text:
          won
              ? 'You won! \nThe OASIS is yours!'
              : 'Game Over.\n Your Score: $secondsPassed \n  Try again!',
      position: size / 2,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontFamily: "orbitron",
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(gameOverText);
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

    startBgmMusic();
  }

  void startBgmMusic() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('background_music.mp3');
  }

  void stopBgmMusic() {
    FlameAudio.bgm.stop();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!isGameOver) {
      player.move(info.delta.global);
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (!isGameOver) {
      player.startShooting();
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (!isGameOver) {
      player.stopShooting();
    }
  }

  @override
  void onRemove() {
    stopBgmMusic();
    super.onRemove();
  }
}
