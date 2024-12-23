import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_demo/game_pages/final/bullet.dart';
import 'package:flame_demo/game_pages/final/explosion.dart';
import 'package:flame_demo/game_pages/final/astroid_game.dart';

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
