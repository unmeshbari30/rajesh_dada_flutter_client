import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rajesh_dada_padvi/controllers/authentication_controller.dart';
import 'package:rajesh_dada_padvi/l10n/app_localizations.dart';
import 'package:rajesh_dada_padvi/providers/locale_provider.dart';
import 'package:rajesh_dada_padvi/providers/theme_provider.dart';
import 'package:rajesh_dada_padvi/screen/Login_Screens/login_screen.dart';
import 'package:rajesh_dada_padvi/screen/Notification/notification_handler.dart';
import 'package:rajesh_dada_padvi/screen/home_screen.dart';
import 'package:rajesh_dada_padvi/theme/app_theme.dart';
import 'package:upgrader/upgrader.dart';

// OPTIONAL: Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle the background message (e.g., show notification, update DB)
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp();

  // ✅ Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Optional: Request permission (important for iOS, useful for Android 13+)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );

  AuthenticationController mainController = AuthenticationController();
  bool isLoggedIn = await mainController.checkIsLogin();
  runApp(ProviderScope(child: MyApp(isLoggedIn: isLoggedIn)));
}

class MyApp extends ConsumerWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return FCMHandler(
      child: MaterialApp(
        title: 'Rajesh Dada Padvi',
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init(),
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: themeMode,
        locale: locale,
        supportedLocales: const [Locale('mr'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: UpgradeAlert(
          showReleaseNotes: false,
          child: isLoggedIn ? HomeScreen() : LoginScreen()
        ),
      ),
    );
  }
}
