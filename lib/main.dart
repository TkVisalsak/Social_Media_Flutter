import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'modules/auth/bindings/auth_binding.dart';
import 'modules/auth/views/login_view.dart';
// import 'modules/home/bindings/home_binding.dart';
// import 'modules/home/views/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Instagram Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginView(),
          binding: AuthBinding(),
        ),
        // GetPage(
        //   name: '/home',
        //   page: () => const HomeView(),
        //   binding: HomeBinding(),
        // ),
      ],
    );
  }
}
