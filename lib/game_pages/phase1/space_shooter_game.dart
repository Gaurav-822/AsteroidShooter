import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class AstroidGame extends FlameGame with PanDetector, HasCollisionDetection {
  late BuildContext context; // Add this line to define context

  AstroidGame(this.context); // Modify the constructor to accept BuildContext
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

class Player extends SpriteComponent
    with HasGameRef<AstroidGame>, CollisionCallbacks {
  late final SpawnComponent _bulletSpawner;

  Player()
    : super(size: Vector2(113.5 / 2, 132 / 2), anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load player sprite
    sprite = await gameRef.loadSprite('rocketShip.png');

    position = Vector2(gameRef.size[0] / 2, gameRef.size[1] - 40);

    // Add hitbox to detect collisions
    add(RectangleHitbox());

    // Player's Bullet Spawner
    _bulletSpawner = SpawnComponent(
      period: .2,
      selfPositioning: true,
      factory: (index) {
        return Bullet(position: position + Vector2(0, -height / 2));
      },
      autoStart: false,
    );
    game.add(_bulletSpawner);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check if player is out of bounds (left, right, top, or bottom of the screen)
    if (position.x < 0 ||
        position.x > gameRef.size.x ||
        position.y > gameRef.size.y) {
      triggerExplosionAndEndGame();
    }
  }

  // Method to handle explosion and game end
  void triggerExplosionAndEndGame() {
    stopShooting();
    removeFromParent();
    gameRef.add(Explosion(position: position));
    gameRef.endGame(won: false);
  }

  // Making the player move
  void move(Vector2 delta) {
    position.add(delta);
  }

  // Making the player shoot bullets
  void startShooting() {
    _bulletSpawner.timer.start();
  }

  // Making the player stop shooting bullets
  void stopShooting() {
    _bulletSpawner.timer.stop();
  }
}

// Bullet Class
class Bullet extends SpriteAnimationComponent
    with HasGameReference<AstroidGame> {
  Bullet({super.position})
    : super(size: Vector2(25, 50), anchor: Anchor.bottomRight);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'bullet.png',
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: .1,
        textureSize: Vector2(4, 4),
      ),
    );

    // Add hitboxes
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += dt * -1500;

    if (position.y < -height) {
      removeFromParent();
    }
  }
}

// Enemy Class
class Enemy extends SpriteAnimationComponent
    with HasGameRef<AstroidGame>, CollisionCallbacks {
  Enemy({super.position})
    : super(size: Vector2.all(enemySize), anchor: Anchor.center);

  static const enemySize = 100.0;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet) {
      // Handle collision with Bullet (remove both and show explosion)
      removeFromParent();
      other.removeFromParent();
      game.add(Explosion(position: position));
    } else if (other is Player) {
      // Handle collision with Player (end the game)
      removeFromParent();
      other.stopShooting();
      other.removeFromParent();
      game.add(Explosion(position: position));
      game.endGame();
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Randomly select enemy sprite
    final random = Random();
    final assets = ['enemy1.png', 'enemy2.png', 'enemy3.png', 'enemy4.png'];
    final chosenAsset = assets[random.nextInt(assets.length)];

    // Load the sprite animation
    animation = await game.loadSpriteAnimation(
      chosenAsset,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: .2,
        textureSize: Vector2.all(100),
      ),
    );

    // Set a random angle between -15 and 15 degrees (converted to radians)
    final angleInDegrees =
        random.nextDouble() * 30 - 15; // Random value between -15 and 15
    angle = angleInDegrees * pi / 180; // Convert degrees to radians

    // Add hitboxes
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the enemy in the direction of its angle
    final velocity = Vector2(0, 500)..rotate(angle);
    position += velocity * dt;

    if (position.y > game.size.y ||
        position.x < 0 ||
        position.x > game.size.x) {
      removeFromParent();
    }
  }
}

class Explosion extends SpriteAnimationComponent
    with HasGameReference<AstroidGame> {
  Explosion({super.position})
    : super(
        size: Vector2.all(150),
        anchor: Anchor.center,
        removeOnFinish: true,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'explosion.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: .1,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );
  }
}
