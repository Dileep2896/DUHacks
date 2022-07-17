import 'package:evon_merchant/utils/style.dart';
import 'package:flutter/material.dart';

double kInputFormBR = 15;

var kInputDecoration = const InputDecoration(
  contentPadding: EdgeInsets.symmetric(
    vertical: 10.0,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(20.0),
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(
        20,
      ),
    ),
    borderSide: BorderSide(
      color: textGrey,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(
        20,
      ),
    ),
    borderSide: BorderSide(
      color: primaryColor,
    ),
  ),
  focusColor: primaryColor,
  labelText: 'Enter a Value',
  labelStyle: TextStyle(
    color: textGrey,
  ),
  floatingLabelStyle: TextStyle(
    color: primaryColor,
  ),
);

var kFormInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(
    vertical: 20.0,
    horizontal: 10,
  ),
  border: OutlineInputBorder(
    gapPadding: 8,
    borderRadius: BorderRadius.all(
      Radius.circular(kInputFormBR),
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(
        kInputFormBR,
      ),
    ),
    borderSide: const BorderSide(
      color: textGrey,
    ),
  ),
  focusColor: primaryColor,
  labelText: 'Enter a Value',
  hintText: "Dileep Kumar Sharma",
  labelStyle: const TextStyle(
    color: textGrey,
  ),
  floatingLabelStyle: const TextStyle(
    color: primaryColor,
  ),
);

double kTextFieldHeight = 60;

var kHeadline = const TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.bold,
  color: primaryColor,
);

var kBodyText2 = const TextStyle(
  fontSize: 25,
  color: Colors.white,
);

var kErrorStyle = const TextStyle(
  color: Colors.redAccent,
  fontWeight: FontWeight.bold,
);

final Map<String, List<Map<String, String>>> vehicals = {
  "OLA": [
    {"title": "Model", "info": "S1 PRO"},
    {"title": "Range", "info": "181 Km"},
    {"title": "Motor", "info": "5.5/8.5 kW"},
    {"title": "Reg.No", "info": "KA03MK1112"},
  ],
  "Ather": [
    {"title": "Model", "info": "450X"},
    {"title": "Range", "info": "116 Km"},
    {"title": "Motor", "info": "6 kW"},
    {"title": "Reg.No", "info": "KA09AA2222"},
  ],
};

final List<Map<String, dynamic>> searchResults = [
  {
    "index": 0,
    "title": "Free Chargers",
    "loc": "Reva University",
    "stars": 3,
    "distance": 50,
    "avail": 2,
    "isHomeCharger": true,
    "isFastCharger": false,
  },
  {
    "index": 1,
    "title": "Ola Chargers",
    "loc": "Yelhanka",
    "stars": 4,
    "distance": 200,
    "avail": 1,
    "isHomeCharger": true,
    "isFastCharger": true,
  },
  {
    "index": 2,
    "title": "Ather Grid",
    "loc": "M S Palya",
    "stars": 4,
    "distance": 70,
    "avail": 5,
    "isHomeCharger": true,
    "isFastCharger": true,
  },
  {
    "index": 3,
    "title": "Dileep Kumar",
    "loc": "Shambhram College",
    "stars": 5,
    "distance": 100,
    "avail": 3,
    "isHomeCharger": true,
    "isFastCharger": true,
  },
  {
    "index": 4,
    "title": "EVon Chargers",
    "loc": "Vidyaranyapuram",
    "stars": 5,
    "distance": 550,
    "avail": 6,
    "isHomeCharger": false,
    "isFastCharger": true,
  },
];
