import 'package:lekhan_ai/shared/custom_fields/domain/entities/custom_field_definition.dart';
import 'package:lekhan_ai/shared/custom_fields/domain/enum/custom_field_module.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class CustomFieldsRepository {
  Future<Either<AppException, List<CustomFieldDefinition>>> getCachedFields(
    CustomFieldModule module,
  );

  Future<Either<AppException, List<CustomFieldDefinition>>> fetchAndCacheFields(
    CustomFieldModule module,
  );

  Future<Either<AppException, List<CustomFieldDefinition>>> getFields({
    required CustomFieldModule module,
    required bool forceRefresh,
    required Duration maxCacheAge,
  });
}
