import 'package:flutter/material.dart';

import '../models.dart';

// 날짜는 오늘 기준 상대값이라 기간 필터(오늘 밤, 이번 주)가 항상 결과를 가진다.
final DateTime _today = DateTime.now();
DateTime _at(int days, int hour, [int minute = 0]) =>
    DateTime(_today.year, _today.month, _today.day + days, hour, minute);

const String refundNote = '공연 시작 시각 기준이며, 1일은 24시간입니다.';
const List<(String, String)> refundRules = [
  ('공연 72시간 전까지', '전액 환불'),
  ('공연 72시간 전 이후', '취소 수수료 100%'),
  ('공연 시작 이후', '취소 불가'),
];

const List<String> recommendedKeywords = ['홍대', 'Techno', 'DJ', 'EDM', '을지로', '성수'];

const List<Venue> venues = [
  Venue(
    id: 'v1',
    name: '반쥴 BANJUL',
    region: '서울',
    area: '을지로',
    type: '공연장',
    genre: '실험음악',
    address: '서울 중구 을지로 100',
    mapX: 0.36,
    mapY: 0.26,
  ),
  Venue(
    id: 'v2',
    name: '루카 서울',
    region: '서울',
    area: '홍대·합정',
    type: '클럽',
    genre: 'Techno',
    address: '서울 마포구 와우산로 20',
    mapX: 0.28,
    mapY: 0.22,
  ),
  Venue(
    id: 'v3',
    name: '라이언 슈퍼 클럽',
    region: '서울',
    area: '강남·신사',
    type: '클럽',
    genre: 'EDM',
    address: '서울 강남구 도산대로 535',
    mapX: 0.40,
    mapY: 0.32,
  ),
  Venue(
    id: 'v4',
    name: '재즈 하우스 성수',
    region: '서울',
    area: '성수',
    type: '바',
    genre: 'Jazz',
    address: '서울 성동구 연무장길 12',
    mapX: 0.46,
    mapY: 0.24,
  ),
  Venue(
    id: 'v5',
    name: '홍대 언더스테이지',
    region: '서울',
    area: '홍대·합정',
    type: '라이브홀',
    genre: 'Indie',
    address: '서울 마포구 어울마당로 55',
    mapX: 0.24,
    mapY: 0.28,
  ),
  Venue(
    id: 'v6',
    name: '성수 아트 스페이스',
    region: '서울',
    area: '성수',
    type: '갤러리',
    genre: '전시',
    address: '서울 성동구 성수이로 88',
    mapX: 0.50,
    mapY: 0.30,
  ),
  Venue(
    id: 'v7',
    name: '해운대 사운드 클럽',
    region: '부산',
    area: '해운대',
    type: '클럽',
    genre: 'EDM',
    address: '부산 해운대구 구남로 30',
    mapX: 0.74,
    mapY: 0.74,
  ),
  Venue(
    id: 'v8',
    name: '라운지 81',
    region: '대구',
    area: '동성로',
    type: '바',
    genre: 'Hiphop',
    address: '대구 중구 동성로 81',
    mapX: 0.64,
    mapY: 0.58,
  ),
];

final List<Event> events = [
  Event(
    id: 'e1',
    title: '집 : 움직이는 뿌리',
    category: '공연',
    venueId: 'v1',
    sessions: [_at(14, 19, 30), _at(15, 19, 30)],
    price: 40000,
    lineup: [
      'Jinyoung Park',
      'Gamin',
      'Sunjay Jayaram',
      'Galen Passen',
      'Kiyoung Kim',
      'Nuno Lucas',
      'Soyeon Huh',
      'Woonjung Sim',
    ],
    about:
        '집은 고정된 장소가 아니다.\n지나온 시간, 기억, 그리고 그 안에서 만난 사람들이 쌓여 만들어지는 공간.\n\n서로 다른 문화와 언어를 가진 몸들이 움직임과 사운드로 각자의 집을 꺼내놓는다.',
    entryInfo: '- 공연 시작 10분 후까지 입장 가능합니다.\n- 예술인증명 할인 20%가 있습니다.',
    attendees: ['민지', '서준', '하린', '도윤', '지우'],
    tags: ['현대무용', '사운드', '을지로'],
    color: const Color(0xFF9CC9E8),
    pick: true,
  ),
  Event(
    id: 'e2',
    title: 'NO CAMERA NIGHT',
    category: '파티',
    venueId: 'v2',
    sessions: [_at(0, 23)],
    price: 25000,
    lineup: ['PONGPONG', 'HANJI', 'SEANXXX'],
    about: '휴대폰은 주머니에, 음악은 온몸으로. 촬영 없는 테크노 나잇.',
    entryInfo: '- 만 19세 이상 입장 가능합니다.\n- 입장 시 카메라에 스티커를 부착합니다.',
    attendees: ['유나', '현우', '소희'],
    tags: ['Techno', 'DJ', '홍대'],
    color: const Color(0xFF2B2B2B),
    pick: true,
  ),
  Event(
    id: 'e3',
    title: 'Sandi & Objktt Crew',
    category: '파티',
    venueId: 'v3',
    sessions: [_at(3, 22)],
    price: 30000,
    lineup: ['Sandi', 'Objktt Crew'],
    about: '자카르타에서 온 Sandi와 서울 크루 Objktt의 첫 합동 무대.',
    entryInfo: '- 만 19세 이상 입장 가능합니다.\n- 재입장 불가합니다.',
    attendees: ['태오', '나연'],
    tags: ['EDM', 'DJ', '강남'],
    color: const Color(0xFFE8C840),
    pick: true,
  ),
];

Venue venueById(String id) => venues.firstWhere((v) => v.id == id);
List<Event> eventsAtVenue(String venueId) => events.where((e) => e.venueId == venueId).toList();

List<AppNotification> initialNotifications() => [
  AppNotification(title: 'DYVE PICK 업데이트', body: '이번 주 에디터 추천 행사가 올라왔어요.', time: _at(0, 9)),
  AppNotification(title: '찜한 파티 오픈 임박', body: 'NO CAMERA NIGHT 가 오늘 밤 열려요.', time: _at(-1, 18)),
  AppNotification(title: '환영합니다', body: 'DYVE 토이 앱에 오신 것을 환영해요.', time: _at(-3, 12)),
];
