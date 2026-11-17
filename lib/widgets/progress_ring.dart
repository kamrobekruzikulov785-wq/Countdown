// Halqa ko'rinishidagi progress: kutish vaqtining qancha qismi o'tganini
// ko'rsatadi. Markaziga istalgan vidjet (masalan, "3 kun") qo'yiladi.

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.qiymat,
    required this.olcham,
    required this.qalinlik,
    required this.rang,
    required this.izRangi,
    required this.semantikMatn,
    this.child,
  });

  /// 0 dan 1 gacha: qancha qismi to'lgan.
  final double qiymat;

  /// Halqa diametri.
  final double olcham;

  /// Chiziq qalinligi.
  final double qalinlik;

  /// To'lgan qism rangi.
  final Color rang;

  /// To'lmagan qism (iz) rangi.
  final Color izRangi;

  /// Ekran o'quvchi dasturlar uchun matn (ko'rish qobiliyati past foydalanuvchilarga).
  final String semantikMatn;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantikMatn,
      child: SizedBox.square(
        dimension: olcham,
        child: CustomPaint(
          painter: _HalqaChizuvchi(
            qiymat: qiymat.clamp(0.0, 1.0),
            qalinlik: qalinlik,
            rang: rang,
            izRangi: izRangi,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Halqani chizadigan "rassom": avval to'liq iz, ustidan to'lgan yoy.
class _HalqaChizuvchi extends CustomPainter {
  _HalqaChizuvchi({
    required this.qiymat,
    required this.qalinlik,
    required this.rang,
    required this.izRangi,
  });

  final double qiymat;
  final double qalinlik;
  final Color rang;
  final Color izRangi;

  @override
  void paint(Canvas canvas, Size size) {
    final markaz = size.center(Offset.zero);
    final radius = (size.shortestSide - qalinlik) / 2;

    final izQalam = Paint()
      ..color = izRangi
      ..style = PaintingStyle.stroke
      ..strokeWidth = qalinlik;
    canvas.drawCircle(markaz, radius, izQalam);

    if (qiymat <= 0) return;
    final yoyQalam = Paint()
      ..color = rang
      ..style = PaintingStyle.stroke
      ..strokeWidth = qalinlik
      ..strokeCap = StrokeCap.round;
    // Yoy tepadan (-90°) boshlanib, soat mili bo'yicha chiziladi.
    canvas.drawArc(
      Rect.fromCircle(center: markaz, radius: radius),
      -math.pi / 2,
      2 * math.pi * qiymat,
      false,
      yoyQalam,
    );
  }

  // Faqat qiymat yoki rang o'zgarganda qayta chiziladi.
  @override
  bool shouldRepaint(_HalqaChizuvchi eski) =>
      eski.qiymat != qiymat || eski.rang != rang || eski.izRangi != izRangi;
}
