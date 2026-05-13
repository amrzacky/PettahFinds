import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // App Check — debug provider in debug builds (so emulator/CI keep working
  // without Play Integrity / DeviceCheck), Play Integrity / DeviceCheck for
  // release. Failures are swallowed so a broken provider never blocks
  // launch — backend enforcement is the source of truth.
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? AndroidDebugProvider()
          : AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? AppleDebugProvider()
          : AppleDeviceCheckProvider(),
    );
  } catch (_) {
    // App Check init failed (no token, network blip, unsupported platform).
    // App still runs; rules will gate writes once Enforce is on in console.
  }

  runApp(const ProviderScope(child: PetaFindsApp()));
}

class PetaFindsApp extends ConsumerWidget {
  const PetaFindsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}