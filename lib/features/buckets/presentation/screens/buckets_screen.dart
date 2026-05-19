import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class BucketsScreen extends StatelessWidget {
  const BucketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TallyColors.groupedBackground,
      appBar: AppBar(title: const Text('Buckets')),
      body: const Center(
        child: Text(
          'Configuration des buckets',
          style: TextStyle(color: TallyColors.secondaryLabel),
        ),
      ),
    );
  }
}
