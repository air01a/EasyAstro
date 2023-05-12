import 'package:flutter/material.dart';

class ImageWithButton extends StatefulWidget {
  @override
  _ImageWithButtonState createState() => _ImageWithButtonState();
}

class _ImageWithButtonState extends State<ImageWithButton> {
  bool _isButtonVisible = false;

  void _toggleButtonVisibility() {
    setState(() {
      _isButtonVisible = !_isButtonVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleButtonVisibility,
      child: Stack(
        children: [
          Image.asset('assets/images/image.png'), // Remplacez par le chemin de votre image
          if (_isButtonVisible)
            Positioned(
              top: 50,
              left: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Action à effectuer lors du clic sur le bouton
                  print('Bouton cliqué!');
                },
                child: Text('Bouton'),
              ),
            ),
        ],
      ),
    );
  }
}
