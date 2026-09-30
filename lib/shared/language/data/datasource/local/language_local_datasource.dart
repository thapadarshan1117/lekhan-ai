

import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/data/local/storage_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/globals.dart';
import 'package:lekhan_ai/shared/language/domain/model/language_model.dart';




abstract class LanguageLocalDataSource {
  String get storageKey;
  Future<Either<AppException, Language>> getLanguage();
  Future<Either<AppException, String>> setLanguage({required Language language});
}

class LanguageLocalDatasourceImpl implements LanguageLocalDataSource {
  final StorageService storageService;

  LanguageLocalDatasourceImpl({required this.storageService});

  @override
  String get storageKey => languagePreference;
  
  // The getLanguage method is used to get the language from the local storage
  // The method returns a Future<Either<AppException, Language>>
  // The method returns a Right with the Language object if the language is fetched successfully
  // The method returns a Left with an AppException if there is an error while fetching the language
  @override
  Future<Either<AppException, Language>> getLanguage() async {
    try {
      final data = await storageService.get(storageKey) as String?;
      
      // returns english as default language if no language is set
      // else returns the language that is set
      if(data == null) {
        return const Right(Language.english);
      } else{
        final decodeString = jsonDecode(data);
        return Right(Language.values.firstWhere((element) => element.name == decodeString));
      }
    } catch (e) {
      return Left(
        AppException(
          message: "Error while getting language",
          statusCode: 1,
          identifier: 'At LanguageLocalDatasourceImpl.getLanguage',
        ),
      );
    }
  }
  
  // The setLanguage method is used to set the language in the local storage
  // The method takes a Language object as an argument and returns a Future<Either<AppException, String>>
  // The method returns a Right with a success message if the language is set successfully
  // The method returns a Left with an AppException if there is an error while setting the language
  @override
  Future<Either<AppException, String>> setLanguage({required Language language}) async {
    try {
      final jsonLanguage = jsonEncode(language.name);
      final result = await storageService.set(storageKey, jsonLanguage);
      if(result) {
        return const Right("Language set successfully");
      } else {
        return Left(
          AppException(
            message: "Error while setting language",
            statusCode: 1,
            identifier: 'At LanguageLocalDatasourceImpl.setLanguage',
          ),
        );
      }
    } catch (e) {
      return Left(
        AppException(
          message: "Error while setting language",
          statusCode: 1,
          identifier: 'At LanguageLocalDatasourceImpl.setLanguage',
        ),
      );
    }
  }
}