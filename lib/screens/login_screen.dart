import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/common.dart';

/// 모의 로그인. 버튼은 로그인 플래그만 켠다 (실제 인증 없음).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _login(BuildContext context, String provider) {
    AppScope.read(context).login(provider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$provider 계정으로 로그인했어요 (모의 로그인).')));
    Navigator.of(context).pop();
  }

  Widget _button(BuildContext context, String provider, Color bg, Color fg, IconData icon) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(backgroundColor: bg, foregroundColor: fg, minimumSize: const Size.fromHeight(56)),
      onPressed: () => _login(context, provider),
      icon: Icon(icon),
      label: Text('$provider로 계속하기', style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('로그인', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('파티를 발견하고, 친구들과 함께 즐겨보세요.', style: TextStyle(color: kMuted)),
            const SizedBox(height: 32),
            _button(context, '카카오', const Color(0xFFFAE54D), Colors.black, Icons.chat_bubble),
            const SizedBox(height: 12),
            _button(context, '네이버', const Color(0xFF5AC466), Colors.white, Icons.north_east),
            const SizedBox(height: 24),
            const Text('토이 앱이라 실제 인증 없이 로그인 상태만 바뀝니다.', style: TextStyle(color: kMuted, fontSize: 12)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
