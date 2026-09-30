import 'package:lekhan_ai/core/config/api/api_configs.dart';
import 'package:lekhan_ai/shared/custom_fields/domain/enum/custom_field_module.dart';
import 'package:lekhan_ai/shared/custom_fields/data/model/custom_field_definition_model.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class CustomFieldsRemoteDataSource {
  Future<Either<AppException, List<CustomFieldDefinitionModel>>> fetchFields(
    CustomFieldModule module,
  );
}

class CustomFieldsRemoteDataSourceImpl implements CustomFieldsRemoteDataSource {
  final NetworkService networkService;

  const CustomFieldsRemoteDataSourceImpl({required this.networkService});

  @override
  Future<Either<AppException, List<CustomFieldDefinitionModel>>> fetchFields(
    CustomFieldModule module,
  ) async {
    final res = await networkService.get(
      ApiConfigs.customFields,
      queryParameters: {
        'module_type': module.apiValue,
        'state': 'true',
      },
    );

    return res.fold(
      (l) => Left(l),
      (r) {
        final data = r.data;
        if (data is! Map) {
          return Left(
            AppException(
              message: 'Unexpected response for custom fields',
              statusCode: r.statusCode,
              identifier: 'CustomFieldsRemoteDataSourceImpl.fetchFields',
            ),
          );
        }

        final listNode = data['data'];
        if (listNode is! List) {
          return Left(
            AppException(
              message: 'Custom fields list missing',
              statusCode: r.statusCode,
              identifier: 'CustomFieldsRemoteDataSourceImpl.fetchFields',
            ),
          );
        }

        final fields = listNode
            .whereType<Map>()
            .map((e) =>
                CustomFieldDefinitionModel.fromJson(e.cast<String, dynamic>()))
            .toList();

        fields.sort((a, b) {
          final byOrder = a.order.compareTo(b.order);
          if (byOrder != 0) return byOrder;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

        return Right(fields);
      },
    );
  }
}
