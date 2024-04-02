import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image"),), // You can customize the app bar as needed
      body: Center(
        child: Hero(
          tag: imageUrl, // Use the image URL as the hero tag
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
