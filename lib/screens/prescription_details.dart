import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medallyproapp/providers/deletemedicine_provider.dart';
import 'package:medallyproapp/screens/mydrawer_screen.dart';
import 'package:medallyproapp/screens/prescription_list.dart';
import 'package:medallyproapp/widgets/my_textformfield.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/mycolors.dart';
import '../model/medicine_model_class.dart';
import '../providers/deleteuser_provider.dart';
import '../providers/updateMedicineData_provider.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  final MedicineModel medicineModel;

  const PrescriptionDetailScreen({Key? key, required this.medicineModel})
      : super(key: key);

  @override
  State<PrescriptionDetailScreen> createState() =>
      _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? user = FirebaseAuth.instance.currentUser;

  String? selectedOption;

  // TODO UPDATE DATA IN FIREBASE
  // Future<void> updateDataInFirebase(String nameOfMedicine, prescriptionNote, medicineType,
  //     durationOfMedicine, medicineIntake, List medicineTimes) async {
  //   String? documentId = widget.medicineModel.userID;
  //   print("DocumentID $documentId");
  //
  //   print("Medicine Name $nameOfMedicine");
  //   print("prescriptionNote $prescriptionNote");
  //   print("medicineType $medicineType");
  //   print("durationOfMedicine $durationOfMedicine");
  //   print("medicineIntake $medicineIntake");
  //   print("medicineTimes $medicineTimes");
  //
  //   // Prepare the data to be updated
  //   Map<String, dynamic> updatedData = {
  //     'medicineName': nameOfMedicine,
  //     'note': prescriptionNote,
  //     'duration': durationOfMedicine,
  //     'intake': medicineIntake,
  //     'typeOfMedicine': selectedOption,
  //     'time': medicineTimes,
  //   };
  //
  //   try {
  //     // Check for internet connectivity
  //     var connectivityResult = await Connectivity().checkConnectivity();
  //     if (connectivityResult != ConnectivityResult.none) {
  //       // Show CircularProgressIndicator
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return const Center(
  //             child: CircularProgressIndicator(color: primaryColor),
  //           );
  //         },
  //       );
  //
  //       // Update data in Firestore
  //       await FirebaseFirestore.instance
  //           .collection('medicineDetail')
  //           .doc(user!.uid)
  //           .collection('medicines')
  //           .doc(documentId)
  //           .update(updatedData);
  //
  //       // Close the CircularProgressIndicator Dialog
  //       Navigator.pop(context);
  //
  //       // Show Toast for successful update
  //       Fluttertoast.showToast(
  //         msg: "Successfully updated!",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.green,
  //         textColor: Colors.white,
  //         fontSize: 16.0,
  //       );
  //
  //       // Navigate to PrescriptionListScreen
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const PrescriptionListScreen()),
  //       );
  //     } else {
  //       // Close the CircularProgressIndicator Dialog
  //       Navigator.pop(context);
  //
  //       // Show error dialog for no internet connectivity
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: const Text("Error"),
  //             content: const Text("No internet connection"),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text("OK"),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     }
  //   } catch (error) {
  //     // Close the CircularProgressIndicator Dialog on error
  //     Navigator.pop(context);
  //
  //     print("Error updating document: $error");
  //
  //     // Show error dialog
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text("Error"),
  //           content: const Text("Failed to update data"),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: const Text("OK"),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    var deleteMedicine =
        Provider.of<DeleteMedicineProvider>(context, listen: false);
    var deleteUser = Provider.of<DeleteUserProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: primaryColor,
      key: _scaffoldKey,
      drawer: MyDrawerScreen(),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10.0,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          height: height,
          width: width,
          margin: const EdgeInsets.only(top: 10.0),
          decoration: const BoxDecoration(
            color: textColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Column(
            children: [
              const Gap(30),
              SizedBox(
                height: 70,
                width: width,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12.0,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PrescriptionListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: textBlackColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: primaryColor.withOpacity(0.2),
                        backgroundImage: NetworkImage(
                          widget.medicineModel.doctorImage,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height,
                      width: 150,
                      child: ListTile(
                        title: Text(
                          widget.medicineModel.member.toString(),
                          style: const TextStyle(
                              color: primaryColor,
                              fontFamily: 'GT Walsheim Trial',
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          widget.medicineModel.doctorName,
                          style: TextStyle(
                            color: textBlackColor.withOpacity(0.3),
                            fontFamily: 'GT Walsheim Trial',
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: GestureDetector(
                    //     onTap: (){},
                    //     child: Container(
                    //       height: 25,
                    //       width: 50,
                    //       alignment: Alignment.topRight,
                    //       margin: const EdgeInsets.only(right: 25),
                    //       child: const Text(
                    //         "Stop",
                    //         style: TextStyle(
                    //           color: deleteButtonColor,
                    //           fontFamily: 'GT Walsheim Trial',
                    //           fontSize: 14.0,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
              const Gap(20),
              widget.medicineModel != null
                  ? Expanded(
                      child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 20.0);
                        },
                        physics: const BouncingScrollPhysics(),
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 215.0,
                            width: width,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: containerBorderColor.withOpacity(0.3),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15.0, left: 8.0),
                                      child: CircleAvatar(
                                        radius: 12.0,
                                        backgroundColor:
                                            primaryColor.withOpacity(0.2),
                                        child: FutureBuilder<void>(
                                          future: precacheImage(
                                            NetworkImage(widget
                                                .medicineModel.fronImage
                                                .toString()),
                                            context,
                                          ),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              return CircleAvatar(
                                                radius: 12.0,
                                                backgroundImage: NetworkImage(
                                                    widget
                                                        .medicineModel.fronImage
                                                        .toString()),
                                              );
                                            } else {
                                              return Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor:
                                                    Colors.grey[100]!,
                                                child: const CircleAvatar(
                                                  radius: 20.0,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        width: 150,
                                        padding: const EdgeInsets.only(
                                          top: 15.0,
                                          right: 25.0,
                                        ),
                                        decoration: const BoxDecoration(),
                                        child: Text(
                                          widget.medicineModel.medicineName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 30.0,
                                        top: 15.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          editData(context);
                                        },
                                        child: const Text(
                                          "Edit",
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'GT Walsheim Trial',
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 30.0,
                                        top: 15.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          deleteMedicine.deleteDataInFirebase(
                                              context,
                                              widget.medicineModel.userID
                                                  .toString());
                                        },
                                        child: const Text(
                                          "Stop",
                                          style: TextStyle(
                                            color: deleteButtonColor,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'GT Walsheim Trial',
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(30),
                                Row(
                                  children: [
                                    Container(
                                      height: 20.0,
                                      width: 70.0,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Time",
                                        style: TextStyle(
                                          color:
                                              textBlackColor.withOpacity(0.3),
                                          fontFamily: 'GT Walsheim Trial',
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 90),
                                    Container(
                                      height: 20.0,
                                      width: 90.0,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Intake",
                                        style: TextStyle(
                                          color:
                                              textBlackColor.withOpacity(0.3),
                                          fontFamily: 'GT Walsheim Trial',
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 20.0,
                                        width: 90.0,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Duration",
                                          style: TextStyle(
                                            color:
                                                textBlackColor.withOpacity(0.3),
                                            fontFamily: 'GT Walsheim Trial',
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(5.0),
                                Row(
                                  children: [
                                    Container(
                                      width: 140.0,
                                      margin: const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        widget.medicineModel.time.join('\n'),
                                        style: const TextStyle(
                                          color: textBlackColor,
                                          fontFamily: 'GT Walsheim Trial',
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      height: 20.0,
                                      width: 90.0,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "${widget.medicineModel.intake} ${widget.medicineModel.typeOfMedicine}",
                                        style: const TextStyle(
                                          color: textBlackColor,
                                          fontFamily: 'GT Walsheim Trial',
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 20.0,
                                        width: 90.0,
                                        alignment: Alignment.center,
                                        child: Text(
                                          widget.medicineModel.duration,
                                          style: const TextStyle(
                                            color: textBlackColor,
                                            fontFamily: 'GT Walsheim Trial',
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(5),
                                ListTile(
                                  title: Text(
                                    "Notes",
                                    style: TextStyle(
                                      color: textBlackColor.withOpacity(0.3),
                                      fontFamily: 'GT Walsheim Trial',
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  subtitle: Text(
                                    widget.medicineModel.notes,
                                    style: const TextStyle(
                                      color: textBlackColor,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'GT Walsheim Trial',
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Text(
                        "No data available",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18.0,
                          fontFamily: 'GT Walsheim Trial',
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      // floatingActionButton: GlowingFloatingActionButton(
      //   onPressed: () {},
      // ),
    );
  }

  // TODO EDIT DIALOGBOX
  editData(BuildContext context) async {
    var medicineProvider =
        Provider.of<MedicineProvider>(context, listen: false);
    var medicineName = TextEditingController();
    final note = TextEditingController();
    final duration = TextEditingController();
    final intake = TextEditingController();
    List<String> times = List.from(widget.medicineModel.time);

    selectedOption = widget.medicineModel.typeOfMedicine;
    print("Type of Medicine $selectedOption");
    medicineName.text = widget.medicineModel.medicineName;
    note.text = widget.medicineModel.notes;
    duration.text = widget.medicineModel.duration;
    intake.text = widget.medicineModel.intake;

    String? documentID = widget.medicineModel.userID;

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: AlertDialog(
              backgroundColor: textColor,
              title: const Text(
                'Update Details',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    height: 420.0,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        MyTextFormField(
                          readOnly: false,
                          hintText: "Medicine Name",
                          labelText: "Update Medicine Name",
                          controller: medicineName,
                          enabledBorderColor: containerBorderColor,
                          focusedBorderColor: primaryColor,
                        ),
                        const SizedBox(height: 10.0),
                        MyTextFormField(
                          readOnly: false,
                          hintText: "Notes",
                          labelText: "Update Note",
                          controller: note,
                          enabledBorderColor: containerBorderColor,
                          focusedBorderColor: primaryColor,
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 10.0),
                        MyTextFormField(
                          readOnly: false,
                          hintText: "Duration",
                          labelText: "Update Duration",
                          controller: duration,
                          enabledBorderColor: containerBorderColor,
                          focusedBorderColor: primaryColor,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10.0),
                        MyTextFormField(
                          readOnly: false,
                          hintText: "Intake",
                          labelText: "Update Intake",
                          controller: intake,
                          enabledBorderColor: containerBorderColor,
                          focusedBorderColor: primaryColor,
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 10.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Radio(
                                value: 'Tablet',
                                activeColor: primaryColor,
                                groupValue: selectedOption,
                                onChanged: (value) {
                                  setState(() {
                                    print("Radio button selected: $value");
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
                                  print("Radio button selected: $value");

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
                                    print("Radio button selected: $value");
                                    selectedOption = value.toString();
                                  });
                                },
                              ),
                              const Text('Table Spoons'),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(
                                height: 10.0,
                              );
                            },
                            itemCount: times.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return MyTextFormField(
                                  readOnly: false,
                                  hintText: "Time",
                                  labelText: "Update Time ${index + 1}",
                                  controller:
                                      TextEditingController(text: times[index]),
                                  enabledBorderColor: containerBorderColor,
                                  focusedBorderColor: primaryColor,
                                  keyboardType: TextInputType.text,
                                  onTap: () async {
                                    FocusScope.of(context).requestFocus(
                                        FocusNode()); // Dismiss keyboard

                                    String cleanedTimeString = times[index]
                                        .replaceAll('\u200B',
                                            ''); // Remove Zero Width Space

                                    TimeOfDay? initialTime;

                                    try {
                                      initialTime = TimeOfDay.fromDateTime(
                                        DateFormat.jm()
                                            .parse(cleanedTimeString),
                                      );
                                    } catch (e) {
                                      print("Error parsing time: $e");
                                    }

                                    if (initialTime == null) {
                                      initialTime = TimeOfDay.now();
                                    }

                                    TimeOfDay? pickedTime =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: initialTime,
                                    );

                                    if (pickedTime != null) {
                                      times[index] = pickedTime.format(context);
                                      // Print or update your list accordingly
                                      print("Updated Time: ${times[index]}");
                                      // Update the UI after selecting the time
                                      setState(() {});
                                    }
                                  }

                                  // onChanged: (value){
                                  //   times[index] = value;
                                  // }
                                  );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 95.0,
                      height: 43.0,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor, shadowColor: textBlackColor.withOpacity(0.3),
                            side: BorderSide(
                              color: primaryColor.withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontSize: 15.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 95.0,
                      height: 43.0,
                      child: OutlinedButton(
                        onPressed: () {
                          medicineProvider.updateDataInFirebase(
                            context,
                            medicineName.text.toString(),
                            note.text.toString(),
                            selectedOption,
                            duration.text.toString(),
                            intake.text.toString(),
                            times,
                            documentID.toString(),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor: textColor, shadowColor: textBlackColor.withOpacity(0.3),
                            backgroundColor: primaryColor,
                            side: BorderSide(
                              color: textColor.withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                        child: const Text(
                          "Save",
                          style: TextStyle(fontSize: 17.0),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }
}
