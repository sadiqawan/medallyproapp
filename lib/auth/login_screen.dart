import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:medallyproapp/auth/register_screen.dart';
import 'package:medallyproapp/providers/otp_provider.dart';
import 'package:provider/provider.dart';
import '../constants/mycolors.dart';
import '../providers/register_provider.dart';
import '../sharedpreference/share_preference.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isChecked = false;
  bool? isUserRegistered;
  late final loginProvider;
  bool isLoading = false;
  String? userNamePersonal;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginProvider = Provider.of<OtpNotifier>(context, listen: false);
  }



  // TODO SELECTED COUNTRY
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

  // TODO CHECK REGISTRATION STATUS METHOD
  Future<bool> checkRegistrationStatus(String phoneNumber) async {
    print("Phone $phoneNumber");
    // String modifiedPhoneNumber = "0$phoneNumber";
    String modifiedPhoneNumber = phoneNumber;
    print("modifiedPhoneNumber $modifiedPhoneNumber");
    Future<bool> isUserRegistered =
        Provider.of<RegisterProvider>(context, listen: false)
            .isUserRegistered(modifiedPhoneNumber);
    return isUserRegistered;
  }

// TODO UPDATE LOGIN BUTTON HANDLER METHOD
  void _loginButtonHandler() async {

    setState(() {
      isLoading = true;
    });

    String phoneNumber = phoneNumberController.text.trim();

    if (!isChecked) {
      // Show a SnackBar if terms and conditions are not agreed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Please agree to the terms and conditions and register yourself first"),
        ),
      );
      _hideLoadingIndicator();
      return;
    }

    // Check if the user is registered
    isUserRegistered = await checkRegistrationStatus(phoneNumber);

    if (!isUserRegistered!) {
      // Show a SnackBar if the user is not registered
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not registered. Please register first."),
        ),
      );
      _hideLoadingIndicator();
      return;
    }

    if (selectedCountry != null && phoneNumber.isNotEmpty) {
      String formattedPhoneNumber = "+${selectedCountry.phoneCode}$phoneNumber";

      await Future.delayed(const Duration(seconds: 2));

      _hideLoadingIndicator();

      loginProvider.signInWithPhoneNumber(formattedPhoneNumber, context);
    } else {
      // Show a SnackBar if the phone number is not valid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid phone number"),
        ),
      );
      _hideLoadingIndicator();
    }
  }


  void _hideLoadingIndicator() {
    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    phoneNumberController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: phoneNumberController.text.length,
      ),
    );


    return Scaffold(
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.fill,
                  image: AssetImage("assets/images/splashbackground.png"),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 160.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: Text(
                            'Medallypro',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30.0,
                              color: textColor,
                              letterSpacing: 0.7,
                              fontFamily: 'GT Walsheim Trial',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60.0),
                          topRight: Radius.circular(60.0),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30.0, top: 70.0),
                              child: Row(
                                children: [
                                  const Text(
                                    "Welcome back !",
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      color: textBlackColor,
                                      letterSpacing: 0.5,
                                      fontFamily: 'GT Walsheim Trial',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    child: Image.asset(
                                      "assets/icons/wavinghand.png",
                                      height: 25,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30.0, top: 5.0),
                              child: Text(
                                "Login To Your Account",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: textBlackColor.withOpacity(0.5),
                                  letterSpacing: 0.4,
                                  fontFamily: 'GT Walsheim Trial',
                                ),
                              ),
                            ),
                            const Gap(30),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              child: TextFormField(
                                cursorColor: Colors.purple,
                                controller: phoneNumberController,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                style: const TextStyle(
                                  color: textBlackColor,
                                  fontWeight: FontWeight.w400,
                                ),
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
                                    borderSide:
                                        const BorderSide(color: primaryColor),
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
                                  suffixIcon:
                                      phoneNumberController.text.length > 9
                                          ? Container(
                                              height: 30,
                                              width: 30,
                                              margin:
                                                  const EdgeInsets.all(10.0),
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
                            const Gap(15.0),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    activeColor: primaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        isChecked = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    "I agree to the terms & conditions\nand privacy policy",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: textBlackColor.withOpacity(0.8),
                                      letterSpacing: 0.4,
                                      fontFamily: 'GT Walsheim Trial',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(60),
                            GestureDetector(
                              onTap: _loginButtonHandler,
                              child: CustomButton(text: "SEND OTP"),
                            ),
                            const Gap(50),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: const Text(
                                  "Register Now",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: primaryColor,
                                    fontFamily: 'GT Walsheim Trial',
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: isLoading,
              child: Container(
                color: textBlackColor.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
