import 'package:flame_demo/game_pages/adding%20enemy/game_page_enemy.dart';
import 'package:flame_demo/game_pages/explosions/game_page_explosions.dart';
import 'package:flame_demo/game_pages/final/game_page_final.dart';
import 'package:flame_demo/game_pages/parallax/game_page_parralax.dart';
import 'package:flame_demo/game_pages/player%20control/game_page_player.dart';
import 'package:flame_demo/game_pages/sound/game_page_sound.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    GamePageParralax(),
    GamePagePlayer(),
    GamePageEnemy(),
    GamePageExplosions(),
    GamePageSound(),
    GamePageParralax(),
    GamePageFinal(),
  ];

  final List<String> _pageTitles = [
    "Parallax",
    "Player Control",
    "Enemy",
    "Explosions",
    "Sound",
    "Finally,",
    "The one You all saw in the Tecno's App",
  ];

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween, // This spreads the items apart
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: IconButton(
                    onPressed:
                        _currentPageIndex > 0
                            ? () => _navigateToPage(_currentPageIndex - 1)
                            : null,
                    icon: Icon(Icons.arrow_back_ios, size: 48),
                  ),
                ),
                const SizedBox(width: 24), // Space between the title and arrows
                Text(
                  _pageTitles[_currentPageIndex],
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 24), // Space between the title and arrows
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    onPressed:
                        _currentPageIndex < _pages.length - 1
                            ? () => _navigateToPage(_currentPageIndex + 1)
                            : null,
                    icon: const Icon(Icons.arrow_forward_ios, size: 48),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 16, // Added 16px padding from the left side
            child: IconButton(
              onPressed:
                  _currentPageIndex > 0
                      ? () => _navigateToPage(_currentPageIndex - 1)
                      : null,
              icon: const Icon(Icons.arrow_back_ios, size: 48),
            ),
          ),
          Positioned(
            top: 40,
            right: 16, // Added 16px padding from the right side
            child: IconButton(
              onPressed:
                  _currentPageIndex < _pages.length - 1
                      ? () => _navigateToPage(_currentPageIndex + 1)
                      : null,
              icon: const Icon(Icons.arrow_forward_ios, size: 48),
            ),
          ),
        ],
      ),
    );
  }
}
