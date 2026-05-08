import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

// Just for demo
const productDemoImg1 = "https://i.imgur.com/CGCyp1d.png";
const productDemoImg2 = "https://i.imgur.com/AkzWQuJ.png";
const productDemoImg3 = "https://i.imgur.com/J7mGZ12.png";
const productDemoImg4 = "https://i.imgur.com/q9oF9Yq.png";
const productDemoImg5 = "https://i.imgur.com/MsppAcx.png";
const productDemoImg6 = "https://i.imgur.com/JfyZlnO.png";

// End For demo

const grandisExtendedFont = "Grandis Extended";

// On color 80, 60.... those means opacity

// Amazon-inspired color palette
const Color primaryColor = Color(0xFFFF9900); // Amazon Orange

const MaterialColor primaryMaterialColor =
    MaterialColor(0xFFFF9900, <int, Color>{
  50: Color(0xFFFFF4E0),
  100: Color(0xFFFFE4B3),
  200: Color(0xFFFFD280),
  300: Color(0xFFFFBF4D),
  400: Color(0xFFFFB026),
  500: Color(0xFFFF9900),
  600: Color(0xFFE68A00),
  700: Color(0xFFCC7A00),
  800: Color(0xFFB36B00),
  900: Color(0xFF995C00),
});

const Color navyColor = Color(0xFF232F3E); // Amazon Navy

const Color blackColor = Color(0xFF111111);
const Color blackColor80 = Color(0xFF404040);
const Color blackColor60 = Color(0xFF707070);
const Color blackColor40 = Color(0xFFA0A0A0);
const Color blackColor20 = Color(0xFFD0D0D0);
const Color blackColor10 = Color(0xFFE8E8E8);
const Color blackColor5 = Color(0xFFF3F3F3);

const Color whiteColor = Colors.white;
const Color whileColor80 = Color(0xFFCCCCCC);
const Color whileColor60 = Color(0xFF999999);
const Color whileColor40 = Color(0xFF666666);
const Color whileColor20 = Color(0xFF333333);
const Color whileColor10 = Color(0xFF191919);
const Color whileColor5 = Color(0xFF0D0D0D);

const Color greyColor = Color(0xFFB8B5C3);
const Color lightGreyColor = Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF1C1C25);

const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

const double defaultPadding = 16.0;
const double defaultBorderRadius = 12.0;
const Duration defaultDuration = Duration(milliseconds: 300);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(8, errorText: 'password must be at least 8 digits long'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])',
      errorText: 'passwords must have at least one special character')
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: "Enter a valid email address"),
]);

const pasNotMatchErrorText = "passwords do not match";
