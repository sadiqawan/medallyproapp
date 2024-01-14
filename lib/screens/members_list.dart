import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:medallyproapp/constants/mycolors.dart';
import 'package:medallyproapp/screens/prescription_list.dart';
import 'package:medallyproapp/widgets/glowingfloatingbutton.dart';
import 'package:medallyproapp/widgets/my_textformfield.dart';
import 'package:random_string/random_string.dart';
import 'package:shimmer/shimmer.dart';
import '../model/members_model_class.dart';
import '../widgets/gender_selection.dart';
import '../widgets/pick_image.dart';

class MembersListScreen extends StatefulWidget {
  const MembersListScreen({Key? key}) : super(key: key);

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  final StreamController<List<Member>> _memberStreamController =
      StreamController<List<Member>>();

  Stream<List<Member>> get _memberStream => _memberStreamController.stream;

  @override
  void dispose() {
    _memberStreamController.close();
    super.dispose();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Member> memberList = [];
  String selectedGender = 'male';
  File? selectedImage;
  String? selectedItem = 'Self';
  List<String> items = [
    'Self',
    'Mother',
    'Brother',
    'Younger Brother',
  ];

  // TODO ADD MEMBER TO FIREBASE
  addMembersToFirebase() async {
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
        Reference firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child("UserImages")
            .child("${randomAlphaNumeric(9)}.jpg");
        final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

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
            "Gender": selectedGender,
            "image": downloadURL,
            "relation": selectedItem,
            'age': ageController.text.trim()
          });

