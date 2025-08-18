import 'package:calendar_scheduler/model/schedule_modal.dart';
import 'package:calendar_scheduler/repository/schedule_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleRepository repository; // API 요청 로직을 담은 클래스

  DateTime selectedDate = DateTime.utc( // 선택한 날짜
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  Map<DateTime, List<ScheduleModel>> cache = {}; // 일정 정보를 저장해둘 변수

  ScheduleProvider({ // 생성자 부분
    required this.repository,
  }) : super() {
    getSchedules(date: selectedDate);
  }

  void getSchedules({ // 일정 가져오기 -> Read
    required DateTime date,
  }) async {
    final resp = await repository.getSchedules(date: date); // GET 메서드 보내기

    cache.update(date, (value) => resp, ifAbsent: () => resp); // 선택한 날짜의 일정들 업데이트하기

    notifyListeners(); // 리슨하는 위젯들 업데이트 하기
  }

  void createSchedule({ // 일정 추가하기 -> Create
    required ScheduleModel schedule,
  }) async {
    final targetDate = schedule.date;

    final savedSchedule = await repository.createSchedule(schedule: schedule);

    cache.update(
      targetDate, (value) => [ // 현존하는 캐시 리스트 끝에 새로운 일정 추가
        ...value,
      schedule.copyWith(
        id: savedSchedule,
      ),
    ]..sort(
        (a, b) => a.startTime.compareTo(
            b.startTime,
        ),
      ),
      ifAbsent: () => [schedule], // 날짜에 해당되는 값이 없다면 새로운 리스트에 새로운 일정 하나만 추가
    );

    notifyListeners();
  }

  void deleteSchedule({ // 일정 삭제하기 -> Deleted
    required DateTime date,
    required String id,
  }) async {
    final resp = await repository.deleteSchedule(id: id);

    cache.update(
      date,
        (value) => value.where((e) => e.id != id).toList(),
      ifAbsent: () => [],
    );

    notifyListeners();
  }

  void changeSelectedDate({ // 선택된 날짜 변경
    required DateTime date,
  }) {
    selectedDate = date;
    notifyListeners();
  }
}