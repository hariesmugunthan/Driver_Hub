import 'package:flutter/material.dart';

class VehicleRegisterButton extends StatelessWidget {
  final bool isRegistering;
  final VoidCallback onPressed;

  const VehicleRegisterButton({super.key, required this.isRegistering, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isRegistering ? null : onPressed,
        child: isRegistering
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Text('Register Vehicle'),
      ),
    );
  }
}