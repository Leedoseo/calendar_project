import 'package:calendar_scheduler/component/custom_text_field.dart';
import 'package:calendar_scheduler/constants/colors.dart';
import 'package:calendar_scheduler/model/schedule_modal.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';
import 'package:calendar_scheduler/database/drift_database.dart';
import 'package:flutter/material.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate; // 선택된 날짜 상위 위젯에서 입력받기

  const ScheduleBottomSheet({
    required this.selectedDate,
    Key? key
  }) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey(); // 폼 Key 생성

  int? startTime;
  int? endTime;
  String? content;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom; // 키보드 높이 가져오기

    return Form( // 텍스트 필드를 한 번에 관리할 수 있는 폼
      key: formKey, // Form을 조작할 키 값
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height / 2 + bottomInset, // 화면 절반 높이에 키보드 높이 추가하기
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: bottomInset), // Padding에 키보드 높이를 추기해서 위젯 전반적으로 위로 올려주기
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: "시작 시간",
                          isTime: true,
                          onSaved: (String? val) { // 저장이 실행되면 starTime 변수에 텍스트 필드값 저장
                            startTime = int.parse(val!);
                          },
                          validator: timeValidator,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: CustomTextField(
                          label: "종료 시간",
                          isTime: true,
                          onSaved: (String? val) {
                            endTime = int.parse(val!);
                          },
                          validator: timeValidator,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Expanded(
                    child: CustomTextField(
                      label: "내용",
                      isTime: false,
                      onSaved: (String? val) {
                        content = val;
                      },
                      validator: contentValidator,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton( // 저장 버튼
                      onPressed: () => onSavePressed(context), // 함수에 context전달
                      style: ElevatedButton.styleFrom(
                        foregroundColor: PRIMARY_COLOR,
                      ),
                      child: Text("저장"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  void onSavePressed(BuildContext context) async {
    if (formKey.currentState!.validate()) { // 폼 검증
      formKey.currentState!.save(); // 폼 저장

      final schedule = ScheduleModel( // 스케줄 모델 생성
        id: Uuid().v4(),
        content: content!,
        date: widget.selectedDate,
        startTime: startTime!,
        endTime: endTime!,
      );

      await FirebaseFirestore.instance // 스케줄 모델 파이어스토어에 삽입
          .collection(
            "schedule",
          )
          .doc(schedule.id)
          .set(schedule.toJson());

      Navigator.of(context).pop(); // 일정 생성 후 화면 뒤로 가기
    }
  }
  String? timeValidator(String? val) { // 시간 검증 함수
    if (val == null) {
      return "값을 입력해주세요";
    }

    int? number;

    try {
      number = int.parse(val);
    } catch (e) {
      return "숫자를 입력해주세요";
    }

    if (number < 0 || number > 24) {
      return "0시부터 24시 사이를 입력해주세요";
    }

    return null;
  }

  String? contentValidator(String? val) { // 내용 검증 함수
    if(val == null || val.length == 0) {
      return "값을 입력해주세요";
    }

    return null;
  }
}