import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../constants/mycolors.dart';
import '../sharedpreference/share_preference.dart';
import '../widgets/customtoast_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userId = MySharedPrefClass.preferences?.getString("UserID");
  String? name, gender, dateOfBirth, phoneNumber, id;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? selectedGender;
  DateTime? _selectedDate;

  // TODO Format The Date
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  // TODO My Profile List Data
  List myProfileData = [
    {
      'name': 'Shaki Sun',
      'leadingIcon': Icon(
        Icons.person,
        color: textBlackColor.withOpacity(0.7),
      ),
      'trailingIcon': IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.edit,
          color: deleteButtonColor.withOpacity(0.9),
        ),
      ),
    },
    {
      'name': 'Hassan Sun',
      'leadingIcon': Icon(
        Icons.accessibility_new_sharp,
        color: textBlackColor.withOpacity(0.7),
      ),
      'trailingIcon': IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.edit,
          color: deleteButtonColor.withOpacity(0.9),
        ),
      ),
    },
    {
      'name': 'Shaila Sun',
      'leadingIcon': Icon(
        Icons.phone_android_rounded,
        color: textBlackColor.withOpacity(0.7),
      ),
      'trailingIcon': IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.edit,
          color: deleteButtonColor.withOpacity(0.9),
        ),
      ),
    },
    {
      'name': 'Kashi Sun',
      'leadingIcon': Icon(
        Icons.date_range_rounded,
        color: textBlackColor.withOpacity(0.7),
      ),
      'trailingIcon': IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.edit,
          color: deleteButtonColor.withOpacity(0.9),
        ),
      ),
    },
  ];

  // TODO Select Date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  // Future<void> updateUserData(
  //     String docId, Map<String, dynamic> newData) async {
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(docId)
  //       .update(newData);
  // }

  // TODO Show DialogBox

  void _showDialog(
      String name, String dateOfBirth, String gender, String id, fieldName) {
    _nameController.text = name;
    _dateController.text = dateOfBirth;
    selectedGender = gender;

    print("Name ${_nameController.text}");
    print("Name ${_dateController.text}");
    print("Name ${selectedGender}");

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update Data'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                  height: 250.0,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(labelText: "Update name"),
                      ),
                      const Gap(15.0),
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: "Update dateOfBirth",
                          suffixIcon: GestureDetector(
                            onTap: () {
                              _selectDate(context);
                            },
                            child: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                      const Gap(25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Radio(
                            value: 'male',
                            activeColor: primaryColor,
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                print("Radio button selected: $value");
                                selectedGender = value.toString();
                              });
                            },
                          ),
                          const Text('male'),
                          Radio(
                            value: 'female',
                            activeColor: primaryColor,
                            groupValue: selectedGender,
                            onChanged: (value) {
                              print("Radio button selected: $value");

                              setState(() {
                                selectedGender = value.toString();
                              });
                            },
                          ),
                          const Text('female'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    color: deleteButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    splashColor: primaryColor.withOpacity(0.2),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                  MaterialButton(
                    color: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    splashColor: deleteButtonColor.withOpacity(0.2),
                    onPressed: () {
                      String updatedName = _nameController.text;
                      String? updatedGender = selectedGender;
                      DateTime? dateOfBirth = _selectedDate;
                      _updateUserData(context, id);
                      print('Entered Text: $updatedName');
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: textColor),
                    ),
                  )
                ],
              )
            ],
          );
        });
  }

  _updateUserData(context, String id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      String updatedName = _nameController.text;
      String? updatedGender = selectedGender;
      String dateOfBirth = _dateController.text;

      // Your logic to update data in Firebase
      await updateUserData(context, id, {
        'name': updatedName,
        'gender': updatedGender,
        'dateOfBirth': _selectedDate
      });

      setState(() {
        _isLoading = false; // Hide circular progress indicator
      });

      Navigator.of(context).pop(); // Close the dialog
    } catch (error) {
      setState(() {
        _isLoading = false; // Hide circular progress indicator
      });

      print("Error updating data: $error");
      CustomToast.showToast(
          context, "Failed to update data. Please try again.");
    }
  }

  updateUserData(context, String docId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
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
    _nameController.clear();
    _dateController.clear();
    _selectedDate == null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    print("UserID $userId");
    return Scaffold(
      backgroundColor: primaryColor,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 190,
                width: MediaQuery.of(context).size.width,
                color: primaryColor,
              ),
            ],
          ),
          Expanded(
            child: Container(
              height: height,
              width: width,
              decoration: const BoxDecoration(
                color: textColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.only(left: 30.0, top: 25.0),
                      child: const Text(
                        "My Profile",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'GT Walsheim Trial',
                          color: textBlackColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.only(left: 30.0, top: 5.0),
                      child: Text(
                        "Unveiling my story, one profile update at a time !",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          fontFamily: ' GT Walsheim Trial',
                          color: textBlackColor.withOpacity(0.5),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Gap(20.0),
                    SizedBox(
                      height: 300.0,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('userId', isEqualTo: userId)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: SpinKitCircle(
                                color: primaryColor,
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'No data available',
                                style: TextStyle(
                                    color: textBlackColor, fontSize: 20.0),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              String formattedDate = _formatTimestamp(snapshot
                                      .data!
                                      .docs[index]['dateOfBirth'] as Timestamp? ??
                                  Timestamp.now());

                              name = snapshot.data!.docs[index]['name'];
                              dateOfBirth = formattedDate;
                              gender = snapshot.data!.docs[index]['gender'];
                              id = snapshot.data!.docs[index].id;

                              return SizedBox(
                                height: 280.0,
                                child: Column(
                                  children: [
                                    Card(
                                      color: textColor,
                                      surfaceTintColor: primaryColor,
                                      shadowColor: primaryColor.withOpacity(0.4),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 30.0),
                                      elevation: 8.0,
                                      child: SizedBox(
                                        height: 55.0,
                                        width: width,
                                        child: ListTile(
                                          leading: myProfileData[index]
                                              ['leadingIcon'],
                                          title: Text(
                                            snapshot.data!.docs[index]['name']
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'GT Walsheim Trial',
                                              color:
                                                  textBlackColor.withOpacity(0.7),
                                            ),
                                          ),
                                          // trailing: IconButton(
                                          //   onPressed: () {
                                          //     // _showDialog(
                                          //     //     snapshot.data!.docs[index]['name']
                                          //     //         .toString(),
                                          //     //     snapshot.data!.docs[index].id
                                          //     //         .toString(),
                                          //     //     'name');
                                          //   },
                                          //   icon: Icon(
                                          //     Icons.edit,
                                          //     color: deleteButtonColor
                                          //         .withOpacity(0.9),
                                          //   ),
                                          // ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Card(
                                      color: textColor,
                                      surfaceTintColor: primaryColor,
                                      shadowColor: primaryColor.withOpacity(0.4),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 30.0),
                                      elevation: 8.0,
                                      child: SizedBox(
                                        height: 55.0,
                                        width: width,
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.accessibility_new_sharp,
                                            color: textBlackColor.withOpacity(0.7),
                                          ),
                                          title: Text(
                                            snapshot.data!.docs[index]['gender']
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'GT Walsheim Trial',
                                              color:
                                                  textBlackColor.withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Card(
                                      color: textColor,
                                      surfaceTintColor: primaryColor,
                                      shadowColor: primaryColor.withOpacity(0.4),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 30.0),
                                      elevation: 8.0,
                                      child: SizedBox(
                                        height: 55.0,
                                        width: width,
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.phone_android_rounded,
                                            color: textBlackColor.withOpacity(0.7),
                                          ),
                                          title: Text(
                                            snapshot
                                                .data!.docs[index]['phoneNumber']
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'GT Walsheim Trial',
                                              color:
                                                  textBlackColor.withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Card(
                                      color: textColor,
                                      surfaceTintColor: primaryColor,
                                      shadowColor: primaryColor.withOpacity(0.4),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 30.0),
                                      elevation: 8.0,
                                      child: SizedBox(
                                        height: 55.0,
                                        width: width,
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.date_range_rounded,
                                            color: textBlackColor.withOpacity(0.7),
                                          ),
                                          title: Text(
                                            formattedDate.toString(),
                                            style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'GT Walsheim Trial',
                                              color:
                                                  textBlackColor.withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15.0,),
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
                              _showDialog(name.toString(), dateOfBirth.toString(),
                                  gender.toString(), id.toString(), "name");
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
