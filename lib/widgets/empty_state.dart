// Bo'sh holat ekrani: ro'yxatda hech narsa bo'lmaganda ko'rsatiladi.
// Masalan, "Hali hodisa yo'q" va "Hodisa qo'shish" tugmasi.

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.belgi,
    required this.sarlavha,
    required this.izoh,
    this.tugmaMatni,
    this.onTugma,
  });

  final IconData belgi;
  final String sarlavha;
  final String izoh;

  /// Tugma ixtiyoriy: berilmasa, ko'rsatilmaydi.
  final String? tugmaMatni;
  final VoidCallback? onTugma;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(color: r.urguFon, shape: BoxShape.circle),
            child: Icon(belgi, size: 40, color: r.urgu),
          ),
          const SizedBox(height: 20),
          Text(
            sarlavha,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            izoh,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.4, color: r.ikkinchiMatn),
          ),
          if (tugmaMatni != null && onTugma != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onTugma,
              icon: const Icon(Icons.add),
              label: Text(tugmaMatni!),
            ),
          ],
        ],
      ),
    );
  }
}
