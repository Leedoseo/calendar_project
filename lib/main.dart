import 'package:calendar_scheduler/screen/home_screen.dart';
import 'package:calendar_scheduler/database/drift_database.dart';
import 'package:calendar_scheduler/provider/schedule_provider.dart';
import 'package:calendar_scheduler/repository/schedule_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:calendar_scheduler/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 플러터 프레임워크가 준비될 때까지 대기

  await Firebase.initializeApp( // 파이어베이스 프로젝트 설정 함수
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting(); // intl 패키지 초기화(다국어화)

  final database = LocalDatabase(); // 데이터베이스 생성

  GetIt.I.registerSingleton<LocalDatabase>(database); // GetIt에 데이터베이스 변수 주입

  final repository = ScheduleRepository();
  final scheduleProvider = ScheduleProvider(repository: repository);

  runApp(
    ChangeNotifierProvider(
      create: (_) => scheduleProvider,
      child: MaterialApp(
        home: HomeScreen(),
      ),
    ),
  );
}