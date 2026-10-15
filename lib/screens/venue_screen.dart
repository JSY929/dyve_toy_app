import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/dummy_data.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'venue_detail_screen.dart';

typedef VenueFilter = ({String? region, String? type, String? genre, int period});

const VenueFilter _noFilter = (region: null, type: null, genre: null, period: 0);
const _periods = ['전체', '오늘 밤', '7일 이내'];

/// 베뉴 탭: 검색, 필터, 지도/목록 전환.
class VenueScreen extends StatefulWidget {
  const VenueScreen({super.key});

  @override
  State<VenueScreen> createState() => _VenueScreenState();
}

class _VenueScreenState extends State<VenueScreen> {
  String _query = '';
  VenueFilter _filter = _noFilter;

  bool _matches(Venue v) {
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty && ![v.name, v.region, v.area, v.address].any((t) => t.toLowerCase().contains(q))) return false;
    if (_filter.region != null && v.region != _filter.region) return false;
    if (_filter.type != null && v.type != _filter.type) return false;
    if (_filter.genre != null && v.genre != _filter.genre) return false;
    if (_filter.period == 0) return true;
    return eventsAtVenue(v.id).any((e) => e.sessions.any((d) => _filter.period == 1 ? isToday(d) : withinDays(d, 7)));
  }

  Future<void> _openFilter() async {
    final result = await showModalBottomSheet<VenueFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBg,
      builder: (_) => _FilterSheet(initial: _filter),
    );
    if (result != null) setState(() => _filter = result);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final list = venues.where(_matches).toList();
    final filterOn = _filter != _noFilter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('베뉴 탐색', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: const InputDecoration(
                        hintText: '베뉴명, 지역, 주소 검색',
                        isDense: true,
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _openFilter,
                    icon: Badge(isLabelVisible: filterOn, child: const Icon(Icons.tune)),
                    label: const Text('필터'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('지도'), icon: Icon(Icons.map_outlined)),
                    ButtonSegment(value: false, label: Text('목록'), icon: Icon(Icons.list)),
                  ],
                  selected: {state.venueMapView},
                  onSelectionChanged: (s) => state.setVenueView(map: s.first),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text('베뉴 ${list.length}곳', style: const TextStyle(color: kMuted)),
        ),
        Expanded(
          child: list.isEmpty
              ? const EmptyText('조건에 맞는 베뉴가 없어요. 검색어나 필터를 바꿔보세요.')
              : state.venueMapView
              ? _VenueMap(venues: list, selectedId: state.selectedVenueId)
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => VenueListTile(venue: list[i]),
                ),
        ),
      ],
    );
  }
}

/// 지도 SDK 없이 그린 간이 지도. 핀 위치는 Venue.mapX/mapY 비율.
class _VenueMap extends StatelessWidget {
  const _VenueMap({required this.venues, required this.selectedId});

  final List<Venue> venues;
  final String? selectedId;

