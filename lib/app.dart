import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'core/theme/app_theme.dart';
import 'features/carbon_intensity/data/carbon_intensity_api.dart';
import 'features/carbon_intensity/data/carbon_intensity_repository.dart';
import 'features/carbon_intensity/presentation/cubit/carbon_intensity_cubit.dart';
import 'features/carbon_intensity/presentation/pages/dashboard_page.dart';
import 'features/carbon_intensity/presentation/pages/launch_page.dart';

class CarbonIntensityApp extends StatefulWidget {
  const CarbonIntensityApp({super.key});

  @override
  State<CarbonIntensityApp> createState() => _CarbonIntensityAppState();
}

class _CarbonIntensityAppState extends State<CarbonIntensityApp> {
  late final http.Client _httpClient;
  late final CarbonIntensityRepository _repository;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    _repository = CarbonIntensityRepository(
      api: CarbonIntensityApi(client: _httpClient),
    );
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CarbonIntensityRepository repository = CarbonIntensityRepository(
      api: CarbonIntensityApi(client: http.Client()),
    );

    return BlocProvider(
      create: (_) => CarbonIntensityCubit(repository)
        ..load()
        ..startAutoRefresh(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const LaunchPage(),
      ),
    );
  }
}
