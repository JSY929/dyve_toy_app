import 'dart:math';

import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models.dart';
import '../widgets/common.dart';

/// QR 티켓 제시. QR은 패키지 없이 그린 가짜 패턴.
class TicketQrScreen extends StatelessWidget {
  const TicketQrScreen({super.key, required this.ticket, this.justIssued = false});

  final Ticket ticket;
  final bool justIssued;

  @override
  Widget build(BuildContext context) {
    final venue = venueById(ticket.event.venueId);
    return Scaffold(
      appBar: AppBar(title: const Text('모바일 티켓'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (justIssued)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: kCoral.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: const Text('예매가 완료되었어요. 마이 탭 내 티켓에서 다시 볼 수 있어요.', textAlign: TextAlign.center),
            ),
          Text(
            ticket.event.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${fmtDateTime(ticket.session)} · ${venue.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: kMuted),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 240,
              height: 240,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: CustomPaint(painter: _FakeQrPainter(ticket.id.hashCode)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('입장 시 이 QR을 보여주세요.', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Text('티켓 ID', style: TextStyle(color: kMuted, fontSize: 12)),
                  Text(ticket.id, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${ticket.quantity}매 · ${ticket.payMethod} · ${won(ticket.total)}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: kMuted),
          ),
          const SizedBox(height: 8),
          const Text(
            '토이 앱용 가짜 QR이라 실제 입장에는 쓸 수 없어요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FakeQrPainter extends CustomPainter {
  _FakeQrPainter(this.seed);

  final int seed;
  static const _n = 21;

  bool _inFinder(int x, int y) {
    bool corner(int cx, int cy) => x >= cx && x < cx + 7 && y >= cy && y < cy + 7;
    return corner(0, 0) || corner(_n - 7, 0) || corner(0, _n - 7);
  }

  bool _finderDark(int x, int y) {
    final lx = x >= _n - 7 ? x - (_n - 7) : x;
    final ly = y >= _n - 7 ? y - (_n - 7) : y;
    final edge = lx == 0 || lx == 6 || ly == 0 || ly == 6;
    final center = lx >= 2 && lx <= 4 && ly >= 2 && ly <= 4;
    return edge || center;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _n;
    final paint = Paint()..color = Colors.black;
    final rnd = Random(seed);
    for (var y = 0; y < _n; y++) {
      for (var x = 0; x < _n; x++) {
        final dark = _inFinder(x, y) ? _finderDark(x, y) : rnd.nextBool();
        if (dark) canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_FakeQrPainter old) => old.seed != seed;
}
