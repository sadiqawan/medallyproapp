import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/mycolors.dart';

class PickImage extends StatefulWidget {
  final ValueChanged<File> onImagePicked;
  const PickImage({super.key, required this.onImagePicked});

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {


  File? _image;

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        widget.onImagePicked(_image!);
      });
    }
  }



  Future<void> _showImagePickerDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  // Permission Handler
  Future<void> openGallery() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    switch (cameraStatus) {
      case PermissionStatus.granted:
        _showImagePickerDialog();
        _showSnackBar("Permission Granted");
        break;
      case PermissionStatus.denied:
        _showSnackBar("You Need To Provide Camera Permission.");
        break;
      case PermissionStatus.permanentlyDenied:
        _handlePermanentlyDenied();
        break;
      default:
        break;
    }
  }


  // Function to show a snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  // Function to handle permanently denied permission
  void _handlePermanentlyDenied() {
    // Show a dialog to open app settings when permission is permanently denied
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Permission Required"),
          content: const Text("You have permanently denied camera permission. "
              "Please go to app settings and enable the permission."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text("Open Settings"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 3.0),
          child: const Text(
            "Add Image",
            style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
                fontFamily: 'GT Walsheim Trial',
                color: textBlackColor,
                letterSpacing: 0.3),
          ),
        ),
        GestureDetector(
          onTap: (){
            openGallery();
          },
          child: Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                color: containerBorderColor.withOpacity(0.2),
                border: Border.all(color: containerBorderColor)
            ),
            child: _image != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Image.file(_image!, fit: BoxFit.cover, width: 120, height: 120,),)
                :  Text(
              "Upload\nImage",
              style: TextStyle(
                color: textBlackColor.withOpacity(0.3),
                fontFamily: 'GT Walsheim Trial',
                fontSize: 8.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
