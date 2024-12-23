import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_demo/game_pages/sound/bullet.dart';
import 'package:flame_demo/game_pages/sound/sound_game.dart';

class Player extends SpriteComponent
    with HasGameRef<SoundGame>, CollisionCallbacks {
  late final SpawnComponent _bulletSpawner;
  Player()
    : super(size: Vector2(113.5 / 2, 132 / 2), anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load player sprite
    sprite = await gameRef.loadSprite('rocketShip.png');

    position = Vector2(gameRef.size[0] / 2, gameRef.size[1] - 40);

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
