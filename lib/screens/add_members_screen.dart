import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gap/gap.dart';
import 'package:medallyproapp/screens/members_list.dart';
import 'package:random_string/random_string.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../constants/mycolors.dart';
import '../widgets/gender_selection.dart';
import '../widgets/my_textformfield.dart';
import '../widgets/pick_image.dart';

class AddMembersScreen extends StatefulWidget {
  const AddMembersScreen({super.key});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController dateOfBirth = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var connectivityResult = ConnectivityResult.none;
  String selectedGender = 'male';
  File? selectedImage;
  DateTime? _selectedDate;
  String selectedItem = 'Brother';

  // TODO RELATIONSHIPS LIST
  List<String> relations = [
    'Brother',
    'Sister',
    'Mother',
    'Father',
    'Grandfather',
    'Grandmother',
    'Friends',
    'Spouse',
    'Husband',
  ];


  // TODO CHECK INTERNET CONNECTIVITY
  Future<void> checkInternetAndProceed(context) async {
    var result = await Connectivity().checkConnectivity();
    setState(() {
      connectivityResult = result;
    });

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection, handle the error (throw an exception or show an alert)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
              'Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      addMembersToFirebase(context);
    }
  }


  // TODO COMPRESS IMAGE
  Future<File> compressImage(File imageFile) async {
    try {
      final tempDir = await path_provider.getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      var result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 20,
      );

      if (result != null) {
        return File(result.path);
      } else {
        throw Exception("Image compression failed: Result is null");
      }
    } catch (error) {
      if (error is CompressError) {
        throw Exception("Image compression error: ${error.message}");
      } else {
        throw Exception("Image compression error: $error");
      }
    }
  }


  // TODO ADD MEMBER TO FIREBASE
  addMembersToFirebase(BuildContext context) async {
    if (_formKey.currentState!.validate() && selectedImage != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                  ),
                  SizedBox(
                    width: 25.0,
                  ),
                  Text("Loading, Please wait"),
                ],
              ),
            ),
          );
        },
      );

      try {
        File compressedFrontImage = await compressImage(selectedImage!);
        Reference firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child("UserImages")
            .child("${randomAlphaNumeric(9)}.jpg");
        final UploadTask task = firebaseStorageRef.putFile(compressedFrontImage);

        await task.whenComplete(() async {
          var downloadURL = await firebaseStorageRef.getDownloadURL();
          print("this is url $downloadURL");

          await FirebaseFirestore.instance
              .collection("membersList")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection("members")
              .add({
            "userId": user?.uid,
            "name": nameController.text.trim(),
            "phoneNumber": phoneNumberController.text.trim(),
            "gender": selectedGender,
            "image": downloadURL,
            "relation": selectedItem,
            'dateOfBirth': _selectedDate
          });

          // Clearing variables
          setState(() {
            nameController.clear();
            phoneNumberController.clear();
            dateOfBirth.clear();
            selectedGender = 'male';
            selectedImage = null;
            selectedItem = 'Brother';
          });
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MembersListScreen()),
                  (route) => false,
            );
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Added Successfully",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          );
        });
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              e.toString(),
              style: const TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ),
        );
        if (kDebugMode) {
          print(e.toString());
        }
      } finally {
        Navigator.of(context).pop(); // Dismiss the dialog
      }
    }
    else {
      // Show toast/snackbar if any required field is missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Please fill all the required fields and select an image.",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ),
      );
    }
  }




  // TODO SELECTED COUNTRY
  Country selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "India",
    displayName: "India",
    displayNameNoCountryCode: "IN",
    e164Key: "",
  );


  // TODO SELECT DATE
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dateOfBirth.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: textColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MembersListScreen()
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: textColor,
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(left: 50.0),
          child: Text(
            "Add New Member",
            style: TextStyle(
              fontSize: 20.0,
              color: textColor,
              fontFamily: 'GT Walsheim Trial',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Gap(50.0),
                  MyTextFormField(
                    controller: nameController,
                    readOnly: false,
                    hintText: "Name",
                    labelText: "Enter your name",
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    enabledBorderColor: containerBorderColor,
                    focusedBorderColor: containerBorderColor,
                  ),
                  const Gap(15.0),
                  TextFormField(
                    cursorColor: primaryColor,
                    controller: phoneNumberController,
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: textBlackColor,
                      fontWeight: FontWeight.w400,
                    ),
                    validator: (String? value){
                      if(value == null || value.isEmpty){
                        return 'Please enter phone number';
                      }else if(value.length > 10){
                        return 'Number length is not correct should be 10';
                      } return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        phoneNumberController.text = value;
                      });
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: "  Phone Number",
                      labelText: 'Enter Phone Number',
                      hintStyle: const TextStyle(
                        color: textBlackColor,
                      ),
                      labelStyle: TextStyle(
                        color: textBlackColor.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        borderSide:
                        const BorderSide(color: containerBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        borderSide:
                        const BorderSide(color: containerBorderColor),
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.only(
                            top: 13.5, left: 10.0, right: 5.0),
                        // Add right padding
                        child: InkWell(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              countryListTheme:
                              const CountryListThemeData(
                                bottomSheetHeight: 500,
                              ),
                              onSelect: (value) {
                                setState(() {
                                  selectedCountry = value;
                                });
                              },
                            );
                          },
                          child: Text(
                            "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      suffixIcon: phoneNumberController.text.length > 9
                          ? Container(
                        height: 30,
                        width: 30,
                        margin: const EdgeInsets.all(10.0),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: const Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                          : null,
                    ),
                  ),
                  const Gap(15.0),
                  MyTextFormField(
                    controller: dateOfBirth,
                    readOnly: true,
                    labelText: "Date of Birth",
                    hintText: "Select Date of Birth",
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please add your date of birth';
                      }
                      return null;
                    },
                    enabledBorderColor: containerBorderColor,
                    focusedBorderColor: containerBorderColor,
                    suffixIcon: IconButton(
                      onPressed: () {
                        _selectDate(context);
                      },
                      icon: const Icon(
                        Icons.calendar_month,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const Gap(15.0),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(left: 3.0),
                    child: const Text(
                      "Select Gender",
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GT Walsheim Trial',
                        color: textBlackColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const Gap(15.0),
                  SimpleGenderSelection(
                    selectedGender: selectedGender,
                    onGenderChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  const Gap(15.0),
                  PickImage(
                    onImagePicked: (File image) {
                      setState(() {
                        selectedImage = image;
                      });
                    },
                  ),
                  const Gap(15.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton(
                      isExpanded: true,
                      value: selectedItem,
                      hint: const Text(
                        'Relation',
                        style: TextStyle(color: Colors.grey),
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down_sharp,
                        color: Colors.grey,
                      ),
                      items: relations.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedItem = newValue!;
                        });
                      },
                    ),
                  ),
                  const Gap(30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MembersListScreen()));
                        },
                        child: Container(
                          height: 40,
                          width: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: deleteButtonColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Text(
                            "CANCEL",
                            style: TextStyle(
                              fontSize: 15.0,
                              color: deleteButtonColor,
                              fontFamily: 'GT Walsheim Trial',
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          checkInternetAndProceed(context);
                          // Member newMember = Member(
                          //   name: nameController.text,
                          //   phoneNumber: phoneNumberController.text,
                          //   age: int.tryParse(ageController.text.toString())!,
                          //   gender: selectedGender,
                          //   image: selectedImage,
                          //   relation: selectedItem ?? 'Unknown',
                          // );
                          // setState(() {
                          //   memberList.add(newMember);
                          //   nameController.clear();
                          //   phoneNumberController.clear();
                          //   ageController.clear();
                          //   selectedGender = '';
                          //   selectedImage = null;
                          //   selectedItem = null;
                          //   _memberStreamController.add(memberList);
                          //   Navigator.pop(context);
                          // });
                        },
                        child: Container(
                          height: 40,
                          width: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Text(
                            "ADD",
                            style: TextStyle(
                              fontSize: 15.0,
                              color: textColor,
                              fontFamily: 'GT Walsheim Trial',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(15.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
