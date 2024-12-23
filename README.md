
# AsteroidShooter - Tutorial

## Overview

**AsteroidShooter** is a Flutter game built using the Flame engine. The game challenges players to control a spaceship, avoid enemies, and shoot to survive. As the game progresses, enemies spawn faster, and the gameplay becomes more challenging.

This tutorial walks you through the process of building **AstroidGame** step by step. By the end, you'll have a complete game that integrates shooting mechanics, dynamic enemy spawning, and animations.

---

## Step 1: Setting Up the Environment

### Prerequisites

* Flutter installed on your system. ([Install Flutter](https://flutter.dev/docs/get-started/install))
* Basic understanding of Dart and Flutter.
* Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flame: ^1.2.0
  flame_audio: ^1.2.0
  flutter:
    sdk: flutter
```

### Installing Dependencies

Run the following command to install the dependencies:

```bash
flutter pub get
```

---

## Step 2: Creating the Game Class

The core of the game is the `AstroidGame` class, which extends `FlameGame`. This class handles the main game loop, updating the game state, and responding to player input.

### Code Snippet

```dart
class AstroidGame extends FlameGame with PanDetector, HasCollisionDetection {
  late Player player;
  late SpawnComponent enemySpawner;
  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    // Load background
    final parallax = await loadParallaxComponent([
      ParallaxImageData('stars_0.png'),
      ParallaxImageData('stars_1.png'),
    ],
      baseVelocity: Vector2(0, -7),
      repeat: ImageRepeat.repeat,
    );
    add(parallax);

    // Add player
    player = Player();
    add(player);

    // Enemy spawner
    enemySpawner = SpawnComponent(
      factory: (index) => Enemy(),
      period: 1.0,
      area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize),
    );
    add(enemySpawner);

    startBgmMusic();
  }

  void startBgmMusic() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('background_music.mp3');
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!isGameOver) {
      player.move(info.delta.global);
    }
  }
}
```

### Explanation

* **`FlameGame`:** The base class for building games with Flame.
* **`PanDetector`:** Captures drag events to move the player.
* **Parallax Background:** Adds a scrolling starry background for the space theme.

---

## Step 3: Adding the Player

The `Player` class represents the spaceship controlled by the user. It can move and shoot bullets.

### Code Snippet

```dart
class Player extends SpriteComponent {
  late final SpawnComponent _bulletSpawner;

  Player()
      : super(
          size: Vector2(113.5 / 2, 132 / 2),
          anchor: Anchor.bottomCenter,
        );

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('rocketShip.png');
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - 40);

    // Add hitbox for collision detection
    add(RectangleHitbox());

    // Bullet spawner
    _bulletSpawner = SpawnComponent(
      period: 0.2,
      selfPositioning: true,
      factory: (index) => Bullet(position: position - Vector2(0, height / 2)),
      autoStart: false,
    );
    game.add(_bulletSpawner);
  }

  void move(Vector2 delta) {
    position.add(delta);
  }

  void startShooting() {
    _bulletSpawner.timer.start();
  }

  void stopShooting() {
    _bulletSpawner.timer.stop();
  }
}
```

### Explanation

* **Positioning:** The player starts at the bottom center of the screen.
* **Hitbox:** Added for collision detection.
* **Shooting:** Uses a `SpawnComponent` to periodically create bullets.

---

## Step 4: Adding Bullets

The `Bullet` class handles the logic for bullets fired by the player.

### Code Snippet

```dart
class Bullet extends SpriteComponent {
  Bullet({super.position}) : super(size: Vector2(25, 50), anchor: Anchor.bottomRight);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('bullet.png');
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    position.y -= dt * 500; // Move bullet upwards
    if (position.y < -height) {
      removeFromParent();
    }
  }
}
```

### Explanation

* **CollisionType.passive:** Allows the bullet to interact with enemies.
* **Movement:** Bullets move upwards and are removed when off-screen.

---

## Step 5: Adding Enemies

The `Enemy` class spawns enemies at random positions and moves them toward the player.

### Code Snippet

```dart
class Enemy extends SpriteComponent {
  Enemy({super.position}) : super(size: Vector2.all(100), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('enemy.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    position.y += dt * 100; // Move enemy downwards
    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet || other is Player) {
      removeFromParent();
      other.removeFromParent();
      gameRef.add(Explosion(position: position));
    }
  }
}
```

### Explanation

* **Movement:** Enemies move down the screen.
* **Collision Handling:** Enemies are removed upon collision with bullets or the player, triggering an explosion.

---

## Step 6: Adding Explosions

The `Explosion` class animates the explosion effect when an enemy or the player is destroyed.

### Code Snippet

```dart
class Explosion extends SpriteAnimationComponent {
  Explosion({super.position}) : super(size: Vector2.all(150), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    animation = await gameRef.loadSpriteAnimation(
      'explosion.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.1,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );
  }
}
```

### Explanation

* **Animation:** Displays a sequence of explosion sprites.
* **Remove on Finish:** Automatically removes itself after the animation completes.

---

## Putting It All Together

Combine the components by creating an instance of `AstroidGame` in your main app and running it in a `GameWidget`:

### Code Snippet

```dart
void main() {
  runApp(GameWidget(game: AstroidGame()));
}
```

---

## Conclusion

You now have a working space shooter game! Customize the game further by:

* Adding power-ups.
* Introducing more enemy types.
* Implementing a scoring system.

Enjoy building games with Flame!
