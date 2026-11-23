import 'package:flutter/material.dart';

class NoDriversView extends StatelessWidget {
  final VoidCallback onAddDriver;

  NoDriversView({
    super.key,
    required this.onAddDriver,
  });

  Widget buildEmptyMessage() {
    return const Column(
      children: [
        Text('No drivers found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildAddButton() {
    return ElevatedButton.icon(
      onPressed: onAddDriver,
      icon: const Icon(Icons.add),
      label: const Text('Add New Driver'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              buildEmptyMessage(),
              buildAddButton(),
            ],
          ),
        ),
      ],
    );
  }
}