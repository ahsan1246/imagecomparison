import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final Function()? onPressed;
  final bool isLoading;
  final String btnTxt;
  const CustomButton({required this.btnTxt, this.isLoading = false, this.onPressed, super.key});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isLoading)
            const SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
          if (widget.isLoading) const SizedBox(width: 20),
          Text(widget.btnTxt),
        ],
      ),
    );
  }
}
