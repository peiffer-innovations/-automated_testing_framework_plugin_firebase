import 'dart:convert';
import 'dart:io';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_example/automated_testing_framework_example.dart';
import 'package:automated_testing_framework_plugin_firebase/automated_testing_framework_plugin_firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

void main() async {
  TestAppSettings.initialize(appIdentifier: 'ATF FB');
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      // ignore: avoid_print
      print('${record.error}');
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print('${record.stackTrace}');
    }
  });

  WidgetsFlutterBinding.ensureInitialized();

  final credentials =
      json.decode(await rootBundle.loadString('assets/secrets/login.json'));
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: credentials['username'],
    password: credentials['password'],
  );

  final store = FirebaseTestStore(
    db: FirebaseDatabase.instance,
    storage: FirebaseStorage.instance,
  );

  TestFirebaseHelper.autoformatJson = true;
  TestFirebaseHelper.registerTestSteps();

  var gestures = TestableGestures();
  if (kIsWeb ||
      Platform.isFuchsia ||
      Platform.isLinux ||
      Platform.isMacOS ||
      Platform.isWindows) {
    gestures = TestableGestures(
      widgetLongPress: null,
      widgetSecondaryLongPress: TestableGestureAction.open_test_actions_page,
      widgetSecondaryTap: TestableGestureAction.open_test_actions_dialog,
    );
  }

  runApp(App(
    options: TestExampleOptions(
      autorun: kProfileMode,
      enabled: true,
      gestures: gestures,
      // testReader: AssetTestStore(
      //   testAssetIndex:
      //       'packages/automated_testing_framework_example/assets/all_tests.json',
      // ).testReader,
      testReader: store.testReader,
      testReporter: store.testReporter,
      testWidgetsEnabled: true,
      testWriter: store.testWriter,
    ),
  ));
}
