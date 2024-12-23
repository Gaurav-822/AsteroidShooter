// Bullet Class
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_demo/game_pages/sound/sound_game.dart';

class Bullet extends SpriteAnimationComponent with HasGameReference<SoundGame> {
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
