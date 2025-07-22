import 'package:flutter/material.dart';

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Planner'),
      ),
      body: const Center(
        child: Text('Project Planner Screen'),
      ),
    );
  }
}
