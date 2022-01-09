import 'package:bibit_test_apps/utils/text_styles.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Loading..',
        style: notoSerifDefaultWhite,
      ),
    );
  }
}
// ignore_for_file: unused_field, prefer_const_constructors_in_immutables, prefer_final_fields, prefer_const_constructors, unnecessary_cast, avoid_function_literals_in_foreach_calls, prefer_is_empty, avoid_print, unnecessary_const, sized_box_for_whitespace,  unnecessary_this, curly_braces_in_flow_control_structures
