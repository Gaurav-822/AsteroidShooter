// Enemy Class
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_demo/game_pages/adding%20enemy/enemy_game.dart';

class Enemy extends SpriteAnimationComponent
    with HasGameRef<EnemyGame>, CollisionCallbacks {
  Enemy({super.position})
    : super(size: Vector2.all(enemySize), anchor: Anchor.center);

  static const enemySize = 100.0;

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
