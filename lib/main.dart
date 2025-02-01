// to run on ios flutter run --enable-software-rendering
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:clean_run/runs.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:clean_run/model/app_state.dart';
import 'package:clean_run/redux/reducers.dart';
import 'package:clean_run/navigation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'clean_run_themes.dart';
import 'constants.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'package:background_location/background_location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  var initializedThemeMode = true;
  WidgetsFlutterBinding.ensureInitialized();
  final persistor = Persistor<AppState>(
      storage: FlutterStorage(
          location: FlutterSaveLocation.sharedPreferences, key: "savedState"),
      serializer: JsonSerializer<AppState>(AppState.fromJson));

  AppState storedState;
  try {
    storedState = await persistor.load();
  } catch (e) {
    print("excpetion Caugth:$e");
  }
  if (storedState == null) {
    var manager = RunPersistenceHandler();
    storedState = getDefaultState(manager);
    initializedThemeMode = false;
  }

  final _initialState = storedState;

  final Store<AppState> _store = Store<AppState>(reducer,
      initialState: _initialState, middleware: [persistor.createMiddleware()]);
  Future.delayed(Duration(seconds: 1), () {
    BackgroundLocation.getPermissions(onGranted: () {
      if (Platform.isAndroid) {
        BackgroundLocation.setAndroidConfiguration(100);
        BackgroundLocation.setAndroidNotification(
          message: "gps position retrieved in background",
          title: "gps retrieval service",
        );
      }
    });
  });
  runApp(MyApp(store: _store, initialized: initializedThemeMode));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;
  final bool initialized;
  MyApp({this.store, this.initialized});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => store.state.currentThemeNotifier,
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) => StoreProvider<AppState>(
            store: store,
            child: MaterialApp(
              theme: theme.getTheme(),
              debugShowCheckedModeBanner: false,
              //title: 'Flutter Demo',
              home: Nav(),
            )),
      ),
    );
  }
}
