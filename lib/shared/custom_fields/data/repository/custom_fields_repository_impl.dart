import 'package:lekhan_ai/shared/custom_fields/data/datasource/local/custom_fields_local_datasource.dart';
import 'package:lekhan_ai/shared/custom_fields/data/datasource/remote/custom_fields_remote_datasource.dart';
import 'package:lekhan_ai/shared/custom_fields/domain/enum/custom_field_module.dart';
import 'package:lekhan_ai/shared/custom_fields/data/model/custom_field_definition_model.dart';
import 'package:lekhan_ai/shared/custom_fields/domain/repository/custom_fields_repository.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class CustomFieldsRepositoryImpl implements CustomFieldsRepository {
  final CustomFieldsLocalDataSource local;
  final CustomFieldsRemoteDataSource remote;

  const CustomFieldsRepositoryImpl({required this.local, required this.remote});

  @override
  Future<Either<AppException, List<CustomFieldDefinitionModel>>> getCachedFields(
    CustomFieldModule module,
  ) {
    return local.getFields(module);
  }

  @override
  Future<Either<AppException, List<CustomFieldDefinitionModel>>> fetchAndCacheFields(
    CustomFieldModule module,
  ) async {
    final fetched = await remote.fetchFields(module);
    return fetched.fold(
      (l) => Left(l),
      (fields) async {
        await local.saveFields(module, fields);
        return Right(fields);
      },
    );
  }

  @override
  Future<Either<AppException, List<CustomFieldDefinitionModel>>> getFields({
    required CustomFieldModule module,
    required bool forceRefresh,
    required Duration maxCacheAge,
  }) async {
    if (forceRefresh) {
      return fetchAndCacheFields(module);
    }

    final cachedFieldsRes = await local.getFields(module);
    final cachedAtRes = await local.getCachedAt(module);

    final cachedFields = cachedFieldsRes.getOrElse((_) => const []);
    final cachedAt = cachedAtRes.getOrElse((_) => null);

    if (cachedFields.isNotEmpty && cachedAt != null) {
      final age = DateTime.now().difference(cachedAt);
      if (age <= maxCacheAge) {
        return Right(cachedFields);
      }
    }

    final refreshed = await fetchAndCacheFields(module);
    return refreshed.fold(
      (l) {
        if (cachedFields.isNotEmpty) return Right(cachedFields);
        return Left(l);
      },
      (r) => Right(r),
    );
  }
}
