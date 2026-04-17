import 'dart:convert';

import 'package:carbon_intensity_dashboard/core/failure.dart';
import 'package:carbon_intensity_dashboard/core/result.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/data/carbon_intensity_api.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/data/carbon_intensity_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  String currentJson() => jsonEncode(<String, dynamic>{
    'data': <Map<String, dynamic>>[
      <String, dynamic>{
        'from': '2024-03-15T12:00Z',
        'to': '2024-03-15T12:30Z',
        'intensity': <String, dynamic>{
          'forecast': 142,
          'actual': 138,
          'index': 'low',
        },
      },
    ],
  });

  String todayJson() => jsonEncode(<String, dynamic>{
    'data': <Map<String, dynamic>>[
      <String, dynamic>{
        'from': '2024-03-15T00:00Z',
        'to': '2024-03-15T00:30Z',
        'intensity': <String, dynamic>{
          'forecast': 140,
          'actual': 135,
          'index': 'low',
        },
      },
      <String, dynamic>{
        'from': '2024-03-15T00:30Z',
        'to': '2024-03-15T01:00Z',
        'intensity': <String, dynamic>{
          'forecast': 138,
          'actual': null,
          'index': 'low',
        },
      },
    ],
  });

  group('getCurrent', () {
    test('returns Success with a DTO on HTTP 200', () async {
      final MockClient client = MockClient(
        (_) async => http.Response(currentJson(), 200),
      );
      final CarbonIntensityApi api = CarbonIntensityApi(client: client);

      final Result<CarbonIntensityDto, Failure> result = await api.getCurrent();

      expect(result.isSuccess, isTrue);
      final CarbonIntensityDto dto =
          (result as Success<CarbonIntensityDto, Failure>).value;
      expect(dto.forecast, 142);
      expect(dto.actual, 138);
      expect(dto.index, 'low');
    });

    test('returns ServerFailure on non-200 status code', () async {
      final MockClient client = MockClient(
        (_) async => http.Response('error', 500),
      );
      final CarbonIntensityApi api = CarbonIntensityApi(client: client);

      final Result<CarbonIntensityDto, Failure> result = await api.getCurrent();

      expect(result.isFailure, isTrue);
      final Failure failure =
          (result as FailureResult<CarbonIntensityDto, Failure>).failure;
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
    });

    test('returns ParseFailure on malformed JSON', () async {
      final MockClient client = MockClient(
        (_) async => http.Response('not json', 200),
      );
      final CarbonIntensityApi api = CarbonIntensityApi(client: client);

      final Result<CarbonIntensityDto, Failure> result = await api.getCurrent();

      expect(result.isFailure, isTrue);
      expect(
        (result as FailureResult<CarbonIntensityDto, Failure>).failure,
        isA<ParseFailure>(),
      );
    });

    test('returns ParseFailure when `data` is missing', () async {
      final MockClient client = MockClient(
        (_) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
      );
      final CarbonIntensityApi api = CarbonIntensityApi(client: client);

      final Result<CarbonIntensityDto, Failure> result = await api.getCurrent();

      expect(result.isFailure, isTrue);
      expect(
        (result as FailureResult<CarbonIntensityDto, Failure>).failure,
        isA<ParseFailure>(),
      );
    });

    test('returns NetworkFailure on ClientException', () async {
      final MockClient client = MockClient(
        (_) async => throw http.ClientException('Network down'),
      );
      final CarbonIntensityApi api = CarbonIntensityApi(client: client);

      final Result<CarbonIntensityDto, Failure> result = await api.getCurrent();

      expect(result.isFailure, isTrue);
      expect(
        (result as FailureResult<CarbonIntensityDto, Failure>).failure,
        isA<NetworkFailure>(),
      );
    });
  });

  group('getToday', () {
    test('returns a list of DTOs with nullable actual preserved', () async {
      final MockClient client = MockClient(
        (_) async => http.Response(todayJson(), 200),
      );
      final CarbonIntensityApi api = CarbonIntensityApi(client: client);

      final Result<List<CarbonIntensityDto>, Failure> result = await api
          .getToday();

      expect(result.isSuccess, isTrue);
      final List<CarbonIntensityDto> dtos =
          (result as Success<List<CarbonIntensityDto>, Failure>).value;
      expect(dtos, hasLength(2));
      expect(dtos.first.actual, 135);
      expect(dtos.last.actual, isNull);
    });

    test('targets the correct endpoint', () async {
      Uri? capturedUri;
      final MockClient client = MockClient((http.Request req) async {
        capturedUri = req.url;
        return http.Response(todayJson(), 200);
      });
      final CarbonIntensityApi api = CarbonIntensityApi(client: client);

      await api.getToday();

      expect(capturedUri, isNotNull);
      expect(capturedUri?.path, '/intensity/date');
    });
  });
}
