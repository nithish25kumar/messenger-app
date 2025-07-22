import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger_app/domain/constants/appthemes.dart';
import 'package:messenger_app/domain/constants/cubits/themecubit.dart';
import 'package:messenger_app/domain/constants/cubits/themestates.dart';
import 'package:messenger_app/repositary/screens/onboard/onboardingscreen.dart';

void main() {
  runApp(BlocProvider(create: (_) => Themecubit(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Themecubit, Themestates>(builder: (context, state) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Messenger-app',
        theme: state is LightThemeStates
            ? Appthemes.lightTheme
            : Appthemes.darkTheme,
        home: Onboardingscreen(),
      );
    });
  }
}
