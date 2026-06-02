import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/sos_button.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  static const _canSee = [
    'Statistik stres per divisi — anonim, hanya untuk grup berisi minimal 5 orang',
    'Tren kesejahteraan agregat di seluruh perusahaan',
    'Sinyal peringatan dini di level divisi (tanpa namamu, kecuali kamu mengizinkan)',
    'Laporan insiden yang kamu kirimkan secara resmi',
  ];

  static const _cannotSee = [
    'Mood harian yang kamu catat',
    'Jawaban detail asesmen stresmu',
    'Sesi konseling & booking psikologmu — sepenuhnya rahasia',
    'Namamu pada data wellness, kecuali kamu mengaktifkannya sendiri',
  ];

  @override
  Widget build(BuildContext context) {
    final consent = ApiService.wellnessConsent;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.brand,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privasi & Keamanan Data',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.brand,
          ),
        ),
        actions: const [
          SosIconButton(size: 38, margin: EdgeInsets.only(right: 12)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.accentLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_rounded,
                  color: AppColors.brand,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Privasimu adalah default. Data kesehatan mentalmu tidak dipakai untuk menilai kinerja.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brand.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _section(
            title: 'Yang BISA dilihat HR',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            items: _canSee,
          ),
          const SizedBox(height: 18),
          _section(
            title: 'Yang TIDAK BISA dilihat HR',
            icon: Icons.cancel_rounded,
            color: AppColors.danger,
            items: _cannotSee,
          ),
          const SizedBox(height: 24),
          _infoCard(
            icon: Icons.psychology_rounded,
            title: 'Psikolog terpisah dari HR',
            body:
                'Psikolog adalah pihak klinis yang independen. Mereka melihat kasus yang ditangani dan sesi konseling — tetapi HR tidak. Booking konselingmu tidak pernah muncul di dashboard HR.',
          ),
          const SizedBox(height: 12),
          _infoCard(
            icon: consent
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            title: consent
                ? 'Kamu mengizinkan namamu terlihat'
                : 'Namamu saat ini dirahasiakan',
            body: consent
                ? 'Tim wellness dapat melihat namamu dan menghubungimu bila terdeteksi stres tinggi. Kamu bisa menonaktifkan ini kapan saja di Profil.'
                : 'Data wellness-mu hanya menyumbang ke statistik anonim. Kamu bisa mengubahnya di Profil → "Bagikan Sinyal Kesejahteraan".',
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAF0F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F191A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t,
                      style: TextStyle(
                        fontFamily: 'NimbusSans',
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.brand.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String body,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.accentLight.withValues(alpha: 0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight
              ? AppColors.accent.withValues(alpha: 0.3)
              : const Color(0xFFEAF0F1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.brand, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.brand.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
