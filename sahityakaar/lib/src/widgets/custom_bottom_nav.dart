import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global provider for managing bottom navigation state
/// Uses Riverpod StateProvider to maintain selected tab index across the app
/// Default value is 0 (Home tab)
final bottomNavProvider = StateProvider<int>((ref) => 0);

/// CustomBottomNav is a reusable bottom navigation bar widget.
/// It provides navigation between main app sections:
/// - Home: Main feed and categories
/// - Explore: Discover content
/// - Create: Quick access to content creation
/// - Favorites: Saved/liked content
class CustomBottomNav extends ConsumerWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavProvider);

    // Handle navigation based on index
    void onItemTapped(int index) {
      ref.read(bottomNavProvider.notifier).state = index;

      // Handle navigation based on selected item
      switch (index) {
        case 0: // Home
          Navigator.pushReplacementNamed(context, '/');
          break;
        case 1: // Explore
          // Add navigation for explore
          break;
        case 2: // Create
          // Add navigation for create
          break;
        case 3: // Favorites
          // Add navigation for favorites
          break;
      }
    }

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
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
    );
  }
}
