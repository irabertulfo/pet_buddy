import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoUploadWidget extends StatefulWidget {
  final void Function(String, File) onImageSelected;

  const PhotoUploadWidget({Key? key, required this.onImageSelected})
      : super(key: key);

  @override
  PhotoUploadWidgetState createState() => PhotoUploadWidgetState();
}

class PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  late ImagePicker _imagePicker;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
  }

  Future<void> _selectImage() async {
    final pickedImage = await showDialog<XFile>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an option'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Take a picture'),
                  onTap: () async {
                    Navigator.of(context).pop(await _imagePicker.pickImage(
                      source: ImageSource.camera,
                    ));
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  child: const Text('Select from gallery'),
                  onTap: () async {
                    Navigator.of(context).pop(await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                    ));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });

      widget.onImageSelected(pickedImage.path, _pickedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: _selectImage,
      child: CircleAvatar(
        radius: size.width / 2 * 0.25,
        backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
        child: _pickedImage == null
            ? const Icon(
                Icons.add_a_photo,
                color: Colors.white,
                size: 36,
              )
            : null,
      ),
    );
  }
}
