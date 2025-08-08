import 'package:flutter/material.dart';
import 'primary_button.dart';

class BottomFixedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? additionalContent;

  const BottomFixedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.additionalContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (additionalContent != null) ...[
                additionalContent!,
                const SizedBox(height: 16),
              ],
              PrimaryButton(
                text: text,
                onPressed: onPressed,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}