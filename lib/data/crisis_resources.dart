import 'package:flutter/material.dart';

/// Crisis support contacts surfaced when an employee reports high stress.
///
/// Curated, credible Indonesian resources. The tone of the surrounding UI is
/// deliberately calming (not alarm-red) — the goal is to feel held, not scared.
/// In a real deployment these can be extended per-company (EAP provider).

class CrisisResource {
  final String name;
  final String description;
  final String? phone; // launched via tel:
  final String? url; // launched via https:
  final IconData icon;
  final bool emergency;

  const CrisisResource({
    required this.name,
    required this.description,
    this.phone,
    this.url,
    required this.icon,
    this.emergency = false,
  });
}

const List<CrisisResource> kCrisisResources = [
  CrisisResource(
    name: 'Hotline Kesehatan Jiwa Kemenkes',
    description: 'Layanan konseling — tekan 119 lalu pilih ext. 8 (SEJIWA).',
    phone: '119',
    icon: Icons.support_agent_rounded,
  ),
  CrisisResource(
    name: 'Into The Light Indonesia',
    description: 'Komunitas pencegahan bunuh diri & dukungan kesehatan mental.',
    url: 'https://www.intothelightid.org',
    icon: Icons.volunteer_activism_outlined,
  ),
  CrisisResource(
    name: 'Panggilan Darurat',
    description: 'Untuk situasi darurat yang mengancam keselamatan.',
    phone: '112',
    icon: Icons.emergency_outlined,
    emergency: true,
  ),
];

/// The primary, most actionable contact (used for the main call button).
CrisisResource get kPrimaryCrisisContact => kCrisisResources.first;
