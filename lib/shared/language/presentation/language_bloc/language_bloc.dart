import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/shared/language/domain/model/language_model.dart';
import 'package:lekhan_ai/shared/language/domain/usecases/get_selected_language_usecase.dart';
import 'package:lekhan_ai/shared/language/domain/usecases/set_selected_language_usecase.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc({
    required this.getSelectedLanguageUseCase,
    required this.setSelectedLanguageUseCase,
  }) : super(const LanguageState()) {
    on<ChangeLanguage>(_onChangeLanguage);
    on<FetchedSelectedLanguage>(_onFetchSelectedLanguage);
  }

  final GetSelectedLanguageUseCase getSelectedLanguageUseCase;
  final SetSelectedLanguageUseCase setSelectedLanguageUseCase;

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    // Apply the choice immediately. A storage failure should never prevent the
    // user from reading the current session in their preferred language.
    emit(state.copyWith(selectedLanguage: event.selectedLanguage));
    await setSelectedLanguageUseCase(event.selectedLanguage);
  }

  Future<void> _onFetchSelectedLanguage(
    FetchedSelectedLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    final response = await getSelectedLanguageUseCase();
    response.fold(
      (_) => emit(state.copyWith(selectedLanguage: Language.english)),
      (Language language) => emit(state.copyWith(selectedLanguage: language)),
    );
  }
}
