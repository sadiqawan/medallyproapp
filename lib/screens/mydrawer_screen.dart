import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medallyproapp/constants/mycolors.dart';
import 'package:medallyproapp/screens/add_prescription.dart';
import 'package:medallyproapp/screens/members_list.dart';
import 'package:medallyproapp/screens/profile_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../auth/auth_manager_class.dart';
import '../auth/login_screen.dart';
import '../sharedpreference/share_preference.dart';

class MyDrawerScreen extends StatefulWidget {
  MyDrawerScreen({super.key});

  @override
  State<MyDrawerScreen> createState() => _MyDrawerScreenState();
}

class _MyDrawerScreenState extends State<MyDrawerScreen> {
  String? userId = MySharedPrefClass.preferences?.getString("UserID");

  late String name = "";
  late String phoneNumber = "";
  bool isDataLoaded = false;

  void fetchDataFromFirebase() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Assuming 'name' and 'phoneNumber' are the field names in your Firestore document
        name = snapshot.docs[0]['name'];
        phoneNumber = snapshot.docs[0]['phoneNumber'];

        // Print the retrieved data (for debugging purposes)
        print("Name: $name");
        print("Phone Number: $phoneNumber");

        // Update the state to reflect changes in the UI
        setState(() {
          isDataLoaded = true;
        });
      } else {
        // Handle the case where no data is found
        print("No data found in Firestore");
      }
    } catch (error) {
      // Handle errors during data retrieval
      print("Error fetching data: $error");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDataFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/splashbackground.png"),
                filterQuality: FilterQuality.high,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/drawerupper.png"),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high)),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(top: 85.0, left: 30.0),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      border: Border.all(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(100.0),
                      boxShadow: const [
                        BoxShadow(
                          color: primaryColor,
                          spreadRadius: 2.0,
                          blurRadius: 0.0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'MedallyPro',
                        style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 80.0, left: 90.0),
                    child: ListTile(
                      title: isDataLoaded
                          ? Text(
                              name,
                              style: const TextStyle(
                                fontSize: 17.0,
                                color: primaryColor,
                                fontFamily: 'GT Walsheim Trial',
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: const Text("Loading..."),
                            ),
                      subtitle: isDataLoaded
                          ? Text(
                              phoneNumber,
                              style: const TextStyle(
                                fontSize: 17.0,
                                color: primaryColor,
                                fontFamily: 'GT Walsheim Trial',
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: const Text("Loading..."),
                            ),
                    ),
                  )
                ],
              ),
              const Gap(30),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Image.asset(
                      "assets/icons/personicon.png",
                      height: 25.0,
                    ),
                    title: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 17.0,
                        color: textColor,
                        fontFamily: 'GT Walsheim Trial',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MembersListScreen(),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Image.asset(
                      "assets/icons/managememicon.png",
                      height: 25.0,
                    ),
                    title: const Text(
                      "Manage Members",
                      style: TextStyle(
                        fontSize: 17.0,
                        color: textColor,
                        fontFamily: 'GT Walsheim Trial',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddPrescriptionScreen(),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Image.asset(
                      "assets/icons/prescriptionicon.png",
                      height: 25.0,
                    ),
                    title: const Text(
                      "Add Prescription",
                      style: TextStyle(
                        fontSize: 17.0,
                        color: textColor,
                        fontFamily: 'GT Walsheim Trial',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 20.0),
              //   child: ListTile(
              //     leading: Image.asset(
              //       "assets/icons/settingicon.png",
              //       height: 25.0,
              //     ),
              //     title: const Text(
              //       "Reminder Settings",
              //       style: TextStyle(
              //         fontSize: 17.0,
              //         color: textColor,
              //         fontFamily: 'GT Walsheim Trial',
              //         fontWeight: FontWeight.w400,
              //       ),
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 20.0),
              //   child: ListTile(
              //     leading: Image.asset(
              //       "assets/icons/abouticon.png",
              //       height: 25.0,
              //     ),
              //     title: const Text(
              //       "About",
              //       style: TextStyle(
              //         fontSize: 17.0,
              //         color: textColor,
              //         fontFamily: 'GT Walsheim Trial',
              //         fontWeight: FontWeight.w400,
              //       ),
              //     ),
              //   ),
              // ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 30.0),
                child: ListTile(
                  onTap: () async {
                    // Set login status to false
                    await AuthManager.setLoggedIn(false);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  },
                  leading: Image.asset(
                    "assets/icons/logouticon.png",
                    height: 25.0,
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 17.0,
                      color: textColor,
                      fontFamily: 'GT Walsheim Trial',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
