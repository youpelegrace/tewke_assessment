import 'package:bloc_test/bloc_test.dart';
import 'package:carbon_intensity_dashboard/core/failure.dart';
import 'package:carbon_intensity_dashboard/core/result.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/data/carbon_intensity_repository.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/domain/carbon_intensity.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/domain/intensity_index.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/presentation/cubit/carbon_intensity_cubit.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/presentation/cubit/carbon_intensity_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements CarbonIntensityRepository {}

void main() {
  late _MockRepository repository;

  final CarbonIntensity live = CarbonIntensity(
    from: .utc(2024, 3, 15, 12),
    to: .utc(2024, 3, 15, 12, 30),
    forecast: 142,
    actual: 138,
    index: .low,
  );

  final List<CarbonIntensity> daily = <CarbonIntensity>[
    CarbonIntensity(
      from: .utc(2024, 3, 15),
      to: .utc(2024, 3, 15, 0, 30),
      forecast: 140,
      actual: 135,
      index: .low,
    ),
  ];

  setUp(() {
    repository = _MockRepository();
  });

  blocTest<CarbonIntensityCubit, CarbonIntensityState>(
    'emits [Loading, Loaded] when both calls succeed from initial',
    setUp: () {
      when(
        () => repository.getLiveIntensity(),
      ).thenAnswer((_) async => Success<CarbonIntensity, Failure>(live));
      when(
        () => repository.getTodayIntensity(),
      ).thenAnswer((_) async => Success<List<CarbonIntensity>, Failure>(daily));
    },
    build: () => CarbonIntensityCubit(repository),
    act: (CarbonIntensityCubit cubit) => cubit.load(),
    expect: () => <Matcher>[
      isA<CarbonIntensityLoading>(),
      isA<CarbonIntensityLoaded>()
          .having((CarbonIntensityLoaded s) => s.live, 'live', live)
          .having((CarbonIntensityLoaded s) => s.daily, 'daily', daily)
          .having(
            (CarbonIntensityLoaded s) => s.isRefreshing,
            'isRefreshing',
            false,
          ),
    ],
  );

  blocTest<CarbonIntensityCubit, CarbonIntensityState>(
    'emits [Loading, Error] when the live call fails',
    setUp: () {
      when(() => repository.getLiveIntensity()).thenAnswer(
        (_) async =>
            const FailureResult<CarbonIntensity, Failure>(NetworkFailure()),
      );
      when(
        () => repository.getTodayIntensity(),
      ).thenAnswer((_) async => Success<List<CarbonIntensity>, Failure>(daily));
    },
    build: () => CarbonIntensityCubit(repository),
    act: (CarbonIntensityCubit cubit) => cubit.load(),
    expect: () => <Matcher>[
      isA<CarbonIntensityLoading>(),
      isA<CarbonIntensityError>().having(
        (CarbonIntensityError s) => s.failure,
        'failure',
        isA<NetworkFailure>(),
      ),
    ],
  );

  blocTest<CarbonIntensityCubit, CarbonIntensityState>(
    'emits [Loading, Error] when the daily call fails',
    setUp: () {
      when(
        () => repository.getLiveIntensity(),
      ).thenAnswer((_) async => Success<CarbonIntensity, Failure>(live));
      when(() => repository.getTodayIntensity()).thenAnswer(
        (_) async => const FailureResult<List<CarbonIntensity>, Failure>(
          ServerFailure('boom', statusCode: 500),
        ),
      );
    },
    build: () => CarbonIntensityCubit(repository),
    act: (CarbonIntensityCubit cubit) => cubit.load(),
    expect: () => <Matcher>[
      isA<CarbonIntensityLoading>(),
      isA<CarbonIntensityError>().having(
        (CarbonIntensityError s) => s.failure,
        'failure',
        isA<ServerFailure>(),
      ),
    ],
  );

  blocTest<CarbonIntensityCubit, CarbonIntensityState>(
    'refresh from Loaded keeps data visible with isRefreshing=true',
    setUp: () {
      when(
        () => repository.getLiveIntensity(),
      ).thenAnswer((_) async => Success<CarbonIntensity, Failure>(live));
      when(
        () => repository.getTodayIntensity(),
      ).thenAnswer((_) async => Success<List<CarbonIntensity>, Failure>(daily));
    },
    build: () => CarbonIntensityCubit(repository),
    seed: () => CarbonIntensityLoaded(
      live: live,
      daily: daily,
      lastUpdated: .utc(2024),
    ),
    act: (CarbonIntensityCubit cubit) => cubit.load(),
    expect: () => <Matcher>[
      isA<CarbonIntensityLoaded>().having(
        (CarbonIntensityLoaded s) => s.isRefreshing,
        'isRefreshing during refresh',
        true,
      ),
      isA<CarbonIntensityLoaded>().having(
        (CarbonIntensityLoaded s) => s.isRefreshing,
        'isRefreshing after',
        false,
      ),
    ],
  );
  group('stale data on refresh failure', () {
    blocTest<CarbonIntensityCubit, CarbonIntensityState>(
      'preserves Loaded with refreshError when live call fails during refresh',
      setUp: () {
        when(() => repository.getLiveIntensity()).thenAnswer(
          (_) async =>
              const FailureResult<CarbonIntensity, Failure>(NetworkFailure()),
        );
        when(() => repository.getTodayIntensity()).thenAnswer(
          (_) async => Success<List<CarbonIntensity>, Failure>(daily),
        );
      },
      build: () => CarbonIntensityCubit(repository),
      seed: () => CarbonIntensityLoaded(
        live: live,
        daily: daily,
        lastUpdated: .utc(2024),
      ),
      act: (CarbonIntensityCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<CarbonIntensityLoaded>().having(
          (CarbonIntensityLoaded s) => s.isRefreshing,
          'isRefreshing',
          true,
        ),
        isA<CarbonIntensityLoaded>()
            .having(
              (CarbonIntensityLoaded s) => s.isRefreshing,
              'isRefreshing',
              false,
            )
            .having(
              (CarbonIntensityLoaded s) => s.refreshError,
              'refreshError',
              isA<NetworkFailure>(),
            )
            .having((CarbonIntensityLoaded s) => s.live, 'live preserved', live)
            .having(
              (CarbonIntensityLoaded s) => s.daily,
              'daily preserved',
              daily,
            ),
      ],
    );

    blocTest<CarbonIntensityCubit, CarbonIntensityState>(
      'preserves Loaded with refreshError when daily call fails during refresh',
      setUp: () {
        when(
          () => repository.getLiveIntensity(),
        ).thenAnswer((_) async => Success<CarbonIntensity, Failure>(live));
        when(() => repository.getTodayIntensity()).thenAnswer(
          (_) async => const FailureResult<List<CarbonIntensity>, Failure>(
            ServerFailure('boom', statusCode: 500),
          ),
        );
      },
      build: () => CarbonIntensityCubit(repository),
      seed: () => CarbonIntensityLoaded(
        live: live,
        daily: daily,
        lastUpdated: .utc(2024),
      ),
      act: (CarbonIntensityCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<CarbonIntensityLoaded>().having(
          (CarbonIntensityLoaded s) => s.isRefreshing,
          'isRefreshing',
          true,
        ),
        isA<CarbonIntensityLoaded>()
            .having(
              (CarbonIntensityLoaded s) => s.isRefreshing,
              'isRefreshing',
              false,
            )
            .having(
              (CarbonIntensityLoaded s) => s.refreshError,
              'refreshError',
              isA<ServerFailure>(),
            ),
      ],
    );

    blocTest<CarbonIntensityCubit, CarbonIntensityState>(
      'dismissError clears refreshError',
      build: () => CarbonIntensityCubit(repository),
      seed: () => CarbonIntensityLoaded(
        live: live,
        daily: daily,
        lastUpdated: .utc(2024),
        refreshError: const NetworkFailure(),
      ),
      act: (CarbonIntensityCubit cubit) => cubit.dismissError(),
      expect: () => <Matcher>[
        isA<CarbonIntensityLoaded>().having(
          (CarbonIntensityLoaded s) => s.refreshError,
          'refreshError',
          isNull,
        ),
      ],
    );

    blocTest<CarbonIntensityCubit, CarbonIntensityState>(
      'successful refresh clears a previous refreshError',
      setUp: () {
        when(
          () => repository.getLiveIntensity(),
        ).thenAnswer((_) async => Success<CarbonIntensity, Failure>(live));
        when(() => repository.getTodayIntensity()).thenAnswer(
          (_) async => Success<List<CarbonIntensity>, Failure>(daily),
        );
      },
      build: () => CarbonIntensityCubit(repository),
      seed: () => CarbonIntensityLoaded(
        live: live,
        daily: daily,
        lastUpdated: .utc(2024),
        refreshError: const NetworkFailure(),
      ),
      act: (CarbonIntensityCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<CarbonIntensityLoaded>().having(
          (CarbonIntensityLoaded s) => s.isRefreshing,
          'isRefreshing',
          true,
        ),
        isA<CarbonIntensityLoaded>()
            .having(
              (CarbonIntensityLoaded s) => s.isRefreshing,
              'isRefreshing',
              false,
            )
            .having(
              (CarbonIntensityLoaded s) => s.refreshError,
              'refreshError',
              isNull,
            ),
      ],
    );
  });

  group('reconciles /intensity into /intensity/date via load()', () {
    blocTest<CarbonIntensityCubit, CarbonIntensityState>(
      'patches a null actual in the slot matching live',
      setUp: () {
        final CarbonIntensity liveNow = CarbonIntensity(
          from: .utc(2026, 4, 16, 14),
          to: .utc(2026, 4, 16, 14, 30),
          forecast: 66,
          actual: 77,
          index: .low,
        );
        final List<CarbonIntensity> rawDaily = <CarbonIntensity>[
          CarbonIntensity(
            from: .utc(2026, 4, 16, 13, 30),
            to: .utc(2026, 4, 16, 14),
            forecast: 64,
            actual: 77,
            index: .low,
          ),
          CarbonIntensity(
            from: .utc(2026, 4, 16, 14),
            to: .utc(2026, 4, 16, 14, 30),
            forecast: 66,
            actual: null,
            index: .low,
          ),
          CarbonIntensity(
            from: .utc(2026, 4, 16, 14, 30),
            to: .utc(2026, 4, 16, 15),
            forecast: 68,
            actual: null,
            index: .low,
          ),
        ];
        when(
          () => repository.getLiveIntensity(),
        ).thenAnswer((_) async => Success<CarbonIntensity, Failure>(liveNow));
        when(() => repository.getTodayIntensity()).thenAnswer(
          (_) async => Success<List<CarbonIntensity>, Failure>(rawDaily),
        );
      },
      build: () => CarbonIntensityCubit(repository),
      act: (CarbonIntensityCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<CarbonIntensityLoading>(),
        isA<CarbonIntensityLoaded>()
            .having(
              (CarbonIntensityLoaded s) => s.daily[0].actual,
              'past slot preserved',
              77,
            )
            .having(
              (CarbonIntensityLoaded s) => s.daily[1].actual,
              'current slot patched from live',
              77,
            )
            .having(
              (CarbonIntensityLoaded s) => s.daily[2].actual,
              'future slot untouched',
              isNull,
            ),
      ],
    );

    blocTest<CarbonIntensityCubit, CarbonIntensityState>(
      'does not overwrite an existing actual',
      setUp: () {
        final CarbonIntensity liveNow = CarbonIntensity(
          from: .utc(2026, 4, 16, 14),
          to: .utc(2026, 4, 16, 14, 30),
          forecast: 66,
          actual: 99,
          index: .low,
        );
        final List<CarbonIntensity> rawDaily = <CarbonIntensity>[
          CarbonIntensity(
            from: .utc(2026, 4, 16, 14),
            to: .utc(2026, 4, 16, 14, 30),
            forecast: 66,
            actual: 77,
            index: .low,
          ),
        ];
        when(
          () => repository.getLiveIntensity(),
        ).thenAnswer((_) async => Success<CarbonIntensity, Failure>(liveNow));
        when(() => repository.getTodayIntensity()).thenAnswer(
          (_) async => Success<List<CarbonIntensity>, Failure>(rawDaily),
        );
      },
      build: () => CarbonIntensityCubit(repository),
      act: (CarbonIntensityCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<CarbonIntensityLoading>(),
        isA<CarbonIntensityLoaded>().having(
          (CarbonIntensityLoaded s) => s.daily.single.actual,
          'existing actual is preserved',
          77,
        ),
      ],
    );

    blocTest<CarbonIntensityCubit, CarbonIntensityState>(
      'is a no-op when live has no actual yet',
      setUp: () {
        final CarbonIntensity liveNoActual = CarbonIntensity(
          from: .utc(2026, 4, 16, 14),
          to: .utc(2026, 4, 16, 14, 30),
          forecast: 66,
          actual: null,
          index: .low,
        );
        final List<CarbonIntensity> rawDaily = <CarbonIntensity>[
          CarbonIntensity(
            from: .utc(2026, 4, 16, 14),
            to: .utc(2026, 4, 16, 14, 30),
            forecast: 66,
            actual: null,
            index: .low,
          ),
        ];
        when(() => repository.getLiveIntensity()).thenAnswer(
          (_) async => Success<CarbonIntensity, Failure>(liveNoActual),
        );
        when(() => repository.getTodayIntensity()).thenAnswer(
          (_) async => Success<List<CarbonIntensity>, Failure>(rawDaily),
        );
      },
      build: () => CarbonIntensityCubit(repository),
      act: (CarbonIntensityCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<CarbonIntensityLoading>(),
        isA<CarbonIntensityLoaded>()
            .having(
              (CarbonIntensityLoaded s) => s.daily.single.actual,
              'still null',
              isNull,
            )
            .having(
              (CarbonIntensityLoaded s) => s.daily.single.index,
              'index unchanged',
              IntensityIndex.low,
            ),
      ],
    );

    blocTest<CarbonIntensityCubit, CarbonIntensityState>(
      'adopts live.index on the patched slot',
      setUp: () {
        final CarbonIntensity liveModerate = CarbonIntensity(
          from: .utc(2026, 4, 16, 15),
          to: .utc(2026, 4, 16, 15, 30),
          forecast: 76,
          actual: 120,
          index: .moderate,
        );
        final List<CarbonIntensity> rawDaily = <CarbonIntensity>[
          CarbonIntensity(
            from: .utc(2026, 4, 16, 15),
            to: .utc(2026, 4, 16, 15, 30),
            forecast: 76,
            actual: null,
            index: .low,
          ),
        ];
        when(() => repository.getLiveIntensity()).thenAnswer(
          (_) async => Success<CarbonIntensity, Failure>(liveModerate),
        );
        when(() => repository.getTodayIntensity()).thenAnswer(
          (_) async => Success<List<CarbonIntensity>, Failure>(rawDaily),
        );
      },
      build: () => CarbonIntensityCubit(repository),
      act: (CarbonIntensityCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<CarbonIntensityLoading>(),
        isA<CarbonIntensityLoaded>()
            .having(
              (CarbonIntensityLoaded s) => s.daily.single.actual,
              'actual patched from live',
              120,
            )
            .having(
              (CarbonIntensityLoaded s) => s.daily.single.index,
              'band adopted from live',
              IntensityIndex.moderate,
            ),
      ],
    );
  });
}
