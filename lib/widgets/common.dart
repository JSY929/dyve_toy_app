import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/dummy_data.dart';
import '../models.dart';
import '../screens/event_detail_screen.dart';
import '../screens/login_screen.dart';

const kBg = Color(0xFF121316);
const kSurface = Color(0xFF1C1D21);
const kCoral = Color(0xFFEF6B5F);
const kMuted = Color(0xFF9A9BA1);
const kLine = Color(0xFF2C2D33);

String won(int value) {
  final s = value.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '₩$b';
}

String _two(int n) => n.toString().padLeft(2, '0');
String fmtDate(DateTime d) => '${d.year}.${_two(d.month)}.${_two(d.day)}';
String fmtTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';
String fmtDateTime(DateTime d) => '${fmtDate(d)} · ${fmtTime(d)}';
String fmtSessions(List<DateTime> s) => '${s.map(fmtDate).join(', ')} · ${fmtTime(s.first)}';

bool isToday(DateTime d) {
  final n = DateTime.now();
  return d.year == n.year && d.month == n.month && d.day == n.day;
}

/// 오늘 0시부터 [days]일 이내인지.
bool withinDays(DateTime d, int days) {
  final n = DateTime.now();
  final start = DateTime(n.year, n.month, n.day);
  return !d.isBefore(start) && d.isBefore(start.add(Duration(days: days)));
}

/// 로그인이 필요한 기능 앞에서 호출. 로그인 안 되어 있으면 로그인 화면으로 보낸다.
Future<bool> ensureLoggedIn(BuildContext context) async {
  final state = AppScope.read(context);
  if (state.loggedIn) return true;
  await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LoginScreen()));
  return state.loggedIn;
}

void openEvent(BuildContext context, Event event) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EventDetailScreen(event: event)));
}

/// 이미지 대신 쓰는 색상 포스터.
class Poster extends StatelessWidget {
  const Poster({
    super.key,
    required this.event,
    this.fontSize = 18,
    this.showPick = false,
    this.showTitle = true,
    this.radius = 16,
  });

  final Event event;
  final double fontSize;
  final bool showPick;
  final bool showTitle;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = event.color.computeLuminance() < 0.45;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [event.color, Color.lerp(event.color, Colors.black, 0.45)!],
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          if (showPick && event.pick) const Pill('DYVE PICK', filled: true),
          if (showTitle)
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                event.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: dark ? Colors.white : Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, this.highlighted = false, this.filled = false});

  final String label;
  final bool highlighted;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? kCoral : (highlighted ? kCoral.withValues(alpha: 0.15) : Colors.transparent),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: highlighted || filled ? kCoral : kLine),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: filled ? Colors.black : (highlighted ? kCoral : Colors.white70),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.eyebrow, this.subtitle});

  final String title;
  final String? eyebrow;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null)
            Text(
              eyebrow!,
              style: const TextStyle(color: kCoral, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          if (subtitle != null) ...[const SizedBox(height: 6), Text(subtitle!, style: const TextStyle(color: kMuted))],
        ],
      ),
    );
  }
}

/// 세로 목록용 이벤트 행 (티켓 탭, 검색, 찜, 베뉴 상세).
class EventListTile extends StatelessWidget {
  const EventListTile({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final venue = venueById(event.venueId);
    return InkWell(
      onTap: () => openEvent(context, event),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        color: kSurface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 88, height: 110, child: Poster(event: event, fontSize: 12, radius: 10)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Pill(event.category, highlighted: true),
                      Pill(event.onSale ? '판매 중' : '판매 예정', highlighted: event.onSale),
                      if (event.sessions.length > 1) const Pill('다회차 공연'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(fmtSessions(event.sessions), style: const TextStyle(fontSize: 13)),
                  Text(venue.name, style: const TextStyle(fontSize: 13, color: kMuted)),
                  Text('${event.entryType} · ${won(event.price)}', style: const TextStyle(fontSize: 13, color: kMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 가로 목록·그리드용 이벤트 카드 (홈).
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final venue = venueById(event.venueId);
    return GestureDetector(
      onTap: () => openEvent(context, event),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Poster(event: event, showPick: true),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fmtSessions(event.sessions),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: kCoral, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          Text(
            '${venue.name} · ${venue.region}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: kMuted),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(won(event.price), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 6),
              Pill(event.onSale ? '판매 중' : '판매 예정', highlighted: event.onSale),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyText extends StatelessWidget {
  const EmptyText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    child: Text(text, style: const TextStyle(color: kMuted)),
  );
}
