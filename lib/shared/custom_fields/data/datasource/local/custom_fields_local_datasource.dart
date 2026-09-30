import 'dart:convert';

import 'package:lekhan_ai/shared/custom_fields/domain/enum/custom_field_module.dart';
import 'package:lekhan_ai/shared/custom_fields/data/model/custom_field_definition_model.dart';
import 'package:lekhan_ai/shared/data/local/storage_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class CustomFieldsLocalDataSource {
  Future<Either<AppException, List<CustomFieldDefinitionModel>>> getFields(
    CustomFieldModule module,
  );

  Future<Either<AppException, DateTime?>> getCachedAt(CustomFieldModule module);

  Future<Either<AppException, bool>> saveFields(
    CustomFieldModule module,
    List<CustomFieldDefinitionModel> fields,
  );
}

class CustomFieldsLocalDataSourceImpl implements CustomFieldsLocalDataSource {
  final StorageService storageService;

  const CustomFieldsLocalDataSourceImpl({required this.storageService});

  String _fieldsKey(CustomFieldModule module) =>
      'custom_fields_${module.apiValue}';

  String _cachedAtKey(CustomFieldModule module) =>
      'custom_fields_${module.apiValue}_cached_at';

  @override
  Future<Either<AppException, List<CustomFieldDefinitionModel>>> getFields(
    CustomFieldModule module,
  ) async {
    try {
      final raw = await storageService.get(_fieldsKey(module));
      if (raw == null) return const Right([]);

      final decoded = jsonDecode(raw.toString());
      if (decoded is! List) return const Right([]);

      final items = decoded
          .whereType<Map>()
          .map((e) => CustomFieldDefinitionModel.fromJson(e.cast<String, dynamic>()))
          .toList();

      return Right(items);
    } catch (e) {
      return Left(
        AppException(
          message: 'Error while reading cached custom fields',
          statusCode: 1,
          identifier: 'CustomFieldsLocalDataSourceImpl.getFields',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, DateTime?>> getCachedAt(
    CustomFieldModule module,
  ) async {
    try {
      final raw = await storageService.get(_cachedAtKey(module));
      if (raw == null) return const Right(null);
      return Right(DateTime.tryParse(raw.toString()));
    } catch (e) {
      return Left(
        AppException(
          message: 'Error while reading custom fields cache time',
          statusCode: 1,
          identifier: 'CustomFieldsLocalDataSourceImpl.getCachedAt',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> saveFields(
    CustomFieldModule module,
    List<CustomFieldDefinitionModel> fields,
  ) async {
    try {
      final jsonList = fields.map((e) => e.toJson()).toList();
      final ok =
          await storageService.set(_fieldsKey(module), jsonEncode(jsonList));
      if (ok) {
        await storageService.set(
            _cachedAtKey(module), DateTime.now().toIso8601String());
      }
      return Right(ok);
    } catch (e) {
      return Left(
        AppException(
          message: 'Error while saving custom fields',
          statusCode: 1,
          identifier: 'CustomFieldsLocalDataSourceImpl.saveFields',
        ),
      );
    }
  }
}
