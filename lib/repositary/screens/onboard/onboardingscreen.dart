import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger_app/domain/constants/cubits/themecubit.dart';

class Onboardingscreen extends StatelessWidget {
  const Onboardingscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Themes"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                BlocProvider.of<Themecubit>(context).toggleTheme();
              },
              icon: Icon(Icons.dark_mode_outlined))
        ],
      ),
    );
  }
}
