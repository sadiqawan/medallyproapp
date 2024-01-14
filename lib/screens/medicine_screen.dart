import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medallyproapp/constants/mycolors.dart';
import 'package:medallyproapp/providers/time_provider.dart';
import 'package:medallyproapp/screens/prescription_list.dart';
import 'package:medallyproapp/sharedpreference/share_preference.dart';
import 'package:medallyproapp/widgets/custom_button.dart';
import 'package:medallyproapp/widgets/my_textformfield.dart';
import 'package:medallyproapp/widgets/timepicker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

import 'ocr_scanning_screen.dart';

class MedicineScreen extends StatefulWidget {
  MedicineScreen(
      {super.key,
        this.doctorName,
        this.member,
        this.selectedImage,
        this.ocrText});

  String? doctorName;
  File? selectedImage;
  String? member;
  String? ocrText;

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  TextEditingController medicineNameController = TextEditingController();
  TextEditingController intakeController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;

  File? _frontImage;
  File? _backImage;
  bool isLoading = false;
  String selectedOption = 'Tablet';

  Future<void> _getImage(ImageSource source, bool isFront) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(pickedFile.path);
        } else {
          _backImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _showImagePickerDialog(bool newValue) async {
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
                  _getImage(ImageSource.camera, newValue);
                },
              ),
              ListTile(
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery, newValue);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Permission Handler
  Future<void> openGallery(bool value) async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    switch (cameraStatus) {
      case PermissionStatus.granted:
        _showImagePickerDialog(value);
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


  void addMedicineToFirebase() async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);

    String? userId = MySharedPrefClass.preferences?.getString("UserID");
    String? userName = MySharedPrefClass.preferences?.getString("UserName");

    print("UserID $userId");
    print("UserName $userName");
    print("UserName2 ${user!.displayName}");

    if (_formKey.currentState!.validate() &&
        _frontImage != null &&
        _backImage != null &&
        widget.selectedImage != null) {
      setState(() {
        isLoading = true;
      });

      try {
        Reference frontImageRef = FirebaseStorage.instance
            .ref()
            .child("MedicineImages")
            .child("${randomAlphaNumeric(9)}_front.jpg");
        final UploadTask frontImageTask = frontImageRef.putFile(_frontImage!);

        Reference backImageRef = FirebaseStorage.instance
            .ref()
            .child("MedicineImages")
            .child("${randomAlphaNumeric(9)}_back.jpg");
        final UploadTask backImageTask = backImageRef.putFile(_backImage!);

        Reference doctorImageRef = FirebaseStorage.instance
            .ref()
            .child("DoctorImages")
            .child("${randomAlphaNumeric(9)}.jpg");
        final UploadTask doctorImageTask =
        doctorImageRef.putFile(widget.selectedImage!);

        await Future.wait([frontImageTask, backImageTask, doctorImageTask]);

        var frontImageDownloadUrl = await frontImageRef.getDownloadURL();
        var backImageDownloadUrl = await backImageRef.getDownloadURL();
        var doctorImageDownloadUrl = await doctorImageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("medicineDetail")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("medicines")
            .add({
          "userId": user!.uid,
          "userName": userName,
          "doctorName": widget.doctorName,
          "member": widget.member,
          "doctorImage": doctorImageDownloadUrl,
          "medicineName": medicineNameController.text.toString(),
          "time": timeProvider.selectedTimes,
          "intake": intakeController.text.toString(),
          "typeOfMedicine": selectedOption,
          "duration": durationController.text.toString(),
          "note": notesController.text.toString(),
          "frontImage": frontImageDownloadUrl,
          "backImage": backImageDownloadUrl,
        }).then((value) {
          setState(() {
            isLoading = false;
          });

          medicineNameController.clear();
          intakeController.clear();
          durationController.clear();
          notesController.clear();
          timeProvider.clearSelectedTimes();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Added Successfully",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          );

          // Navigate to PrescriptionListScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrescriptionListScreen()),
          );
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });

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
      }
    }
  }






  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("OCR ${widget.ocrText}");
    medicineNameController = TextEditingController(text: widget.ocrText);
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    print("Member ${widget.member}");
    print("Doctor ${widget.doctorName}");
    print("Image ${widget.selectedImage}");

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
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
            "Medicine",
            style: TextStyle(
              fontSize: 20.0,
              color: textColor,
              fontFamily: 'GT Walsheim Trial',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Gap(50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: MyTextFormField(
                          controller: medicineNameController,
                          validator: (String? value){
                            if(value == null || value.isEmpty){
                              return 'Please scan image of tablet';
                            }return null;
                          },
                          hintText: "Dollo 650mg Tablet",
                          labelText: "Medicine name",
                          enabledBorderColor: containerBorderColor,
                          focusedBorderColor: primaryColor,
                          suffixIcon: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OcrScanningScreen(
                                    member: widget.member,
                                    selectedImage: widget.selectedImage,
                                    doctorName: widget.doctorName,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.document_scanner_sharp,
                              color: containerBorderColor,
                              size: 25.0,
                            ),
                          ),
                        ),
                      ),
                      const Gap(30),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(left: 30.0),
                        child: Text(
                          "Time",
                          style: TextStyle(
                            color: textBlackColor.withOpacity(0.3),
                            fontFamily: 'GT Walsheim Trial',
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      const TimePickerRow(),
                      const Gap(30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: MyTextFormField(
                          controller: intakeController,
                          validator: (String? value){
                            if(value == null || value.isEmpty){
                              return 'Please add intakes';
                            }return null;
                          },
                          keyboardType: TextInputType.number,
                          hintText: "4",
                          labelText: "Intake",
                          enabledBorderColor: containerBorderColor,
                          focusedBorderColor: primaryColor,
                        ),
                      ),
                      const Gap(30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Radio(
                            value: 'Tablet',
                            activeColor: primaryColor,
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value.toString();
                              });
                            },
                          ),
                          const Text('Tablet'),
                          Radio(
                            value: 'Pill',
                            activeColor: primaryColor,
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value.toString();
                              });
                            },
                          ),
                          const Text('Pill'),
                          Radio(
                            value: 'Table Spoons',
                            activeColor: primaryColor,
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value.toString();
                              });
                            },
                          ),
                          const Text('Table Spoons'),
                        ],
                      ),
                      const Gap(30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: MyTextFormField(
                          controller: durationController,
                          validator: (String? value){
                            if(value == null || value.isEmpty){
                              return 'Please add days';
                            }return null;
                          },
                          keyboardType: TextInputType.number,
                          hintText: "6 Days",
                          labelText: "Duration (Days)",
                          enabledBorderColor: containerBorderColor,
                          focusedBorderColor: primaryColor,
                        ),
                      ),
                      const Gap(30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: MyTextFormField(
                          controller: notesController,
                          validator: (String? value){
                            if(value == null || value.isEmpty){
                              return 'Please add note';
                            }return null;
                          },
                          keyboardType: TextInputType.text,
                          hintText: "Neque porro quisquam est qui dolorem",
                          labelText: "Notes",
                          enabledBorderColor: containerBorderColor,
                          focusedBorderColor: primaryColor,
                        ),
                      ),
                      const Gap(30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Photo",
                              style: TextStyle(
                                color: textBlackColor.withOpacity(0.3),
                                fontFamily: 'GT Walsheim Trial',
                                fontSize: 14.0,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _frontImage = null;
                                  _backImage = null;
                                });
                              },
                              child: Text(
                                "Remove",
                                style: TextStyle(
                                  color: textBlackColor.withOpacity(0.3),
                                  fontFamily: 'GT Walsheim Trial',
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _frontImage != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.file(
                              _frontImage!,
                              fit: BoxFit.cover,
                              width: 170,
                              height: 110,
                            ),
                          )
                              : GestureDetector(
                            onTap: () {
                              openGallery(true);
                            },
                            child: Container(
                              height: 110,
                              width: 170,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: const DecorationImage(
                                      image: AssetImage(
                                          "assets/images/medicine1.png"),
                                      filterQuality: FilterQuality.high,
                                      fit: BoxFit.cover)),
                            ),
                          ),
                          _backImage != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.file(
                              _backImage!,
                              fit: BoxFit.cover,
                              width: 170,
                              height: 110,
                            ),
                          )
                              : GestureDetector(
                            onTap: () {
                              openGallery(false);
                            },
                            child: Container(
                              height: 110,
                              width: 170,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: const DecorationImage(
                                      image: AssetImage(
                                          "assets/images/medicine2.png"),
                                      filterQuality: FilterQuality.high,
                                      fit: BoxFit.cover)),
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Frount",
                            style: TextStyle(
                              color: textBlackColor.withOpacity(0.3),
                              fontFamily: 'GT Walsheim Trial',
                              fontSize: 14.0,
                            ),
                          ),
                          Text(
                            "Back",
                            style: TextStyle(
                              color: textBlackColor.withOpacity(0.3),
                              fontFamily: 'GT Walsheim Trial',
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                      GestureDetector(
                        onTap: (){
                          addMedicineToFirebase();
                        },
                        child: CustomButton(
                          text: "SAVE",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Visibility(
              visible: isLoading,
              child: Container(
                height: 60,
                width: 300,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitCircle(
                      color: textColor,
                    ),
                    SizedBox(
                      width: 25.0,
                    ),
                    Text("Loading, Please wait", style: TextStyle(color: textColor),),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
