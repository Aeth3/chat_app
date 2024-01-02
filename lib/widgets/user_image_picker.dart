import 'dart:io';


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker(
      {super.key, required this.onPickedImage, required this.isPostImage});

  final void Function(File? selectedImage) onPickedImage;
  final bool isPostImage;

  @override
  State<UserImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<UserImagePicker> {
  File? _pickImageFile;
  bool isPickImage = false;

  
  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: widget.isPostImage ? 100 : 50,
        maxWidth: widget.isPostImage ? 1000 : 150);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      isPickImage = true;
      _pickImageFile = File(pickedImage.path);
    });
    widget.onPickedImage(_pickImageFile);
  }

  void _selectImage() async {
    final selectedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: widget.isPostImage ? 100 : 50,
        maxWidth: widget.isPostImage ? 1000 : 150);
    if (selectedImage == null) {
      return;
    }

    setState(() {
      _pickImageFile = File(selectedImage.path);
    });
    widget.onPickedImage(_pickImageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickImageFile != null ? FileImage(_pickImageFile!) : null,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera),
              label: Text(
                'Take a picture',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              )),
          Expanded(
            child: TextButton.icon(
                onPressed: _selectImage,
                icon: const Icon(Icons.photo),
                label: Text(
                  'Select from gallery',
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                )),
          ),
        ]),
      ],
    );
  }
}
