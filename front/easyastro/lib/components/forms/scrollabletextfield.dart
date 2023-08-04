import 'package:flutter/material.dart';

class ScrollableTextField extends StatefulWidget {
  final TextEditingController controller;

  const ScrollableTextField({super.key, required this.controller});

  @override
  State<ScrollableTextField> createState() => _ScrollableTextFieldState();
}

class _ScrollableTextFieldState extends State<ScrollableTextField> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: TextField(
        readOnly: true,
        controller: widget.controller,
        maxLines: 10,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
