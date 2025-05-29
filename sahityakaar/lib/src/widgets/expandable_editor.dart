import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';

// Providers for managing editor state
final editorExpandedProvider = StateProvider<bool>((ref) => false);
final editorContentProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'Poetry');

class ExpandableEditor extends ConsumerStatefulWidget {
  const ExpandableEditor({super.key});

  @override
  ConsumerState<ExpandableEditor> createState() => _ExpandableEditorState();
}

class _ExpandableEditorState extends ConsumerState<ExpandableEditor> {
  final _contentController = TextEditingController();
  bool _isExpanded = false;
  double _opacity = 0.1;
  String _selectedCategory = 'Poetry';

  @override
  void initState() {
    super.initState();
    _contentController.addListener(() {
      setState(() {
        _opacity = _contentController.text.isEmpty ? 0.1 : 0.9;
      });
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveArticle() async {
    if (_contentController.text.isEmpty) return;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Insert article into Supabase
      await Supabase.instance.client.from('articles').insert({
        'content': _contentController.text,
        'category': _selectedCategory,
        'author_id': user.id,
      });

      if (mounted) {
        setState(() {
          _isExpanded = false;
          _contentController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildEditor() {
    return BackdropFilter(
      // Applies gaussian blur effect when editor is expanded
      filter: _isExpanded
          ? ImageFilter.blur(sigmaX: 0, sigmaY: 0) // Adjust sigma values for desired blur
          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
      child: AnimatedContainer(
        // Smooth animation for height changes
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        // Dynamic height based on expansion state
        height: _isExpanded ? MediaQuery.of(context).size.height * 0.7 : 56,
        decoration: BoxDecoration(
          // Gradient background with dynamic opacity
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 42, 49, 49).withOpacity(_isExpanded ? 0.4 : 0.2),
              Colors.blue.shade100.withOpacity(_isExpanded ? 0.3 : 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.teal.shade200.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.shade200.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            // Editor Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 54,
              child: Row(
                children: [
                  // Edit icon
                  Icon(Icons.edit_note, color: Colors.teal.shade600),
                  const SizedBox(width: 12),
                  
                  // Conditional UI based on expansion state
                  if (!_isExpanded) ...[
                    // Collapsed state input field
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: "What's on your mind?",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.teal.shade400,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () => setState(() => _isExpanded = true),
                      ),
                    ),
                  ] else ...[
                    // Expanded state controls
                    // Category dropdown
                    DropdownButton<String>(
                      value: _selectedCategory,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.teal.shade600),
                      underline: Container(),
                      items: ['Poetry', 'Stories', 'Articles', 'Quotes']
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                    const Spacer(),
                    // Save and close buttons
                    IconButton(
                      icon: Icon(Icons.save, color: Colors.teal.shade600),
                      onPressed: _saveArticle,
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.teal.shade600),
                      onPressed: () {
                        setState(() {
                          _isExpanded = false;
                          _contentController.clear();
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Main Editor Area
            if (_isExpanded)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Start writing...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null, // Allows unlimited lines
                    autofocus: true, // Opens keyboard automatically
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.teal.shade900,
                      height: 1.8, // Line spacing
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildEditor();
  }
}
