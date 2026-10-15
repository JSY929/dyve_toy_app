import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'venue_detail_screen.dart';

/// 통합 검색 (공연, 아티스트, 베뉴) + 추천 검색어.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _has(String text, String q) => text.toLowerCase().contains(q);

  bool _eventMatches(Event e, String q) {
    final venue = venueById(e.venueId);
    return _has(e.title, q) ||
        _has(e.category, q) ||
        _has(venue.name, q) ||
        e.lineup.any((a) => _has(a, q)) ||
        e.tags.any((t) => _has(t, q));
  }

  bool _venueMatches(Venue v, String q) =>
      [v.name, v.region, v.area, v.address, v.type, v.genre].any((t) => _has(t, q));

  void _setQuery(String q) {
    _controller.text = q;
    setState(() {});
  }

  Widget _keywordChips() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final k in recommendedKeywords) ActionChip(label: Text(k), onPressed: () => _setQuery(k))],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final q = _controller.text.trim().toLowerCase();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '공연, 아티스트, 베뉴 검색',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              suffixIcon: q.isEmpty ? null : IconButton(icon: const Icon(Icons.close), onPressed: () => _setQuery('')),
            ),
          ),
        ),
      ),
      body: q.isEmpty ? _intro() : _results(q),
    );
  }

  Widget _intro() => ListView(
    children: [
      const SectionTitle('공연, 아티스트, 베뉴 검색', subtitle: '키워드 하나로 모든 것을 한 번에 찾아보세요.'),
      const Divider(indent: 16, endIndent: 16),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Text(
          '추천 검색어',
          style: TextStyle(color: kMuted, fontWeight: FontWeight.w700),
        ),
      ),
      _keywordChips(),
    ],
  );

  Widget _results(String q) {
    final foundEvents = events.where((e) => _eventMatches(e, q)).toList();
    final foundVenues = venues.where((v) => _venueMatches(v, q)).toList();
    if (foundEvents.isEmpty && foundVenues.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.search_off, size: 48, color: kMuted),
          const SizedBox(height: 12),
          Center(child: Text('"${_controller.text.trim()}"에 대한 검색 결과가 없어요.')),
          const SizedBox(height: 4),
          const Center(
            child: Text('다른 키워드로 검색해 보세요.', style: TextStyle(color: kMuted)),
          ),
          const SizedBox(height: 24),
          _keywordChips(),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (foundEvents.isNotEmpty) ...[
          SectionTitle('공연·아티스트 ${foundEvents.length}건'),
          for (final e in foundEvents) EventListTile(event: e),
        ],
        if (foundVenues.isNotEmpty) ...[
          SectionTitle('베뉴 ${foundVenues.length}곳'),
          for (final v in foundVenues) VenueListTile(venue: v),
        ],
      ],
    );
  }
}
