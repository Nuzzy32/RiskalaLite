import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../data/crisis_resources.dart';

Future<void> showCrisisSheet(
  BuildContext context, {
  String title = 'Kontak Bantuan',
  String subtitle = 'Pilih layanan untuk menghubungi. Kamu tidak sendirian.',
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => CrisisSheet(title: title, subtitle: subtitle),
  );
}

class CrisisSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  const CrisisSheet({
    super.key,
    this.title = 'Kontak Bantuan',
    this.subtitle = 'Pilih layanan untuk menghubungi. Kamu tidak sendirian.',
  });

  Future<void> _contact(BuildContext context, CrisisResource r) async {
    final uri = r.phone != null
        ? Uri(scheme: 'tel', path: r.phone)
        : Uri.parse(r.url!);
    final messenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka tautan di perangkat ini'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.brand,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 13,
                color: AppColors.brand.withValues(alpha: 0.55),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...kCrisisResources.map((r) {
            final accent = r.emergency
                ? AppColors.danger
                : AppColors.accentDeep;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _contact(context, r);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFDFD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEAF0F1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(r.icon, color: accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brand,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r.description,
                              style: const TextStyle(
                                fontFamily: 'NimbusSans',
                                fontSize: 12,
                                height: 1.35,
                                color: AppColors.subtle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        r.url != null
                            ? Icons.open_in_new_rounded
                            : Icons.call_rounded,
                        size: 18,
                        color: accent,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
