import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../constants/mycolors.dart';
import '../sharedpreference/share_preference.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User? user = FirebaseAuth.instance.currentUser;
  String? userId = MySharedPrefClass.preferences?.getString("UserID");
  final TextEditingController _textEditingController = TextEditingController();

  // Format The Date
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat.yMMMMd().format(dateTime);
  }

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

  Future<void> updateUserData(
      String docId, Map<String, dynamic> newData) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(docId)
        .update(newData);
  }

  // TODO Show DialogBox
  void _showDialog(String initialText, String id, String fieldName) {
    _textEditingController.text = initialText;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update Data'),
            content: TextFormField(
              controller: _textEditingController,
              decoration: const InputDecoration(labelText: "Update your Data"),
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
                      String changedText = _textEditingController.text;
                      updateUserData(id, {fieldName: changedText});
                      print('Entered Text: $changedText');
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
              Padding(
                padding: const EdgeInsets.only(top: 60.0, left: 15.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: textColor),
                ),
              )
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
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(left: 30.0, top: 40.0),
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
                  const Gap(40.0),
                  Expanded(
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

                            return Column(
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
                                      trailing: IconButton(
                                        onPressed: () {
                                          _showDialog(
                                              snapshot.data!.docs[index]['name']
                                                  .toString(),
                                              snapshot.data!.docs[index].id
                                                  .toString(),
                                              'name');
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          color: deleteButtonColor
                                              .withOpacity(0.9),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30.0,
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
                                      trailing: IconButton(
                                        onPressed: () {
                                          _showDialog(
                                              snapshot.data!.docs[index]['gender']
                                                  .toString(),
                                              snapshot.data!.docs[index].id
                                                  .toString(),
                                              'gender');
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          color: deleteButtonColor
                                              .withOpacity(0.9),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30.0,
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
                                  height: 30.0,
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
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
