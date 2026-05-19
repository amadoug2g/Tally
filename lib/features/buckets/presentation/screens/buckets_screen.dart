import 'package:flutter/material.dart';

class BucketsScreen extends StatelessWidget {
  const BucketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buckets')),
      body: const Center(
        child: Text('Configuration des buckets', style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}
