import 'package:carbon_intensity_dashboard/core/failure.dart';
import 'package:carbon_intensity_dashboard/core/result.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/data/carbon_intensity_api.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/data/carbon_intensity_dto.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/data/carbon_intensity_repository.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/domain/carbon_intensity.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/domain/intensity_index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements CarbonIntensityApi {}

void main() {
  late _MockApi api;
  late CarbonIntensityRepository repository;

  setUp(() {
    api = _MockApi();
    repository = CarbonIntensityRepository(api: api);
  });

  group('getLiveIntensity', () {
    test('maps DTO to domain model on success', () async {
      when(() => api.getCurrent()).thenAnswer(
        (_) async => const Success<CarbonIntensityDto, Failure>(
          CarbonIntensityDto(
            from: '2024-03-15T12:00Z',
            to: '2024-03-15T12:30Z',
            forecast: 142,
            actual: 138,
            index: 'low',
          ),
        ),
      );

      final Result<CarbonIntensity, Failure> result = await repository
          .getLiveIntensity();

      expect(result.isSuccess, isTrue);
      final CarbonIntensity domain =
          (result as Success<CarbonIntensity, Failure>).value;
      expect(domain.forecast, 142);
      expect(domain.actual, 138);
      expect(domain.index, IntensityIndex.low);
      expect(domain.value, 138);
    });

    test('passes failures through untouched', () async {
      when(() => api.getCurrent()).thenAnswer(
        (_) async =>
            const FailureResult<CarbonIntensityDto, Failure>(NetworkFailure()),
      );

      final Result<CarbonIntensity, Failure> result = await repository
          .getLiveIntensity();

      expect(result.isFailure, isTrue);
      expect(
        (result as FailureResult<CarbonIntensity, Failure>).failure,
        isA<NetworkFailure>(),
      );
    });
  });

  group('getTodayIntensity', () {
    test('maps every DTO to a domain model', () async {
      when(() => api.getToday()).thenAnswer(
        (_) async => const Success<List<CarbonIntensityDto>, Failure>(
          <CarbonIntensityDto>[
            CarbonIntensityDto(
              from: '2024-03-15T00:00Z',
              to: '2024-03-15T00:30Z',
              forecast: 140,
              actual: 135,
              index: 'low',
            ),
            CarbonIntensityDto(
              from: '2024-03-15T00:30Z',
              to: '2024-03-15T01:00Z',
              forecast: 138,
              actual: null,
              index: 'low',
            ),
          ],
        ),
      );

      final Result<List<CarbonIntensity>, Failure> result = await repository
          .getTodayIntensity();

      expect(result.isSuccess, isTrue);
      final List<CarbonIntensity> daily =
          (result as Success<List<CarbonIntensity>, Failure>).value;
      expect(daily, hasLength(2));
      expect(daily.first.actual, 135);
      expect(daily.last.actual, isNull);
      expect(daily.last.value, 138, reason: 'fallback to forecast');
    });

    test('passes failures through', () async {
      when(() => api.getToday()).thenAnswer(
        (_) async => const FailureResult<List<CarbonIntensityDto>, Failure>(
          ServerFailure('boom', statusCode: 503),
        ),
      );

      final Result<List<CarbonIntensity>, Failure> result = await repository
          .getTodayIntensity();

      expect(result.isFailure, isTrue);
      final Failure failure =
          (result as FailureResult<List<CarbonIntensity>, Failure>).failure;
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 503);
    });
  });
}
