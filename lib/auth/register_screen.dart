import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:medallyproapp/providers/register_provider.dart';
import 'package:medallyproapp/widgets/gender_selection.dart';
import 'package:provider/provider.dart';
import '../constants/mycolors.dart';
import '../widgets/my_textformfield.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  var connectivityResult = ConnectivityResult.none;

  DateTime? _selectedDate;
  Gender selectedGender = Gender.male;

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
        dateOfBirthController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final registerProvider = Provider.of<RegisterProvider>(context);
    return Scaffold(
      backgroundColor: primaryColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.0,
        toolbarHeight: 80.0,
        backgroundColor: primaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back, color: textColor,),
        ),
      ),
      body: Stack(
        children: [
          Container(
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
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.only(left: 30.0, top: 40.0),
                      child: const Text(
                        "Register",
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
                        "Create Your Profile !",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          fontFamily: ' GT Walsheim Trial',
                          color: textBlackColor.withOpacity(0.5),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Gap(30.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: MyTextFormField(
                        readOnly: false,
                        controller: nameController,
                        hintText: "Enter your name",
                        labelText: "Enter your name",
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        enabledBorderColor: containerBorderColor,
                        focusedBorderColor: primaryColor,
                      ),
                    ),
                    const Gap(25.0),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    //   child: MyTextFormField(
                    //     controller: phoneNumberController,
                    //     hintText: "Enter phone number",
                    //     labelText: "Enter phone number",
                    //     keyboardType: TextInputType.number,
                    //     validator: (String? value) {
                    //       if (value == null || value.isEmpty) {
                    //         return 'Please enter your phone number';
                    //       } else if (!RegExp(r'^\+?[0-9]+$').hasMatch(value)) {
                    //         return 'Please enter a valid phone number';
                    //       }
                    //       return null;
                    //     },
                    //     enabledBorderColor: containerBorderColor,
                    //     focusedBorderColor: primaryColor,
                    //   ),
                    // ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        cursorColor: Colors.purple,
                        controller: phoneNumberController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: primaryColor),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.only(
                                top: 13.5, left: 10.0, right: 5.0),
                            // Add right padding
                            child: InkWell(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  countryListTheme: const CountryListThemeData(
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
                    ),

                    const Gap(25.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: MyTextFormField(
                        readOnly: false,
                        controller: dateOfBirthController,
                        labelText: "Date of Birth",
                        hintText: "Select Date of Birth",
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please add your date of birth';
                          }
                          return null;
                        },
                        enabledBorderColor: containerBorderColor,
                        focusedBorderColor: primaryColor,
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
                    ),
                    const Gap(30.0),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.only(left: 30.0, top: 5.0),
                      child: Text(
                        "Gender",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'GT Walsheim Trial',
                          color: textBlackColor.withOpacity(0.5),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Gap(10.0),
                    GenderSelection(
                      selectedGender: selectedGender,
                      onGenderChanged: (value) {
                        setState(() {
                          selectedGender =
                              value == 'male' ? Gender.male : Gender.female;
                        });
                      },
                    ),
                    const Gap(70.0),
                  ],
                ),
              ),
            ),
          ),
          // CircularProgressIndicator at the center of the screen
          Center(
            child: Visibility(
              visible: registerProvider.isRegistering,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50, left: 25, right: 25),
        child: Consumer<RegisterProvider>(
          builder: (context, registerProvider, _) => MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            height: 60,
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                if (selectedGender != null) {
                  String genderString =
                      selectedGender == Gender.male ? 'male' : 'female';

                  var result = await Connectivity().checkConnectivity();
                  setState(() {
                    connectivityResult = result;
                  });

                  if (connectivityResult == ConnectivityResult.none) {
                    // No internet connection, show a dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("No Internet"),
                        content: Text("Please check your internet connection."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text("OK"),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Show CircularProgressIndicator
                    registerProvider.isRegistering = true;

                    await registerProvider.registerUser(
                      nameController.text,
                      phoneNumberController.text,
                      _selectedDate!,
                      genderString,
                      context,
                    );
                  }
                }
              }
            },
            color: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "SAVE",
                style: TextStyle(
                  fontSize: 18.0,
                  color: textColor,
                  fontFamily: 'GT Walsheim Trial',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
