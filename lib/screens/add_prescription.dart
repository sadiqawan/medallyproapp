import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medallyproapp/constants/mycolors.dart';
import 'package:medallyproapp/providers/member_provider_addprescription.dart';
import 'package:medallyproapp/screens/medicine_screen.dart';
import 'package:medallyproapp/screens/prescription_list.dart';
import 'package:medallyproapp/widgets/custom_button.dart';
import 'package:medallyproapp/widgets/my_textformfield.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../model/members_model_class.dart';

class AddPrescriptionScreen extends StatefulWidget {
  const AddPrescriptionScreen({super.key});

  @override
  State<AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  TextEditingController drNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedItem;
  String? selectedRelation;
  File? _image;
  String? name;
  String? relation;

  // TODO Dropdown List
  List<String> items = [
    'Sandeep (brother)',
    'Shaila (mother)',
    "Shaki (self)",
    'Zain (father)',
  ];

  // TODO Get Image
  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // TODO Image Picker
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

  // TODO Permission Handler
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

  // TODO Function to show a snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  // TODO Function to handle permanently denied permission
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

  // TODO Validator
  formValidation() {
    if (_formKey.currentState!.validate() && _image != null) {
      if (selectedItem != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MedicineScreen(
              doctorName: drNameController.text.toString(),
              selectedImage: _image,
              member: selectedItem,
            ),
          ),
        );
      } else {
        print("Please add Image, Dr Name and select member");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please add Image, Dr Name and select member"),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final memberProvider = Provider.of<MemberProvider>(context);
    memberProvider.fetchMembers();
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrescriptionListScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.arrow_back,
              color: textColor,
            ),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(left: 80.0, top: 30.0),
          child: Text(
            "Add",
            style: TextStyle(
              fontSize: 20.0,
              color: textColor,
              fontFamily: 'GT Walsheim Trial',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height,
          width: width,
          margin: const EdgeInsets.only(top: 30.0),
          decoration: const BoxDecoration(
            color: textColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Gap(70),
                Stack(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.0),
                          color: containerBorderColor.withOpacity(0.2),
                          border: Border.all(color: containerBorderColor)),
                      child: _image != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        ),
                      )
                          : Text(
                        "Upload\nPrescription\nImage",
                        style: TextStyle(
                          color: textBlackColor.withOpacity(0.3),
                          fontFamily: 'GT Walsheim Trial',
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        openGallery();
                      },
                      child: Container(
                        height: 40.0,
                        width: 40.0,
                        margin: const EdgeInsets.only(top: 100, left: 43),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.0),
                          color: primaryColor,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: MyTextFormField(
                    controller: drNameController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Pleae Enter Doctor Name';
                      }
                      return null;
                    },
                    hintText: "Dr Sunil Park",
                    labelText: "Dr. Name",
                    enabledBorderColor: containerBorderColor,
                    focusedBorderColor: primaryColor,
                  ),
                ),
                const Gap(30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (memberProvider.members.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('No Members Available'),
                                content: const Text('Please add a member first.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: DropdownButton(
                        isExpanded: true,
                        value: selectedItem,
                        hint: const Text(
                          'Select Member',
                          style: TextStyle(color: Colors.grey),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down_sharp,
                          color: Colors.grey,
                        ),
                        items: memberProvider.members.map<DropdownMenuItem<String>>((Member member) {
                          return DropdownMenuItem<String>(
                            value: "${member.name} (${member.relation})",
                            child: Text(
                              "${member.name.toString()} (${member.relation.toString()})",
                              style: const TextStyle(color: textBlackColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            print("NewValue is $newValue");
                            selectedItem = newValue;
                            // selectedRelation = memberRelation;
                          });
                        },
                      ),
                    ),

                  ),
                ),
                const Gap(30),
                // GestureDetector(
                //   onTap: (){
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const MedicineScreen(),
                //       ),
                //     );
                //   },
                //   child: Container(
                //     alignment: Alignment.topRight,
                //     margin: const EdgeInsets.only(right: 35.0),
                //     child: const Text(
                //       "Add New",
                //       style: TextStyle(
                //           fontSize: 16.0,
                //           fontWeight: FontWeight.w700,
                //           fontFamily: 'GT Walsheim Trial',
                //           color: textBlackColor,
                //           letterSpacing: 0.3),
                //     ),
                //   ),
                // ),
                const Gap(30),
                GestureDetector(
                  onTap: () {
                    formValidation();
                  },
                  child: CustomButton(
                    text: "Add Medicine",
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
