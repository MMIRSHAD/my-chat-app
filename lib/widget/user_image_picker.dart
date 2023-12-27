import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserImage extends StatefulWidget {
  const UserImage({super.key, required this.onpickedImage});
  final void Function(File pickImage) onpickedImage;
  @override
  State<UserImage> createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  File? pickedImageFile;
  File? pickedImageGallaryFile;

  void pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      pickedImageFile = File(pickedImage.path);
    });
    widget.onpickedImage(pickedImageFile!);
  }

  void pickImageFromGallery() async {
    final pickedImaGallary =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImaGallary == null) {
      return;
    }
    setState(() {
      pickedImageGallaryFile = File(pickedImaGallary.path);
    });
    widget.onpickedImage(pickedImageGallaryFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey,
          foregroundImage: pickedImageFile != null
              ? FileImage(pickedImageFile!)
              : pickedImageGallaryFile != null
                  ? FileImage(pickedImageGallaryFile!)
                  : null,
          radius: 40,
        ),
        Row(
          children: [
            TextButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.camera),
                label: Text(
                  'Add Image',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                )),
            TextButton.icon(
                onPressed: pickImageFromGallery,
                icon: const Icon(Icons.image),
                label: Text(
                  'Add Image',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ))
          ],
        )
      ],
    );
  }
}
