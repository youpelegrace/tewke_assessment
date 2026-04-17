import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: .stretch,
      spacing: 16,
      children: <Widget>[_LiveCardSkeleton(), _ChartCardSkeleton()],
    );
  }
}

class _LiveCardSkeleton extends StatelessWidget {
  const _LiveCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: .fromLTRB(22, 22, 22, 20),
        child: Column(
          crossAxisAlignment: .start,
          children: <Widget>[
            _Bone(width: 72, height: 24, radius: 999),
            SizedBox(height: 18),
            Row(
              crossAxisAlignment: .end,
              children: <Widget>[
                _Bone(width: 96, height: 54, radius: 6),
                SizedBox(width: 8),
                Padding(
                  padding: .only(bottom: 6),
                  child: _Bone(width: 64, height: 13),
                ),
              ],
            ),
            SizedBox(height: 14),
            _Bone(width: 190, height: 15),
            SizedBox(height: 6),
            _Bone(width: 150, height: 11),
          ],
        ),
      ),
    );
  }
}

class _ChartCardSkeleton extends StatelessWidget {
  const _ChartCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const .fromLTRB(22, 20, 22, 18),
        child: Column(
          crossAxisAlignment: .stretch,
          children: <Widget>[
            const Row(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .end,
              children: <Widget>[
                _Bone(width: 46, height: 15),
                _Bone(width: 66, height: 11),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 160,
              child: Column(
                mainAxisAlignment: .spaceBetween,
                children: .generate(
                  4,
                  (_) => const _Bone(width: .infinity, height: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: .generate(4, (_) => const _Bone(width: 28, height: 10)),
            ),
            const SizedBox(height: 14),
            const _Bone(width: .infinity, height: 0.5),
            const SizedBox(height: 12),
            const Row(
              children: <Widget>[
                _Bone(width: 14, height: 2),
                SizedBox(width: 6),
                _Bone(width: 36, height: 11),
                SizedBox(width: 16),
                _Bone(width: 14, height: 2),
                SizedBox(width: 6),
                _Bone(width: 48, height: 11),
              ],
            ),
            const SizedBox(height: 10),
            const _Bone(width: 100, height: 11),
          ],
        ),
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({required this.width, required this.height, this.radius = 4});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isLight = theme.brightness == .light;
    final Color base = isLight
        ? const Color(0xFFECEAE4)
        : const Color(0xFF2A2826);
    final Color highlight = isLight
        ? const Color(0xFFF6F4EE)
        : const Color(0xFF3A3836);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: .circular(radius),
        ),
      ),
    );
  }
}
