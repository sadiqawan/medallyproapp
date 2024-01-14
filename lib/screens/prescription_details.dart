import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medallyproapp/screens/mydrawer_screen.dart';
import '../constants/mycolors.dart';
import '../widgets/glowingfloatingbutton.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  const PrescriptionDetailScreen({super.key});

  @override
  State<PrescriptionDetailScreen> createState() =>
      _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: primaryColor,
        key: _scaffoldKey,
        drawer: const MyDrawerScreen(),
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
                          Navigator.pop(context);
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
                            child: Image.asset(
                              "assets/images/preimage.png",
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              height: 30,
                            )),
                      ),
                      SizedBox(
                        height: height,
                        width: 150,
                        child: ListTile(
                          title: const Text(
                            "Sonu Kumar Gad",
                            style: TextStyle(
                                color: primaryColor,
                                fontFamily: 'GT Walsheim Trial',
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "Dr Sunil Parik",
                            style: TextStyle(
                              color: textBlackColor.withOpacity(0.3),
                              fontFamily: 'GT Walsheim Trial',
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 25,
                          width: 50,
                          alignment: Alignment.topRight,
                          margin: const EdgeInsets.only(right: 25),
                          child: const Text(
                            "Stop",
                            style: TextStyle(
                              color: deleteButtonColor,
                              fontFamily: 'GT Walsheim Trial',
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const Gap(20),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 20.0);
                    },
                    physics: const BouncingScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 215.0,
                        width: width,
                        margin: const EdgeInsets.symmetric(horizontal: 25.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                                color: containerBorderColor.withOpacity(0.3),
                                width: 1.0)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, left: 8.0),
                                  child: CircleAvatar(
                                      radius: 12.0,
                                      backgroundColor:
                                          primaryColor.withOpacity(0.2),
                                      child: Image.asset(
                                        "assets/images/preimage2.png",
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                        height: 100,
                                      )),
                                ),
                                Center(
                                  child: Container(
                                    width: 150, // Set your specific width
                                    padding: const EdgeInsets.only(
                                        top: 15.0, right: 25.0),
                                    decoration: const BoxDecoration(),
                                    child: const Text(
                                      'Dollo 650mg Tab Hello',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding:
                                      EdgeInsets.only(right: 30.0, top: 15.0),
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'GT Walsheim Trial',
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding:
                                      EdgeInsets.only(right: 30.0, top: 15.0),
                                  child: Text(
                                    "Stop",
                                    style: TextStyle(
                                      color: deleteButtonColor,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'GT Walsheim Trial',
                                      fontSize: 14.0,
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
                                  // color: Colors.red,
                                  child: Text(
                                    "Time",
                                    style: TextStyle(
                                      color: textBlackColor.withOpacity(0.3),
                                      fontFamily: 'GT Walsheim Trial',
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 90,
                                ),
                                Container(
                                  height: 20.0,
                                  width: 90.0,
                                  // color: Colors.yellow,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Intake",
                                    style: TextStyle(
                                      color: textBlackColor.withOpacity(0.3),
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
                                    // color: Colors.green,
                                    child: Text(
                                      "Duration",
                                      style: TextStyle(
                                        color: textBlackColor.withOpacity(0.3),
                                        fontFamily: 'GT Walsheim Trial',
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const Gap(5.0),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Container(
                                  width: 140.0,
                                  alignment: Alignment.center,
                                  // color: Colors.red,
                                  child: const Text(
                                    "09:00 am  12:00 pm\n05:00 pm",
                                    style: TextStyle(
                                      color: textBlackColor,
                                      fontFamily: 'GT Walsheim Trial',
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  height: 20.0,
                                  width: 90.0,
                                  // color: Colors.yellow,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "1 PILL",
                                    style: TextStyle(
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
                                    // color: Colors.green,
                                    child: const Text(
                                      "3 days",
                                      style: TextStyle(
                                        color: textBlackColor,
                                        fontFamily: 'GT Walsheim Trial',
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const Gap(5),
                            ListTile(
                              title: const Text(
                                "After lunch",
                                style: TextStyle(
                                  color: textBlackColor,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'GT Walsheim Trial',
                                  fontSize: 14.0,
                                ),
                              ),
                              subtitle: Text(
                                "Notes",
                                style: TextStyle(
                                  color: textBlackColor.withOpacity(0.3),
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
              ],
            ),
          ),
        ),
        floatingActionButton: GlowingFloatingActionButton(
          onPressed: () {},
        ));
  }
}
