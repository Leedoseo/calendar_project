import 'dart:async';
import 'dart:io';
import 'package:calendar_scheduler/model/schedule_modal.dart';
import 'package:dio/dio.dart';

class ScheduleRepository {
  final _dio = Dio();
  final _targetUrl = "http://${Platform.isAndroid ? "10.0.2.2" : "localhost"}:3000/schedule";

  Future<List<ScheduleModel>> getSchedules({ // REST API요청 기반 특정 날짜의 일정들을 불러오는 함수
    required DateTime date,
  }) async {
    final resp = await _dio.get(
      _targetUrl,
      queryParameters: { // Query 매개변수
        "date" : "${date.year}${date.month.toString().padLeft(2, "0")}${date.day.toString().padLeft(2, "0")}",
      },
    );

    return resp.data
        .map<ScheduleModel>(
        (x) => ScheduleModel.fromJson(
            json: x,
        ),
    )
        .toList();
  }

  Future<String> createSchedule({ // 새로운 일정을 생성하는 함수
    required ScheduleModel schedule,
  }) async {
    final json = schedule.toJson(); // Json으로 변환
    final resp = await _dio.post(_targetUrl, data:json);

    return resp.data?["id"];
  }

  Future<String> deleteSchedule({ // 일정을 삭제하는 함수
    required String id,
  }) async {
    final resp = await _dio.delete(_targetUrl, data: {
      "id" : id, // 삭제할 id값
    });

    return resp.data?["id"];
  }
}