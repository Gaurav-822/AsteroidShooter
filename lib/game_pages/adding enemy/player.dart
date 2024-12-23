import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_demo/game_pages/adding%20enemy/enemy_game.dart';

class Player extends SpriteComponent
    with HasGameRef<EnemyGame>, CollisionCallbacks {
  Player()
    : super(size: Vector2(113.5 / 2, 132 / 2), anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load player sprite
    sprite = await gameRef.loadSprite('rocketShip.png');

    position = Vector2(gameRef.size[0] / 2, gameRef.size[1] - 40);
  }

  // Making the player move
  void move(Vector2 delta) {
    position.add(delta);
  }
}
