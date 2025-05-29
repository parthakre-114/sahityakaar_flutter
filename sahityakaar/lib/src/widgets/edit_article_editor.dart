import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';

/// EditArticleEditor is a specialized version of ExpandableEditor
/// for editing existing articles
class EditArticleEditor extends ConsumerStatefulWidget {
  final String initialContent;
  final String category;
  final Function(String) onSaved;
  final VoidCallback onClose;

  const EditArticleEditor({
    super.key,
    required this.initialContent,
    required this.category,
    required this.onSaved,
    required this.onClose,
  });

  @override
  ConsumerState<EditArticleEditor> createState() => _EditArticleEditorState();
}

class _EditArticleEditorState extends ConsumerState<EditArticleEditor>
    with SingleTickerProviderStateMixin {
  final _contentController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.initialContent;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write some content')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSaved(_contentController.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildEditor() {
    return Container(
      color: Colors.black.withOpacity(
        0.7,
      ), // Darker overlay for better contrast
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 30, 35, 35).withOpacity(0.6),
                  Colors.blue.shade900.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.teal.shade200.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.shade200.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                // Editor Header Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 54,
                  child: Row(
                    children: [
                      // Edit icon
                      Icon(Icons.edit_note, color: Colors.teal.shade200),
                      const SizedBox(width: 12),

                      // Category text
                      Text(
                        widget.category,
                        style: TextStyle(
                          color: Colors.teal.shade200,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),

                      // Save and close buttons
                      _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.tealAccent,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.save,
                                color: Colors.teal.shade200,
                              ),
                              onPressed: _handleSave,
                            ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.teal.shade200),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ),

                // Main Editor Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: 'Start writing...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintStyle: TextStyle(
                          color: Colors.teal.shade200.withOpacity(0.7),
                        ),
                      ),
                      maxLines: null,
                      autofocus: false,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors
                            .teal
                            .shade50, // Lighter text for better visibility
                        height: 1.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onClose();
        return false;
      },
      child: _buildEditor(),
    );
  }
}
