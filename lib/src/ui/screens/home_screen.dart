import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final int totalXp;
  const HomeScreen({Key? key, this.totalXp = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          Text('Total XP: $totalXp', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 32),
          const Text('Welcome to Life Quest!'),
        ],
      ),
    );
  }
}
