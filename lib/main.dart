import 'package:flame_demo/game_pages/phase1/game_page1.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const MyHomePage());
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
    const Center(child: Text("Page 1", style: TextStyle(fontSize: 24))),
    GamePage1(),
    const Center(child: Text("Page 3", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Page 4", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Page 5", style: TextStyle(fontSize: 24))),
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
      body: Column(
        children: [
          // Navigation arrows at the top center
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed:
                      _currentPageIndex > 0
                          ? () => _navigateToPage(_currentPageIndex - 1)
                          : null,
                  icon: const Icon(Icons.arrow_back, size: 32),
                ),
                const SizedBox(width: 24), // Spacing between arrows
                IconButton(
                  onPressed:
                      _currentPageIndex < _pages.length - 1
                          ? () => _navigateToPage(_currentPageIndex + 1)
                          : null,
                  icon: const Icon(Icons.arrow_forward, size: 32),
                ),
              ],
            ),
          ),
          // Expanded PageView for the pages
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
