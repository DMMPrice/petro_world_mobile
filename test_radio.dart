import 'package:flutter/material.dart';

void main() {}

Widget test() {
  return RadioGroup<String>(
    groupValue: 'test',
    onChanged: (v) {},
    child: Radio<String>(
      value: 'test',
      activeColor: Colors.blue,
    ),
  );
}
