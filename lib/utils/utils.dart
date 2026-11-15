const _months = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// "06 may"
String shortDate(DateTime d) => '${_two(d.day)} ${_months[d.month - 1]}';

/// "06/05/2026"
String fullDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

/// "12:32 p. m."
String timeLabel(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '$h:${_two(d.minute)} ${d.hour < 12 ? 'a. m.' : 'p. m.'}';
}

String mmss(int seconds) => '${_two(seconds ~/ 60)}:${_two(seconds % 60)}';

String firstName(String full) {
  final t = full.trim();
  return t.isEmpty ? '' : t.split(RegExp(r'\s+')).first;
}

String initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts[1][0]).toUpperCase();
}

String dayGreeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Buen día';
  if (h < 19) return 'Buenas tardes';
  return 'Buenas noches';
}
