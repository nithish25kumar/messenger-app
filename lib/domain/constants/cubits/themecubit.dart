import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger_app/domain/constants/cubits/themestates.dart';

class Themecubit extends Cubit<Themestates> {
  Themecubit() : super(LightThemeStates());

  void toggleTheme() {
    if (state is LightThemeStates) {
      emit(DarkThemeStates());
    } else {
      emit(LightThemeStates());
    }
  }
}
