import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double imageSize;
  final double nameFontSize;

  const ProfilePicture({
    super.key,
    this.imageUrl = "",
    this.name = "",
    this.imageSize = 100.0,
    this.nameFontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          name,
          style: TextStyle(fontSize: nameFontSize, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
