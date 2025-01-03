import 'package:flame/components.dart';
import 'package:flame_demo/game_pages/explosions/explosions_game.dart';

class Explosion extends SpriteAnimationComponent
    with HasGameReference<ExplosionsGame> {
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
