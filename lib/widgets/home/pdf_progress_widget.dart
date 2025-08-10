import 'package:flutter/material.dart';

class PdfProgressWidget extends StatelessWidget {
  final double progress;

  const PdfProgressWidget({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(value: progress),
          const SizedBox(height: 16),
          Text('Generating PDF: ${(progress * 100).toInt()}%'),
        ],
      ),
    );
  }
}
