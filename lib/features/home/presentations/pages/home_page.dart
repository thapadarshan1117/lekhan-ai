import 'package:flutter/material.dart';

/// Main Application Entry Point
/// 
/// This screen simply redirects to Projects page since we're using
/// a standalone linear navigation: Projects → Books → Chapters
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simply navigate to projects and show them
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
