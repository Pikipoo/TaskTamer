import 'package:flutter/material.dart';

class CreaturesScreen extends StatelessWidget {
  const CreaturesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creatures')),
      body: const Center(child: Text('Your creatures will appear here.')),
    );
  }
}