  static const _cities = [
    ('서울', 0.36, 0.18),
    ('대전', 0.40, 0.48),
    ('대구', 0.62, 0.52),
    ('광주', 0.26, 0.72),
    ('부산', 0.76, 0.68),
    ('제주', 0.26, 0.92),
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.read(context);
    final selected = venues.where((v) => v.id == selectedId).firstOrNull;
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = c.maxHeight;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => state.setVenueView(clearSelected: true),
                child: const CustomPaint(painter: _MapPainter()),
              ),
            ),
            for (final (name, x, y) in _cities)
              Positioned(
                left: x * w - 20,
                top: y * h - 30,
                child: Text(
                  name,
                  style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.w700),
                ),
              ),
            const Positioned(
              right: 8,
              bottom: 8,
              child: Text('간이 지도 (지도 SDK 미사용)', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ),
            for (final v in venues)
              Positioned(
                left: v.mapX * w - 18,
                top: v.mapY * h - 36,
                child: IconButton(
                  tooltip: v.name,
                  padding: EdgeInsets.zero,
                  onPressed: () => state.setVenueView(selected: v.id),
                  icon: Icon(Icons.location_on, size: 36, color: v.id == selectedId ? Colors.white : kCoral),
                ),
              ),
            if (selected != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Material(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                  child: VenueListTile(venue: selected),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// 남한 윤곽 대략 좌표(지도 영역 비율). 실제 해안선과 정확히 맞지 않는다.
const _landOutline = [
  Offset(0.18, 0.10), Offset(0.30, 0.08), Offset(0.45, 0.06), Offset(0.60, 0.04),
  Offset(0.72, 0.02), Offset(0.76, 0.12), Offset(0.82, 0.25), Offset(0.86, 0.38),
  Offset(0.88, 0.50), Offset(0.88, 0.60), Offset(0.86, 0.68), Offset(0.82, 0.76),
  Offset(0.74, 0.80), Offset(0.64, 0.82), Offset(0.54, 0.86), Offset(0.44, 0.84),
  Offset(0.34, 0.88), Offset(0.24, 0.86), Offset(0.16, 0.80), Offset(0.14, 0.70),
  Offset(0.18, 0.60), Offset(0.14, 0.50), Offset(0.18, 0.42), Offset(0.14, 0.34),
  Offset(0.20, 0.28), Offset(0.16, 0.20),
];
const _hanRiver = [Offset(0.16, 0.22), Offset(0.26, 0.25), Offset(0.36, 0.23), Offset(0.46, 0.26), Offset(0.58, 0.20)];
const _highway = [Offset(0.36, 0.25), Offset(0.40, 0.48), Offset(0.62, 0.56), Offset(0.76, 0.74)];

/// 바다, 격자, 남한 윤곽, 제주, 한강, 경부고속도로를 그린다.
class _MapPainter extends CustomPainter {
  const _MapPainter();

  static Offset _at(Offset o, Size s) => Offset(o.dx * s.width, o.dy * s.height);

  /// 꼭짓점 사이 중점을 이어 윤곽을 둥글게 만든다.
  static Path _smoothClosed(List<Offset> pts, Size s) {
    final path = Path();
    final start = (_at(pts.last, s) + _at(pts.first, s)) / 2;
    path.moveTo(start.dx, start.dy);
    for (var i = 0; i < pts.length; i++) {
      final a = _at(pts[i], s), b = _at(pts[(i + 1) % pts.length], s);
      final mid = (a + b) / 2;
      path.quadraticBezierTo(a.dx, a.dy, mid.dx, mid.dy);
    }
    return path..close();
  }

  static Path _line(List<Offset> pts, Size s) {
    final path = Path()..moveTo(_at(pts.first, s).dx, _at(pts.first, s).dy);
    for (final o in pts.skip(1)) {
      path.lineTo(_at(o, s).dx, _at(o, s).dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF16202A));

    final grid = Paint()..color = Colors.white.withValues(alpha: 0.04);
    for (var x = 0.0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final landFill = Paint()..color = const Color(0xFF243140);
    final landEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF3A4D61);
    final land = _smoothClosed(_landOutline, size);
    final jeju = Rect.fromCenter(
      center: _at(const Offset(0.28, 0.95), size),
      width: size.width * 0.14,
      height: size.height * 0.04,
    );
    canvas
      ..drawPath(land, landFill)
      ..drawPath(land, landEdge)
      ..drawOval(jeju, landFill)
      ..drawOval(jeju, landEdge);

    canvas.drawPath(
      _line(_hanRiver, size),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF2F5B7A),
    );
    canvas.drawPath(
      _line(_highway, size),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: 0.12),
    );
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => false;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});

  final VenueFilter initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late VenueFilter _f = widget.initial;

  Widget _dropdown(
    String label,
    String allLabel,
    String? value,
    Iterable<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButton<String?>(
            value: value,
            isExpanded: true,
            items: [
              DropdownMenuItem(value: null, child: Text(allLabel)),
              for (final o in options) DropdownMenuItem(value: o, child: Text(o)),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Set<String> distinct(String Function(Venue) f) => venues.map(f).toSet();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('필터', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            _dropdown(
              '지역 선택',
              '모든 지역',
              _f.region,
              distinct((v) => v.region),
              (v) => setState(() => _f = (region: v, type: _f.type, genre: _f.genre, period: _f.period)),
            ),
            _dropdown(
              '공간 유형 선택',
              '모든 유형',
              _f.type,
              distinct((v) => v.type),
              (v) => setState(() => _f = (region: _f.region, type: v, genre: _f.genre, period: _f.period)),
            ),
            _dropdown(
              '장르 선택',
              '모든 장르',
              _f.genre,
              distinct((v) => v.genre),
              (v) => setState(() => _f = (region: _f.region, type: _f.type, genre: v, period: _f.period)),
            ),
            const Text('기간', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < _periods.length; i++)
                  ChoiceChip(
                    label: Text(_periods[i]),
                    selected: _f.period == i,
                    onSelected: (_) =>
                        setState(() => _f = (region: _f.region, type: _f.type, genre: _f.genre, period: i)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(onPressed: () => setState(() => _f = _noFilter), child: const Text('초기화')),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: () => Navigator.pop(context, _f),
                    child: const Text('결과 보기'),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
