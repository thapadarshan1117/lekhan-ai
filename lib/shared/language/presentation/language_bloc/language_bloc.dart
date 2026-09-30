import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/shared/language/domain/model/language_model.dart';
import 'package:lekhan_ai/shared/language/domain/usecases/get_selected_language_usecase.dart';
import 'package:lekhan_ai/shared/language/domain/usecases/set_selected_language_usecase.dart';



part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final GetSelectedLanguageUseCase getSelectedLanguageUseCase;
  final SetSelectedLanguageUseCase setSelectedLanguageUseCase;
  LanguageBloc({
    required this.getSelectedLanguageUseCase,
    required this.setSelectedLanguageUseCase,
  }) : super( LanguageState()) {
    on<ChangeLanguage>(onChangeLanguage);
    on<FetchedSelectedLanguage>(onFetchSelectedLanguage);
  }


  // changes the selected language and saves it to the local storage
  // if the selected language is not saved, it saves the default language [English]
  Future<void> onChangeLanguage(ChangeLanguage event, Emitter<LanguageState> emit) async {
    final response = await setSelectedLanguageUseCase(event.selectedLanguage);
    return response.fold(
      (l) => emit(state.copyWith(selectedLanguage: Language.values.first)),
      (r) => emit(state.copyWith(selectedLanguage: event.selectedLanguage)),
    );
  }

  // returns the selected language from the local storage
  // if the selected language is not found, it returns default language [English]
  Future<void> onFetchSelectedLanguage(
    FetchedSelectedLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    final response = await getSelectedLanguageUseCase();
    return response.fold(
      (l) => emit(state.copyWith(selectedLanguage: Language.values.first)),
      (r) => emit(state.copyWith(selectedLanguage: r)),
    );
  }
}
