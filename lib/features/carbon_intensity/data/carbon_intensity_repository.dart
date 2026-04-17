import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../domain/carbon_intensity.dart';
import 'carbon_intensity_api.dart';

class CarbonIntensityRepository {
  const CarbonIntensityRepository({required this.api});

  final CarbonIntensityApi api;

  Future<Result<CarbonIntensity, Failure>> getLiveIntensity() async {
    final result = await api.getCurrent();
    return switch (result) {
      Success(value: final dto) => Success(dto.toDomain()),
      FailureResult(failure: final f) => FailureResult(f),
    };
  }

  Future<Result<List<CarbonIntensity>, Failure>> getTodayIntensity() async {
    final result = await api.getToday();
    return switch (result) {
      Success(value: final dtos) => Success(
        dtos.map((dto) => dto.toDomain()).toList(),
      ),
      FailureResult(failure: final f) => FailureResult(f),
    };
  }
}