          // Clearing variables
          setState(() {
            nameController.clear();
            phoneNumberController.clear();
            ageController.clear();
            selectedGender = 'male'; // Replace with your default gender value
            selectedImage = null;
            selectedItem = 'Self'; // Replace with your default dropdown value
          });
          Navigator.of(context).pop(); // Dismiss the dialog
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
  }

  // TODO DIALOG BOX
  addMemberListDialogBox() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
            side: const BorderSide(color: Colors.grey),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Gap(15.0),
                        const Center(
                          child: Text(
                            "Add Member",
                            style: TextStyle(
                              fontSize: 20.0,
                              color: primaryColor,
                              fontFamily: 'GT Walsheim Trial',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25.0),
                        MyTextFormField(
                          controller: nameController,
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
                        MyTextFormField(
                          controller: phoneNumberController,
                          hintText: "Phone Number",
                          labelText: "Phone Number",
                          keyboardType: TextInputType.number,
                          validator: (String? value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 9) {
                              return 'Please enter your phone number';
                            } else if (!RegExp(r'^\+?[0-9]+$')
                                .hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                          enabledBorderColor: containerBorderColor,
                          focusedBorderColor: containerBorderColor,
                        ),
                        const Gap(15.0),
                        MyTextFormField(
                          controller: ageController,
                          hintText: "Ex: 7",
                          labelText: "Enter your age",
                          keyboardType: TextInputType.number,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please add your age';
                            }
                            return null;
                          },
                          enabledBorderColor: containerBorderColor,
                          focusedBorderColor: containerBorderColor,
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
                            items: items.map((item) {
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
                                selectedItem = newValue;
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
                                Navigator.pop(context);
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

                                addMembersToFirebase();
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
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0.0,
        leading: IconButton(
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
        title: const Padding(
          padding: EdgeInsets.only(left: 80.0),
          child: Text(
            "Member List",
            style: TextStyle(
              fontSize: 20.0,
              color: textColor,
              fontFamily: 'GT Walsheim Trial',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      // body: StreamBuilder<List<Member>>(
      //   stream: _memberStream,
      //   builder: (context, snapshot) {
      //     if (snapshot.hasData && snapshot.data!.isNotEmpty) {
      //       List<Member> updatedMemberList = snapshot.data!;
      //       return Center(
      //         child: RefreshIndicator(
      //           onRefresh: () async {
      //             await Future.delayed(const Duration(seconds: 1));
      //             _memberStreamController.add(updatedMemberList);
      //           },
      //           child: Container(
      //             height: height,
      //             width: width,
      //             margin: const EdgeInsets.only(top: 10.0),
      //             decoration: const BoxDecoration(
      //               color: textColor,
      //               borderRadius: BorderRadius.only(
      //                 topLeft: Radius.circular(30.0),
      //                 topRight: Radius.circular(30.0),
      //               ),
      //             ),
      //             child: Column(
      //               children: [
      //                 Expanded(
      //                   child: ListView.builder(
      //                     itemCount: updatedMemberList.length,
      //                     physics: const BouncingScrollPhysics(),
      //                     itemBuilder: (BuildContext context, int index) {
      //                       return Container(
      //                         height: 70,
      //                         width: width,
      //                         margin: const EdgeInsets.only(
      //                           top: 20.0,
      //                           left: 18.0,
      //                           right: 18.0,
      //                         ),
      //                         decoration: BoxDecoration(
      //                           border:
      //                               Border.all(color: Colors.grey, width: 1.0),
      //                           borderRadius: BorderRadius.circular(10.0),
      //                         ),
      //                         child: Row(
      //                           mainAxisAlignment:
      //                               MainAxisAlignment.spaceEvenly,
      //                           children: [
      //                             Padding(
      //                               padding: const EdgeInsets.only(left: 8.0),
      //                               child: CircleAvatar(
      //                                 backgroundColor:
      //                                     primaryColor.withOpacity(0.2),
      //                                 child: const Text(
      //                                   "SK",
      //                                   style: TextStyle(
      //                                     color: textBlackColor,
      //                                     fontFamily: 'GT Walsheim Trial',
      //                                     fontSize: 15.0,
      //                                     fontWeight: FontWeight.w600,
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                             SizedBox(
      //                               height: height,
      //                               width: 130,
      //                               child: ListTile(
      //                                 title: Text(
      //                                   updatedMemberList[index]
      //                                       .name
      //                                       .toString(),
      //                                   style: const TextStyle(
      //                                     color: textBlackColor,
      //                                     fontFamily: 'GT Walsheim Trial',
      //                                     fontSize: 15.0,
      //                                     fontWeight: FontWeight.w600,
      //                                   ),
      //                                 ),
      //                                 subtitle: Text(
      //                                   updatedMemberList[index]
      //                                       .phoneNumber
      //                                       .toString(),
      //                                   style: TextStyle(
      //                                     color:
      //                                         textBlackColor.withOpacity(0.3),
      //                                     fontFamily: 'GT Walsheim Trial',
      //                                     fontSize: 12.0,
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                             Container(
      //                               height: 20,
      //                               width: 80,
      //                               alignment: Alignment.center,
      //                               margin: const EdgeInsets.only(
      //                                 bottom: 10.0,
      //                                 right: 20,
      //                               ),
      //                               decoration: BoxDecoration(
      //                                 color: primaryColor.withOpacity(0.2),
      //                                 borderRadius: BorderRadius.circular(3.0),
      //                               ),
      //                               child: Text(
      //                                 updatedMemberList[index]
      //                                     .relation
      //                                     .toString(),
      //                                 style: const TextStyle(
      //                                   fontSize: 8.0,
      //                                   color: primaryColor,
      //                                   fontWeight: FontWeight.bold,
      //                                 ),
      //                               ),
      //                             ),
      //                             InkWell(
      //                               onTap: () {
      //                                 setState(() {
      //                                   updatedMemberList.removeAt(index);
      //                                   _memberStreamController
      //                                       .add(updatedMemberList);
      //                                 });
      //                               },
      //                               child: Container(
      //                                 height: 25,
      //                                 width: 60,
      //                                 alignment: Alignment.center,
      //                                 margin: const EdgeInsets.only(right: 10),
      //                                 decoration: BoxDecoration(
      //                                   color: Colors.red,
      //                                   borderRadius:
      //                                       BorderRadius.circular(3.0),
      //                                 ),
      //                                 child: const Text(
      //                                   "Delete",
      //                                   style: TextStyle(
      //                                     fontSize: 10.0,
      //                                     color: textColor,
      //                                     fontWeight: FontWeight.bold,
      //                                   ),
      //                                 ),
      //                               ),
      //                             )
      //                           ],
      //                         ),
      //                       );
      //                     },
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       );
      //     } else if (snapshot.hasError) {
      //       return Text("Error: ${snapshot.error}");
      //     } else {
      //       return const Center(
      //         child: Text(
      //           "No data available",
      //           style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 18.0,
      //             fontWeight: FontWeight.bold,
      //           ),
      //         ),
      //       );
      //     }
      //   },
      // ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('membersList')
            .doc(user!.uid)
            .collection('members')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No data available"),
            );
          }

          try {
            List<Member> members = snapshot.data!.docs.map((doc) {
              return Member(
                memberId: doc.id,
                name: doc['name'],
                phoneNumber: doc['phoneNumber'],
                age: doc['age'],
                gender: doc['Gender'],
                relation: doc['relation'],
                image: doc['image'],
              );
            }).toList();

            // Reverse the order of the members list
            members = members.reversed.toList();


            return Container(
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: members.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 70,
                          width: width,
                          margin: const EdgeInsets.only(
                            top: 20.0,
                            left: 18.0,
                            right: 18.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: CircleAvatar(
                                  radius: 20.0,
                                  backgroundColor: primaryColor.withOpacity(0.2),
                                  child: FutureBuilder<void>(
                                    future: precacheImage(
                                      NetworkImage(members[index].image.toString()),
                                      context,
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        return CircleAvatar(
                                          radius: 20.0,
                                          backgroundImage: NetworkImage(
                                            members[index].image.toString(),
                                          ),
                                        );
                                      } else {
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: CircleAvatar(
                                            radius: 20.0,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height,
                                width: 130,
                                child: ListTile(
                                  title: Text(
                                    members[index].name.toString(),
                                    style: const TextStyle(
                                      color: textBlackColor,
                                      fontFamily: 'GT Walsheim Trial',
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    members[index].phoneNumber.toString(),
                                    style: TextStyle(
                                      color: textBlackColor.withOpacity(0.3),
                                      fontFamily: 'GT Walsheim Trial',
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 20,
                                width: 80,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(
                                  bottom: 10.0,
                                  right: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                child: Text(
                                  members[index].relation.toString(),
                                  style: const TextStyle(
                                    fontSize: 8.0,
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  FirebaseFirestore.instance
                                      .collection('membersList')
                                      .doc(user!.uid)
                                      .collection('members')
                                      .doc(members[index].memberId)
                                      .delete()
                                      .then((value) {
                                    print("Member Deleted");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Member Deleted'),
                                      ),
                                    );
                                  }).catchError((error) {
                                    print("Error deleting document: $error");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Error deleting document'),
                                      ),
                                    );
                                  });
                                },
                                child: Container(
                                  height: 25,
                                  width: 60,
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(3.0),
                                  ),
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } catch (e) {
            print("Error creating Member instances: $e");
            return const Center(
              child: Text("Error loading data"),
            );
          }
        },
      ),

      floatingActionButton: GlowingFloatingActionButton(
        onPressed: addMemberListDialogBox,
      ),
    );
  }
}
