import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/language/domain/model/language_model.dart';
import 'package:lekhan_ai/shared/language/domain/repositories/language_pref_repository.dart';




class GetSelectedLanguageUseCase extends Usecase<Language> {
  final LanguagePrefRepository languageRepository;

  GetSelectedLanguageUseCase(this.languageRepository);

  @override
  Future<Either<AppException, Language>> call() async {
    return await languageRepository.getLanguagePreference();
  }
}