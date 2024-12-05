import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FacePicture extends StatefulWidget{

  @override
  State<FacePicture> createState() => _FacePictureState();
}

class _FacePictureState extends State<FacePicture>{
  File? _image;
  final ImagePicker _picker = ImagePicker();
  
  Future<void> _takePicture() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context){
    return Container(
      child: _image == null
        ? ElevatedButton(
            onPressed: _takePicture,
            child: Icon(Icons.camera_alt),
          )
        : Image.file(
            _image!,
            fit: BoxFit.cover,
          ),
    );
  }
}