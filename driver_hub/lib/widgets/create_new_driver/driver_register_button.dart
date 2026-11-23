import 'package:flutter/material.dart';

class DriverRegisterButton extends StatelessWidget {
  final bool isRegistering;
  final VoidCallback onPressed;

  DriverRegisterButton({super.key, required this.isRegistering, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isRegistering ? null : onPressed,
        child: isRegistering
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(),
        )
            : const Text('Register Driver'),
      ),
    );
  }
}