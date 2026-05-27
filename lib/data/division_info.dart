import 'package:flutter/material.dart';

/// Static metadata for divisions (icon mapping, ordering).
/// This is NOT mock data — it's UI metadata used to render division lists/charts
/// with consistent icons and ordering across HR dashboard pages.
class DivisionInfo {
  final String name;
  final IconData icon;
  const DivisionInfo(this.name, this.icon);
}

const List<DivisionInfo> divisionInfoList = [
  DivisionInfo('Engineering', Icons.settings_outlined),
  DivisionInfo('Marketing', Icons.campaign_outlined),
  DivisionInfo('HR', Icons.groups_outlined),
  DivisionInfo('Finance', Icons.account_balance_outlined),
  DivisionInfo('Operations', Icons.business_outlined),
  DivisionInfo('Sales', Icons.storefront_outlined),
];

IconData divisionIcon(String name) {
  try {
    return divisionInfoList.firstWhere((d) => d.name == name).icon;
  } catch (_) {
    return Icons.business_outlined;
  }
}
