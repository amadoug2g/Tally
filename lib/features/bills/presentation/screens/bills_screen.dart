import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TallyColors.groupedBackground,
      appBar: AppBar(title: const Text('Bills')),
      body: const Center(
        child: Text(
          'Charges fixes du mois',
          style: TextStyle(color: TallyColors.secondaryLabel),
        ),
      ),
    );
  }
}
