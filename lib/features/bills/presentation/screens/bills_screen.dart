import 'package:flutter/material.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      body: const Center(
        child: Text('Charges fixes du mois', style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}
