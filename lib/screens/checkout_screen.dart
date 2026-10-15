import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/dummy_data.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'ticket_qr_screen.dart';

/// 티켓 예매: 관람 회차 선택 → 수량 선택 → 결제 수단 선택 → 모의 결제.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.event});

  final Event event;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const _maxQty = 10;
  static const _feePerTicket = 2000;
  static const _payMethods = [
    ('카드', '신용·체크카드', Icons.credit_card),
    ('간편결제', '결제창에서 간편결제 선택', Icons.phone_iphone),
    ('PayPal', 'USD · 지원되는 해외 카드', Icons.public),
  ];

  int _session = 0;
  int _qty = 1;
  int _pay = 0;
  bool _paying = false;

  int get _ticketSum => widget.event.price * _qty;
  int get _fee => _feePerTicket * _qty;
  int get _total => _ticketSum + _fee;

  Future<void> _payNow() async {
    setState(() => _paying = true);
    await Future<void>.delayed(const Duration(milliseconds: 700)); // 결제 중인 척
    if (!mounted) return;
    final ticket = AppScope.read(context).issueTicket(
      event: widget.event,
      session: widget.event.sessions[_session],
      quantity: _qty,
      payMethod: _payMethods[_pay].$1,
      total: _total,
    );
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => TicketQrScreen(ticket: ticket, justIssued: true)));
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final venue = venueById(e.venueId);
    const label = TextStyle(fontSize: 16, fontWeight: FontWeight.w800);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHECKOUT', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 80, height: 104, child: Poster(event: e, fontSize: 11, radius: 8)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('행사 요약', style: TextStyle(color: kMuted, fontSize: 12)),
                    Text(e.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(fmtDateTime(e.sessions[_session])),
                    Text(venue.name, style: const TextStyle(color: kMuted)),
                    const SizedBox(height: 6),
                    Pill(e.entryType),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          const Text('관람 회차 선택', style: label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < e.sessions.length; i++)
                ChoiceChip(
                  label: Text(fmtDateTime(e.sessions[i])),
                  selected: _session == i,
                  onSelected: (_) => setState(() => _session = i),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Text('티켓 선택', style: label)),
              Text('${won(e.price)} / 1매', style: const TextStyle(color: kMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: kLine),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.entryType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const Text('선착순 입장', style: TextStyle(color: kMuted)),
                    ],
                  ),
                ),
                IconButton.outlined(
                  tooltip: '수량 줄이기',
                  onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$_qty',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton.outlined(
                  tooltip: '수량 늘리기',
                  onPressed: _qty < _maxQty ? () => setState(() => _qty++) : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('현재 최대 $_maxQty매까지 선택할 수 있어요.', style: TextStyle(color: kMuted)),
          const SizedBox(height: 24),
          const Text('주문 요약', style: label),
          _row('티켓 $_qty매', won(_ticketSum)),
          _row('예매 수수료', won(_fee)),
          const Divider(height: 24),
          _row('총 결제금액', won(_total), bold: true),
          const SizedBox(height: 24),
          const Text('결제 수단', style: label),
          const SizedBox(height: 8),
          for (var i = 0; i < _payMethods.length; i++) _payOption(i),
          const SizedBox(height: 12),
          const Text('토이 앱의 모의 결제입니다. 실제 결제는 이루어지지 않아요.', style: TextStyle(color: kMuted)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: _paying ? null : _payNow,
            child: Text(_paying ? '결제 중...' : '${won(_total)} 결제하기'),
          ),
        ),
      ),
    );
  }

  Widget _row(String left, String right, {bool bold = false}) {
    final style = bold ? const TextStyle(fontSize: 20, fontWeight: FontWeight.w900) : const TextStyle(color: kMuted);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(child: Text(left, style: style)),
          Text(right, style: style),
        ],
      ),
    );
  }

  Widget _payOption(int i) {
    final (name, desc, icon) = _payMethods[i];
    final selected = _pay == i;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _pay = i),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? kCoral.withValues(alpha: 0.12) : kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? kCoral : kLine),
          ),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(desc, style: const TextStyle(color: kMuted, fontSize: 13)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? kCoral : kMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
