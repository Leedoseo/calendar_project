import 'package:calendar_scheduler/component/main_calendar.dart';
import 'package:calendar_scheduler/component/schedule_card.dart';
import 'package:calendar_scheduler/component/today_banner.dart';
import 'package:calendar_scheduler/component/schedule_bottom_sheet.dart';
import 'package:calendar_scheduler/constants/colors.dart';
import 'package:calendar_scheduler/component/today_banner.dart';
import 'package:provider/provider.dart'; // Provider 불러오기
import 'package:calendar_scheduler/provider/schedule_provider.dart';
import 'package:calendar_scheduler/database/drift_database.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    // Provider 상태 구독
    final provider = context.watch<ScheduleProvider>(); // Provider 변경이 있을 때마다 build() 함수 재실행
    final selectedDate = provider.selectedDate; // 선택된 날짜 가져오기
    final schedules = provider.cache[selectedDate] ?? []; // 선택된 날짜에 해당하는 일정 가져오기

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          showModalBottomSheet( // BottomSheet 모달창으로 열기
            context: context,
            isDismissible: true, // 배경 탭했을 때 BottomSheet 닫기
            builder: (_) => ScheduleBottomSheet(
              selectedDate: selectedDate, // 선택된 날짜 (selectedDate) 넘겨주기
            ),
            isScrollControlled: true, // BottomSheet의 높이를 화면의 최대 높이로 정의하고 스크롤 가능하게 변경
          );
        },
        child: Icon(
          Icons.add,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MainCalendar(
              selectedDate: selectedDate,
              onDaySelected: (selectedDate, focusedDate) => onDaySelected(selectedDate, focusedDate, context),
            ),
            SizedBox(height: 8.0),

            TodayBanner(
                selectedDate: selectedDate,
                count: schedules.length,
            ),
            SizedBox(height: 8.0),

            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];

                  return Dismissible(
                    key: ObjectKey(schedule.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (DismissDirection direction) {
                      provider.deleteSchedule(date: selectedDate, id: schedule.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8.0, left: 8.0, right: 8.0
                      ),
                      child: ScheduleCard(
                        startTime: schedule.startTime,
                        endTime: schedule.endTime,
                        content: schedule.content,
                      ),
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onDaySelected(
      DateTime selectedDate,
      DateTime foucusedDate,
      BuildContext context,
      ) {
    final provider = context.read<ScheduleProvider>();
    provider.changeSelectedDate(
      date: selectedDate,
    );
    provider.getSchedules(date: selectedDate);
  }
}