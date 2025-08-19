import 'package:calendar_scheduler/model/schedule_modal.dart';
import 'package:calendar_scheduler/repository/schedule_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

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

    final uuid = Uuid();

    final tempId = uuid.v4(); // 유일한 ID값 생성
    final newSchedule = schedule.copyWith( // 임시 ID를 지정
      id: tempId,
    );

    cache.update( // 서버에서 응답받기 전에 캐시를 먼저 업데이트
      targetDate,
        (value) => [
          ...value,
          newSchedule,
        ]..sort(
            (a, b) => a.startTime.compareTo(
              b.startTime,
            ),
        ),
      ifAbsent: () => [newSchedule],
    );

    notifyListeners(); // 캐시 업데이트 반영

    try {
      final savedSchedule = await repository.createSchedule(schedule: schedule); // API 요청

      cache.update( // 서버 응답 기반으로 캐시 업데이트
        targetDate,
          (value) => value
              .map((e) => e.id == tempId ? e.copyWith(id: savedSchedule,
          )
          :e)
          .toList(),
      );
    } catch (e) {
      cache.update( // 삭제 실패 시 캐시 롤백
        targetDate,
          (value) => value.where((e) => e.id != tempId).toList(),
      );
    }
  }

  void deleteSchedule({ // 일정 삭제하기 -> Deleted
    required DateTime date,
    required String id,
  }) async {
    final targetSchedule = cache[date]!.firstWhere( // 삭제할 일정 기억
        (e) => e.id == id,
    );

    cache.update( // 응답 전에 캐시 먼저 업데이트
      date,
        (value) => value.where((e) => e.id != id).toList(),
      ifAbsent: () => [],
    );

    notifyListeners(); // 캐시 업데이트 반영

    try {
      await repository.deleteSchedule(id: id); // 삭제 함수 실행
    } catch (e) {
      cache.update( // 삭제 실패시 캐시 롤백
        date,
          (value) => [...value, targetSchedule]..sort(
              (a, b) => a.startTime.compareTo(
                  b.startTime
              ),
         ),
      );
    }
    notifyListeners();
  }


  void changeSelectedDate({ // 선택된 날짜 변경
    required DateTime date,
  }) {
    selectedDate = date;
    notifyListeners();
  }
}