import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
import 'package:path_provider/path_provider.dart' as path_provider;



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
  var connectivityResult = ConnectivityResult.none;
  File? _frontImage;
  File? _backImage;
  bool isLoading = false;
  bool showTimeSections = false;
  bool showAddTime = false;
  String selectedOption = 'Tablet';
  String selectedMedicine = 'Injection';
  String selectedDescriptionType = 'Before Food';

  // TODO TYPE OF MEDICINES LIST
  List<String> typeOfMedicine = [
    'Injection',
    'Penfil',
    'Vaccine',
    'Cartridge',
    'Tablet',
    'Capsule',
    'Transcaps',
    'Cream',
    'Gel',
    'Ointment',
    'Lotion',
    'Creamgel',
    'Syrup',
    'Solution',
    'Suspension',
    'Wash',
    'Liquid',
    'Paint',
    'Shampoo',
    'Emulshion',
    'Inhalation',
    'Kit',
    'Drop',
    'Drops',
    'Spray',
    'Sachet',
    'Gargle',
    'Suspension',
    'Granules',
    'Suppository',
    'Paste',
    'Soap',
    'Infusion',
    'Foam',
    'Liquidgel',
    'Patch',
    'Repsules',
    'Inhaler',
    'Transhaler',
    'Serum',
    'Not Found'

  ];


  // TODO DESCRIPTION TYPES LIST
  List<String> typeOfDescription = [
    'Before Food',
    'After Food',
    'Before sleep',
    'Empty Stomach',
    'Before Breakfast',
    'After Breakfast',
    'Before Lunch',
    'After Lunch',
    'Before Dinner',
    'After Dinner',
    'Between Meals',

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
      addMedicineToFirebase();
    }
  }

  // TODO IMAGE PICKER
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

  // TODO Permission Handler
  Future<void> getPermissions(bool value) async {
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


  // TODO COMPRESS IMAGE
  Future<File> compressImage(File imageFile) async {
    try {
      final tempDir = await path_provider.getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      var result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 20, // Adjust quality as needed (0 - 100)
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



  // TODO ADD MEDICINES TO FIREBASE WITH REQUIRED ALL FIELDS
  // void addMedicineToFirebase() async {
  //   final timeProvider = Provider.of<TimeProvider>(context, listen: false);
  //
  //   String? userId = MySharedPrefClass.preferences?.getString("UserID");
  //   String? userName = MySharedPrefClass.preferences?.getString("UserName");
  //
  //   print("UserID $userId");
  //   print("UserName $userName");
  //   print("UserName2 ${user!.displayName}");
  //
  //   if (_formKey.currentState!.validate() &&
  //       // _frontImage != null &&
  //       // _backImage != null &&
  //       widget.selectedImage != null &&
  //       // typeOfMedicine != null
  //       typeOfDescription != null &&
  //       intakeController.text.isNotEmpty &&
  //       timeProvider.selectedTimes.isNotEmpty &&
  //       durationController.text.isNotEmpty) {
  //     setState(() {
  //       isLoading = true;
  //     });
  //
  //     try {
  //
  //       File compressedFrontImage = await compressImage(_frontImage!);
  //       File compressedBackImage = await compressImage(_backImage!);
  //       File compressedDoctorImage = await compressImage(widget.selectedImage!);
  //
  //       Reference frontImageRef = FirebaseStorage.instance
  //           .ref()
  //           .child("MedicineImages")
  //           .child("${randomAlphaNumeric(9)}_front.jpg");
  //       final UploadTask frontImageTask = frontImageRef.putFile(compressedFrontImage);
  //
  //       Reference backImageRef = FirebaseStorage.instance
  //           .ref()
  //           .child("MedicineImages")
  //           .child("${randomAlphaNumeric(9)}_back.jpg");
  //       final UploadTask backImageTask = backImageRef.putFile(compressedBackImage);
  //
  //       Reference doctorImageRef = FirebaseStorage.instance
  //           .ref()
  //           .child("DoctorImages")
  //           .child("${randomAlphaNumeric(9)}.jpg");
  //       final UploadTask doctorImageTask =
  //       doctorImageRef.putFile(compressedDoctorImage);
  //
  //       await Future.wait([frontImageTask, backImageTask, doctorImageTask]);
  //
  //       var frontImageDownloadUrl = await frontImageRef.getDownloadURL();
  //       var backImageDownloadUrl = await backImageRef.getDownloadURL();
  //       var doctorImageDownloadUrl = await doctorImageRef.getDownloadURL();
  //
  //
  //       await FirebaseFirestore.instance
  //           .collection("medicineDetail")
  //           .doc(FirebaseAuth.instance.currentUser!.uid)
  //           .collection("medicines")
  //           .add({
  //         "userId": user!.uid,
  //         "userName": userName,
  //         "doctorName": widget.doctorName,
  //         "member": widget.member,
  //         "doctorImage": doctorImageDownloadUrl,
  //         "medicineName": medicineNameController.text.toString(),
  //         "time": timeProvider.selectedTimes.isEmpty ? '' : timeProvider.selectedTimes,
  //         "intake": intakeController.text.toString(),
  //         "typeOfMedicine": selectedMedicine.isEmpty ? '' : selectedMedicine,
  //         "duration": durationController.text.toString(),
  //         "note": selectedDescriptionType,
  //         "frontImage": frontImageDownloadUrl.isEmpty ? '' : frontImageDownloadUrl,
  //         "backImage": backImageDownloadUrl.isEmpty ? '' : backImageDownloadUrl,
  //       }).then((value) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //
  //         medicineNameController.clear();
  //         intakeController.clear();
  //         durationController.clear();
  //         notesController.clear();
  //         timeProvider.clearSelectedTimes();
  //
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             backgroundColor: Colors.green,
  //             content: Text(
  //               "Added Successfully",
  //               style: TextStyle(fontSize: 20.0),
  //             ),
  //           ),
  //         );
  //
  //         // Navigate to PrescriptionListScreen
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => const PrescriptionListScreen()),
  //         );
  //       });
  //     } on FirebaseAuthException catch (e) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Colors.red,
  //           content: Text(
  //             e.toString(),
  //             style: const TextStyle(fontSize: 18.0, color: Colors.black),
  //           ),
  //         ),
  //       );
  //       if (kDebugMode) {
  //         print(e.toString());
  //       }
  //     }
  //   } else {
  //     // Show toast message if any field is missing
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         backgroundColor: deleteButtonColor,
  //         content: Text(
  //           "Please fill all the textformfields, select dropdowns and select images",
  //           style: TextStyle(fontSize: 18.0, color: textColor),
  //         ),
  //       ),
  //     );
  //   }
  // }


  // TODO ADD MEDICINE TO FIREBASE WITHOUT IMAGES AND TYPE OF MEDICINE
  void addMedicineToFirebase() async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);

    String? userId = MySharedPrefClass.preferences?.getString("UserID");
    String? userName = MySharedPrefClass.preferences?.getString("UserName");
    print("username $userName");

    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Initialize variables for images
        File? compressedFrontImage;
        File? compressedBackImage;

        // Compress images if available
        if (_frontImage != null) {
          compressedFrontImage = await compressImage(_frontImage!);
        }
        if (_backImage != null) {
          compressedBackImage = await compressImage(_backImage!);
        }

        // Compress selected image
        File compressedDoctorImage = await compressImage(widget.selectedImage!);

        // Upload images to Firebase Storage
        Reference frontImageRef = FirebaseStorage.instance
            .ref()
            .child("MedicineImages")
            .child("${randomAlphaNumeric(9)}_front.jpg");
        final UploadTask? frontImageTask =
        compressedFrontImage != null ? frontImageRef.putFile(compressedFrontImage) : null;

        Reference backImageRef = FirebaseStorage.instance
            .ref()
            .child("MedicineImages")
            .child("${randomAlphaNumeric(9)}_back.jpg");
        final UploadTask? backImageTask =
        compressedBackImage != null ? backImageRef.putFile(compressedBackImage) : null;

        Reference doctorImageRef = FirebaseStorage.instance
            .ref()
            .child("DoctorImages")
            .child("${randomAlphaNumeric(9)}.jpg");
        final UploadTask doctorImageTask = doctorImageRef.putFile(compressedDoctorImage);

        // Wait for image uploads to complete
        await Future.wait([if (frontImageTask != null) frontImageTask, if (backImageTask != null) backImageTask, doctorImageTask]);

        // Get download URLs for images
        var frontImageDownloadUrl = compressedFrontImage != null ? await frontImageRef.getDownloadURL() : '';
        var backImageDownloadUrl = compressedBackImage != null ? await backImageRef.getDownloadURL() : '';
        var doctorImageDownloadUrl = await doctorImageRef.getDownloadURL();

        // Add data to Firestore
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
          "time": timeProvider.selectedTimes.isNotEmpty ? timeProvider.selectedTimes : '',
          "intake": intakeController.text.toString(),
          "typeOfMedicine": selectedMedicine.isNotEmpty ? selectedMedicine : '',
          "duration": durationController.text.toString(),
          "note": selectedDescriptionType,
          "frontImage": frontImageDownloadUrl,
          "backImage": backImageDownloadUrl,
        }).then((value) {
          setState(() {
            isLoading = false;
          });

          // Clear text controllers and selected times
          medicineNameController.clear();
          intakeController.clear();
          durationController.clear();
          notesController.clear();
          timeProvider.clearSelectedTimes();

          // Show success message
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

        // Show error message
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
    } else {
      // Show toast message if any field is missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: deleteButtonColor,
          content: Text(
            "Please fill all the textformfields, select dropdowns and select images",
            style: TextStyle(fontSize: 18.0, color: textColor),
          ),
        ),
      );
    }
  }







  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("OCR ${widget.ocrText}");
    medicineNameController = TextEditingController(text: widget.ocrText);
    intakeController.addListener(() {
      setState(() {
        // Update showTimeSections based on whether intakeController.text is empty or not
        showTimeSections = intakeController.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrescriptionListScreen()));
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
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
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
                            readOnly: false,
                            controller: medicineNameController,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please scan image of tablet';
                              }
                              return null;
                            },
                            hintText: "enter medicine name or press icon",
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
                        // TODO Type of Medicines
                        //
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //   children: [
                        //     Radio(
                        //       value: 'Tablet',
                        //       activeColor: primaryColor,
                        //       groupValue: selectedOption,
                        //       onChanged: (value) {
                        //         setState(() {
                        //           selectedOption = value.toString();
                        //         });
                        //       },
                        //     ),
                        //     const Text('Tablet'),
                        //     Radio(
                        //       value: 'Pill',
                        //       activeColor: primaryColor,
                        //       groupValue: selectedOption,
                        //       onChanged: (value) {
                        //         setState(() {
                        //           selectedOption = value.toString();
                        //         });
                        //       },
                        //     ),
                        //     const Text('Pill'),
                        //     Radio(
                        //       value: 'Table Spoons',
                        //       activeColor: primaryColor,
                        //       groupValue: selectedOption,
                        //       onChanged: (value) {
                        //         setState(() {
                        //           selectedOption = value.toString();
                        //         });
                        //       },
                        //     ),
                        //     const Text('Table Spoons'),
                        //   ],
                        // ),

                        Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(left: 30.0),
                          child: Text(
                            "Type Of Medicine",
                            style: TextStyle(
                              color: textBlackColor.withOpacity(0.3),
                              fontFamily: 'GT Walsheim Trial',
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        const Gap(10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          margin: const EdgeInsets.symmetric(horizontal: 30.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: IntrinsicWidth(
                            child: DropdownButton(
                              isExpanded: true,
                              dropdownColor: textColor,
                              value: selectedMedicine,
                              hint: const Text(
                                'Type Of Medicine',
                                style: TextStyle(color: primaryColor),
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down_sharp,
                                color: Colors.grey,
                              ),
                              items: typeOfMedicine.map((item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(color: primaryColor),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedMedicine = newValue!;
                                });
                              },
                            ),
                          ),
                        ),

                        const Gap(30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: MyTextFormField(
                            readOnly: false,
                            controller: durationController,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please add days';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            hintText: "please write duration in days",
                            labelText: "Duration (Days)",
                            enabledBorderColor: containerBorderColor,
                            focusedBorderColor: primaryColor,
                          ),
                        ),
                        const Gap(30),
                        Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(left: 30.0),
                          child: Text(
                            "Description of the medicine",
                            style: TextStyle(
                              color: textBlackColor.withOpacity(0.3),
                              fontFamily: 'GT Walsheim Trial',
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        const Gap(10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7.0),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: IntrinsicWidth(
                              child: DropdownButton(
                                isExpanded: true,
                                dropdownColor: textColor,
                                value: selectedDescriptionType,
                                hint: const Text(
                                  'Description of Medicine',
                                  style: TextStyle(color: primaryColor),
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_down_sharp,
                                  color: Colors.grey,
                                ),
                                items: typeOfDescription.map((item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(color: primaryColor),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedDescriptionType = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const Gap(30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyTextFormField(
                                readOnly: false,
                                controller: intakeController,
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please add intakes';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                hintText: "how many tablet/pills etc in a day",
                                labelText: "Intake",
                                enabledBorderColor: containerBorderColor,
                                focusedBorderColor: primaryColor,
                              ),
                              const Gap(30),
                              Visibility(
                                visible: intakeController.text.isNotEmpty,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      alignment: Alignment.topLeft,
                                      margin: const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        "Time",
                                        style: TextStyle(
                                          color: textBlackColor.withOpacity(0.3),
                                          fontFamily: 'GT Walsheim Trial',
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                    const Gap(25),
                                    const Flexible(
                                      child: TimePickerRow(),
                                    ),
                                  ],
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
                                        Text(
                                          "Loading, Please wait",
                                          style: TextStyle(color: textColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),


                        const Gap(30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Add Front & Back Image",
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
                                      getPermissions(true);
                                    },
                                    child: Container(
                                      height: 110,
                                      width: 170,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          image: const DecorationImage(
                                              image: AssetImage(
                                                  "assets/icons/gallery.png"),
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
                                      getPermissions(false);
                                    },
                                    child: Container(
                                      height: 110,
                                      width: 170,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          image: const DecorationImage(
                                              image: AssetImage(
                                                  "assets/icons/gallery.png"),
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
                          onTap: () {
                            checkInternetAndProceed(context);
                          },
                          child: CustomButton(
                            text: "SAVE",
                          ),
                        ),
                        const Gap(20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
