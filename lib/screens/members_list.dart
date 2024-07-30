import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medallyproapp/constants/mycolors.dart';
import 'package:medallyproapp/screens/prescription_list.dart';
import 'package:medallyproapp/widgets/glowingfloatingbutton.dart';
import 'package:medallyproapp/widgets/my_textformfield.dart';
import 'package:shimmer/shimmer.dart';
import '../model/members_model_class.dart';
import '../widgets/customtoast_screen.dart';
import 'add_members_screen.dart';

class MembersListScreen extends StatefulWidget {
  const MembersListScreen({Key? key}) : super(key: key);

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController dateOfBirth = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  String selectedGender = 'male';
  File? selectedImage;
  String selectedItem = 'Brother';
  DateTime? _selectedDate;

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

  // TODO Format The Date
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }


  // TODO UPDATE DATA DIALOG BOX
  updateMembersDetails(String id, memberName, phoneNumber, dateOfBirth, gender, relation) async{
    print("memberName $memberName");
    print("phoneNumber $memberName");
    print("dateOfBirth $dateOfBirth");
    print("Gender $gender");
    print("Relation $relation");
    print("id $id");


    final memberNameController = TextEditingController();
    final phoneNumberController = TextEditingController();
    final dateOfBirthController = TextEditingController();
    String? myGender;
    String? selectedRelation;


    memberNameController.text = memberName;
    phoneNumberController.text = phoneNumber;
    dateOfBirthController.text = dateOfBirth;
    myGender = gender;
    selectedRelation = relation;




    // TODO SELECT DATE
    Future<void> _updateSelecteDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
          dateOfBirthController.text = "${picked.toLocal()}".split(' ')[0];
        });
      }
    }



    return showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            backgroundColor: textColor,
            title: const Text(
              'Update Details',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState){
                return SizedBox(
                  height: 350.0,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Column(
                    children: [
                      const SizedBox(height: 15.0,),
                      MyTextFormField(
                        readOnly: false,
                        hintText: "Member Name",
                        labelText: "Update Member Name",
                        controller: memberNameController,
                        enabledBorderColor: containerBorderColor,
                        focusedBorderColor: primaryColor,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        cursorColor: primaryColor,
                        controller: phoneNumberController,
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
                      const SizedBox(height: 15),
                      MyTextFormField(
                        readOnly: false,
                        hintText: "Date Of Birth",
                        labelText: "Date Of Birth",
                        controller: dateOfBirthController,
                        enabledBorderColor: containerBorderColor,
                        focusedBorderColor: primaryColor,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _updateSelecteDate(context);
                          },
                          child: const Icon(Icons.calendar_today),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Radio(
                            value: 'male',
                            activeColor: primaryColor,
                            groupValue: myGender,
                            onChanged: (value) {
                              setState(() {
                                print("Radio button selected: $value");
                                myGender = value.toString();
                              });
                            },
                          ),
                          const Text('male'),
                          Radio(
                            value: 'female',
                            activeColor: primaryColor,
                            groupValue: myGender,
                            onChanged: (value) {
                              print("Radio button selected: $value");

                              setState(() {
                                myGender = value.toString();
                              });
                            },
                          ),
                          const Text('female'),
                        ],
                      ),
                      const SizedBox(height: 15,),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          value: selectedRelation,
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
                              selectedRelation = newValue;
                            });
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
                    width: 110.0,
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
                        "Back",
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 110.0,
                    height: 43.0,
                    child: OutlinedButton(
                      onPressed: () {
                        _updateMember(context, id, memberNameController.text, phoneNumberController.text, _selectedDate, selectedGender, selectedRelation);
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
                        "Update",
                        style: TextStyle(fontSize: 17.0),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        }
    );
  }

  _updateMember(context, String id, memberName, phoneNumber, dateOfBirth, gender, relation) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await updateMember(context, id, {
        'name': memberName,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'relation': relation,
        'phoneNumber': phoneNumber,
      });

      Navigator.of(context).pop(); // Close the dialog

    } catch (error) {
      print("Error updating data: $error");
      CustomToast.showToast(context, "Failed to update data. Please try again.");

    } finally {
      setState(() {
        _isLoading = false; // Hide circular progress indicator
      });
    }
  }

  updateMember(context, String docId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance
          .collection('membersList')
          .doc(user!.uid)
          .collection('members')
          .doc(docId)
          .update(newData);
    } catch (error) {
      CustomToast.showToast(context, "Error updating user data: $error");
      print("Error updating user data: $error");
      rethrow;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    nameController.clear();
    phoneNumberController.clear();
    dateOfBirth.clear();
    selectedGender = "Brother";
    _selectedDate = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    User? user = FirebaseAuth.instance.currentUser;
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
              Timestamp dateOfBirthTimestamp = doc['dateOfBirth'];
              DateTime dateOfBirth = dateOfBirthTimestamp.toDate();

              print("DocId ${doc.id}");


              return Member(
                memberId: doc.id,
                name: doc['name'],
                phoneNumber: doc['phoneNumber'],
                dateOfBirth: dateOfBirth,
                gender: doc['gender'],
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

                        String formattedDate = _formatTimestamp(snapshot
                            .data!
                            .docs[index]['dateOfBirth'] as Timestamp? ??
                            Timestamp.now());

                        return Container(
                          height: 70,
                          width: 300.0,
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
                                  backgroundColor:
                                      primaryColor.withOpacity(0.2),
                                  child: FutureBuilder<void>(
                                    future: precacheImage(
                                      NetworkImage(
                                          members[index].image.toString()),
                                      context,
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
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
                                          child: const CircleAvatar(
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
                                width: 180,
                                child: ListTile(
                                  title: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: members[index].name,
                                          style: const TextStyle(
                                            color: textBlackColor,
                                            fontFamily: 'GT Walsheim Trial',
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' (${members[index].relation})',
                                          style: const TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'GT Walsheim Trial',
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
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
                              InkWell(
                                onTap: (){
                                  updateMembersDetails(
                                    members[index].memberId.toString(),
                                    members[index].name.toString(),
                                    members[index].phoneNumber.toString(),
                                    formattedDate,
                                    members[index].gender.toString(),
                                    members[index].relation.toString()
                                  );
                                },
                                child: Container(
                                    height: 30,
                                    width: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 20.0,
                                      color: textColor,
                                    )),
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
                                        content:
                                            Text('Error deleting document'),
                                      ),
                                    );
                                  });
                                },
                                child: Container(
                                    height: 30,
                                    width: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      size: 20.0,
                                      color: textColor,
                                    )),
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
        onPressed: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddMembersScreen()));
        },
        textColor: textColor,
        myColor: primaryColor,
      ),
    );
  }
}
