import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tasks/pages/home.dart';
import 'package:tasks/pages/login.dart';
import 'package:tasks/pages/splash.dart';
import 'package:tasks/providers/auth.dart';
import 'package:tasks/providers/tasks.dart';

void main() {
  runApp(TasksApp());
}

class TasksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Tasks>(
          create: (_) => Tasks(authProvider: null),
          update: (_, auth, __) => Tasks(authProvider: auth),
        )
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '.tasks',
          theme: ThemeData(
            primaryColor: Colors.blue,
            accentColor: Colors.pink,
            brightness: Brightness.dark,
            accentColorBrightness: Brightness.light,
            primaryColorBrightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: AppBarTheme(
              elevation: 0,
              color: Colors.transparent,
            ),
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(
                color: Colors.white60,
              ),
            ),
          ),
          // home: SplashScreen()
          home: auth.isAuth
              ? HomePage()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : LoginPage(),
                ),
        ),
      ),
    );
  }
}
