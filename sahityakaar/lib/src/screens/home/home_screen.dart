import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/expandable_editor.dart';

/// A stateful widget that consumes Riverpod providers for state management
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Controllers and State Management
  final _contentController = TextEditingController(); // Manages text input content
  bool _isExpanded = false; // Controls editor expansion state
  double _opacity = 0.1; // Controls background opacity
  String _selectedCategory = 'Poetry'; // Currently selected content category
  int _selectedIndex = 0; // Bottom navigation bar selection

  // Static data for grid items
  final List<GridItem> _gridItems = [
    GridItem(
      title: 'Poetry',
      subtitle: 'Express your emotions through verses',
      color: Colors.blue.withOpacity(0.3),
      icon: Icons.auto_stories,
    ),
    GridItem(
      title: 'Stories',
      subtitle: 'Share your tales with the world',
      color: Colors.green.withOpacity(0.3),
      icon: Icons.book,
    ),
    GridItem(
      title: 'Articles',
      subtitle: 'Write about what matters to you',
      color: Colors.orange.withOpacity(0.3),
      icon: Icons.article,
    ),
    GridItem(
      title: 'Quotes',
      subtitle: 'Inspire others with your words',
      color: Colors.purple.withOpacity(0.3),
      icon: Icons.format_quote,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Listener for text changes to update opacity
    _contentController.addListener(() {
      setState(() {
        _opacity = _contentController.text.isEmpty ? 0.1 : 0.9;
      });
    });
  }

  @override
  void dispose() {
    _contentController.dispose(); // Clean up controller when widget is disposed
    super.dispose();
  }

  /// Builds the expandable editor widget with backdrop blur
  
  /// Handles saving article to Supabase database
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sahityakaar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      // Main body with stack for layering
      body: Stack(
        children: [
          // Background grid with animation
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: ref.watch(editorExpandedProvider) ? 0.3 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const SizedBox(height: 76),
                  // Grid of category cards
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _gridItems.length,
                      itemBuilder: (context, index) => _buildGridItem(index),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating editor overlay
          const ExpandableEditor(),
        ],
      ),
      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  /// Builds a single grid item for the category grid
  Widget _buildGridItem(int index) {
    return Container(
      decoration: BoxDecoration(
        color: _gridItems[index].color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _gridItems[index].color.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _gridItems[index].icon,
            size: 48, // Larger icon
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(height: 16),
          Text(
            _gridItems[index].title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _gridItems[index].subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data model for grid items
class GridItem {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  GridItem({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}
