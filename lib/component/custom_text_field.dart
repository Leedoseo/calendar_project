import 'package:calendar_scheduler/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;

  const CustomTextField({
    required this.label,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: PRIMARY_COLOR,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextFormField(), // 폼 안에서 텍스트 필드를 쓸 때 사용
      ],
    );
  }
}