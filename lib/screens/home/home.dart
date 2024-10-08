import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesticides'),
        centerTitle: true,
        elevation: 1,
      ),
      body: const Column(
        children: [
          Center(
            child: Text("data"),
          )
        ],
      ),
    );
  }
}
