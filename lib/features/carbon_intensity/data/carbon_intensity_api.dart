import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/failure.dart';
import '../../../core/result.dart';
import 'carbon_intensity_dto.dart';

class CarbonIntensityApi {
  CarbonIntensityApi({
    required http.Client client,
    this.baseUrl = 'https://api.carbonintensity.org.uk',
  }) : _client = client;

  final http.Client _client;
  final String baseUrl;

  Future<Result<CarbonIntensityDto, Failure>> getCurrent() =>
      _get<CarbonIntensityDto>('/intensity', (Object data) {
        final Map<String, dynamic> first =
            (data as List<dynamic>).first as Map<String, dynamic>;
        return CarbonIntensityDto.fromJson(first);
      });

  Future<Result<List<CarbonIntensityDto>, Failure>> getToday() =>
      _get<List<CarbonIntensityDto>>(
        '/intensity/date',
        (Object data) => (data as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(CarbonIntensityDto.fromJson)
            .toList(),
      );

  Future<Result<T, Failure>> _get<T>(
    String path,
    T Function(Object data) parse,
  ) async {
    try {
      final http.Response response = await _client.get(
        .parse('$baseUrl$path'),
        headers: const <String, String>{'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        return FailureResult<T, Failure>(
          ServerFailure(
            'Request failed (${response.statusCode})',
            statusCode: response.statusCode,
          ),
        );
      }

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Object? data = body['data'];
      if (data == null) {
        return FailureResult<T, Failure>(
          const ParseFailure('Response missing `data`'),
        );
      }
      return Success<T, Failure>(parse(data));
    } on http.ClientException catch (e) {
      return FailureResult<T, Failure>(NetworkFailure(e.message));
    } on FormatException catch (e) {
      return FailureResult<T, Failure>(ParseFailure(e.message));
    } on TypeError catch (e) {
      return FailureResult<T, Failure>(
        ParseFailure('Unexpected response shape: $e'),
      );
    } catch (e) {
      return FailureResult<T, Failure>(UnknownFailure(e.toString()));
    }
  }
}
