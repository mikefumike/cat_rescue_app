import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cat_rescue_app/models/cat_model.dart';
import 'package:cat_rescue_app/models/medical_record_model.dart';
import 'package:cat_rescue_app/models/user_model.dart';
import 'package:cat_rescue_app/models/adoption_model.dart';
import 'package:cat_rescue_app/models/growth_photo_model.dart';
import 'package:cat_rescue_app/services/database_service.dart';
import 'package:cat_rescue_app/services/auth_service.dart';
import 'package:cat_rescue_app/services/media_storage_service.dart';
import 'package:cat_rescue_app/screens/login_screen.dart';
import 'package:cat_rescue_app/screens/home_screen.dart';
import 'package:cat_rescue_app/screens/cat_list_screen.dart';
import 'package:cat_rescue_app/screens/add_edit_cat_screen.dart';
import 'package:cat_rescue_app/screens/cat_detail_screen.dart';
import 'package:cat_rescue_app/screens/add_edit_medical_record_screen.dart';
import 'package:cat_rescue_app/screens/medical_record_screen.dart';
import 'package:cat_rescue_app/screens/medical_calendar_screen.dart';
import 'package:cat_rescue_app/screens/adoption_screen.dart';
import 'package:cat_rescue_app/screens/add_edit_adoption_screen.dart';
import 'package:cat_rescue_app/screens/adoption_detail_screen.dart';
import 'package:cat_rescue_app/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CatModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MedicalRecordModelAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserRoleAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(UserModelAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(AdoptionModelAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(GrowthPhotoModelAdapter());

  await DatabaseService().init();
  await AuthService().init();
  await MediaStorageService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '光影爱宠',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('zh', 'CN'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8C42),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // 单机版：直接进入首页，无需登录
      home: const HomeScreen(),
      routes: {
        '/login':        (_) => const LoginScreen(),
        '/home':         (_) => const HomeScreen(),
        '/cat-list':     (_) => const CatListScreen(),
        '/add-cat':      (_) => const AddEditCatScreen(),
        '/cat-detail':   (ctx) => CatDetailScreen(
          catId: ModalRoute.of(ctx)!.settings.arguments as String,
        ),
        '/add-medical':  (ctx) => AddEditMedicalRecordScreen(
          catId: ModalRoute.of(ctx)!.settings.arguments as String,
        ),
        '/medical-records': (ctx) => MedicalRecordScreen(
          catId: ModalRoute.of(ctx)!.settings.arguments as String,
        ),
        '/medical-calendar': (_) => const MedicalCalendarScreen(),
        '/adoption':         (_) => const AdoptionScreen(),
        '/add-adoption':     (ctx) => AddEditAdoptionScreen(
          adoptionId: ModalRoute.of(ctx)!.settings.arguments as String?,
        ),
        '/adoption-detail':  (ctx) => AdoptionDetailScreen(
          adoptionId: ModalRoute.of(ctx)!.settings.arguments as String,
        ),
        '/settings':     (_) => const SettingsScreen(),
      },
    );
  }
}

// 全局工具方法
void showLoading([String? message]) {
  Fluttertoast.showToast(msg: message ?? '加载中...', toastLength: Toast.LENGTH_SHORT);
}

void hideLoading() {
  Fluttertoast.cancel();
}

void showSuccess(String message) {
  Fluttertoast.showToast(msg: message, backgroundColor: Colors.green);
}

void showError(String message) {
  Fluttertoast.showToast(msg: message, backgroundColor: Colors.red);
}

void showInfo(String message) {
  Fluttertoast.showToast(msg: message);
}
