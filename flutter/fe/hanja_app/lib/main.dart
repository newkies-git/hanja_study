import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const HanjaApp());
}

class HanjaApp extends StatelessWidget {
  const HanjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '한자정습',
      debugShowCheckedModeBanner: false,
      theme: HanjaTheme.light(),
      home: const LandingScreen(),
    );
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.list, color: HanjaColors.onSurface),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "The Scholar's Editorial",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          color: HanjaColors.primaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const SizedBox(width: 24),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: HanjaColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 6))],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Welcome to Learning',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 10),
                Text(
                  'Master the art of Hanja with our curated educational journal interface.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const AppShell(initialIndex: 1)),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: HanjaColors.primaryContainer,
                      side: BorderSide(color: HanjaColors.outlineVariant.withValues(alpha: 0.15)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('학습 시작하기'),
                  ),
                ),
                const SizedBox(height: 12),
                GradientPrimaryButton(
                  label: '로그인',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _pwController = TextEditingController();
  bool _pwVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkResponse(
                      radius: 24,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back, color: HanjaColors.onSurface),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('이메일로 로그인', style: theme.textTheme.displaySmall),
                      const SizedBox(height: 8),
                      Text(
                        '학습을 이어가기 위해 정보를 입력해 주세요.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      children: [
                        _FieldLabel(label: '이메일'),
                        const SizedBox(height: 8),
                        EditorialTextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          hintText: '이메일 주소를 입력해 주세요',
                          validator: (v) => (v == null || v.trim().isEmpty) ? '이메일을 입력해 주세요' : null,
                        ),
                        const SizedBox(height: 20),
                        _FieldLabel(label: '비밀번호'),
                        const SizedBox(height: 8),
                        EditorialTextField(
                          controller: _pwController,
                          obscureText: !_pwVisible,
                          hintText: '비밀번호를 입력해 주세요',
                          suffix: IconButton(
                            onPressed: () => setState(() => _pwVisible = !_pwVisible),
                            icon: Icon(_pwVisible ? Icons.visibility_off : Icons.visibility, color: HanjaColors.outline),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? '비밀번호를 입력해 주세요' : null,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('비밀번호를 잊으셨나요?'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GradientPrimaryButton(
                          label: '로그인',
                          onPressed: () {
                            if (!(_formKey.currentState?.validate() ?? false)) return;
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const AppShell()),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(child: _GhostDivider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '또는',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: HanjaColors.outline,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                            const Expanded(child: _GhostDivider()),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: '아직 계정이 없으신가요? ',
                              style: theme.textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant),
                              children: [
                                TextSpan(
                                  text: '회원가입',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: HanjaColors.primaryContainer,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const LearnListScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: EditorialBottomNav(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

class EditorialBottomNav extends StatelessWidget {
  const EditorialBottomNav({super.key, required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = const [
      _BottomNavItem(icon: Icons.home, label: '홈'),
      _BottomNavItem(icon: Icons.menu_book, label: '학습'),
      _BottomNavItem(icon: Icons.analytics, label: '통계'),
      _BottomNavItem(icon: Icons.person, label: '내 정보'),
    ];

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < items.length; i++)
                _BottomNavButton(
                  item: items[i],
                  selected: i == index,
                  onTap: () => onChanged(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({required this.item, required this.selected, required this.onTap});
  final _BottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = selected ? HanjaColors.primaryContainer : const Color(0xFF9A9DA0);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: selected ? HanjaColors.primaryFixed.withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, color: fg),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditorialTopBar extends StatelessWidget {
  const EditorialTopBar({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          const Icon(Icons.menu, color: Color(0xFF9A9DA0)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: HanjaColors.primaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.account_circle, color: Color(0xFF9A9DA0)),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        const EditorialTopBar(title: "The Scholar's Editorial"),
        const SizedBox(height: 10),
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: HanjaColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 6))],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Welcome to Learning',
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(fontSize: 32),
        ),
        const SizedBox(height: 10),
        Text(
          'Master the art of Hanja with our curated educational journal interface.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant),
        ),
        const SizedBox(height: 22),
        Column(
          children: [
            SizedBox(
              height: 56,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: HanjaColors.primaryContainer,
                  side: BorderSide(color: HanjaColors.outlineVariant.withValues(alpha: 0.15)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('학습 시작하기'),
              ),
            ),
            const SizedBox(height: 12),
            GradientPrimaryButton(
              label: '연습 바로가기',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudyScreen()));
              },
            ),
          ],
        ),
      ],
    );
  }
}

class LearnListScreen extends StatelessWidget {
  const LearnListScreen({super.key});

  static const _hanjaList = [
    ('佳', '아름다울'),
    ('學', '배울'),
    ('印', '도장'),
    ('永', '길 영'),
    ('人', '사람'),
    ('木', '나무'),
    ('水', '물'),
    ('火', '불'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const EditorialTopBar(title: 'Hanja Jeongseup'),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Pill(label: '가나다순', selected: true, onTap: () {}),
                const SizedBox(width: 10),
                _Pill(label: '획수순', selected: false, onTap: () {}),
                const SizedBox(width: 10),
                _Pill(label: '랜덤', selected: false, onTap: () {}),
              ],
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
            ),
            itemCount: _hanjaList.length,
            itemBuilder: (context, i) {
              final item = _hanjaList[i];
              return _HanjaCard(
                hanja: item.$1,
                meaning: item.$2,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HanjaDetailScreen(
                      hanja: item.$1,
                      meaning: item.$2,
                      radical: '人',
                      radicalLabel: '사람인변',
                      totalStrokes: 8,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? HanjaColors.primaryFixed : HanjaColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? HanjaColors.primaryContainer : HanjaColors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _HanjaCard extends StatelessWidget {
  const _HanjaCard({required this.hanja, required this.meaning, required this.onTap});
  final String hanja;
  final String meaning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hanja, style: theme.textTheme.displaySmall?.copyWith(fontSize: 44, height: 1.0)),
              const Spacer(),
              Text(
                meaning,
                style: theme.textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        const EditorialTopBar(title: '학습 통계'),
        const SizedBox(height: 14),
        Text('주간 활동 분석', style: theme.textTheme.headlineSmall?.copyWith(color: HanjaColors.onSurfaceVariant)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final h = [0.4, 0.65, 0.35, 0.85, 0.55, 0.25, 0.15][i];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 140 * h,
                        decoration: BoxDecoration(
                          color: HanjaColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: 1,
                            widthFactor: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    HanjaColors.primary.withValues(alpha: i == 3 ? 1 : 0.55),
                                    HanjaColors.primaryContainer.withValues(alpha: i == 3 ? 1 : 0.55),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(['월', '화', '수', '목', '금', '토', '일'][i], style: theme.textTheme.labelSmall?.copyWith(color: HanjaColors.outline)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        const EditorialTopBar(title: '내 정보'),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Row(
            children: [
              const CircleAvatar(radius: 26, backgroundColor: HanjaColors.primaryFixed, child: Icon(Icons.person, color: HanjaColors.primaryContainer)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scholar', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('scholar@example.com', style: theme.textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_calendar, color: HanjaColors.primaryContainer),
                title: Text('학습 계획 설정', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                subtitle: Text('나만의 학습 리듬을 설정하세요', style: theme.textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanSettingsScreen())),
              ),
              Divider(height: 1, color: HanjaColors.outlineVariant.withValues(alpha: 0.15)),
              ListTile(
                leading: const Icon(Icons.logout, color: HanjaColors.tertiary),
                title: Text('로그아웃', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum HanjaDetailTab { info, strokes, words }

class HanjaDetailScreen extends StatefulWidget {
  const HanjaDetailScreen({
    super.key,
    required this.hanja,
    required this.meaning,
    required this.radical,
    required this.radicalLabel,
    required this.totalStrokes,
  });

  final String hanja;
  final String meaning;
  final String radical;
  final String radicalLabel;
  final int totalStrokes;

  @override
  State<HanjaDetailScreen> createState() => _HanjaDetailScreenState();
}

class _HanjaDetailScreenState extends State<HanjaDetailScreen> {
  HanjaDetailTab _tab = HanjaDetailTab.info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              children: [
                Row(
                  children: [
                    IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back)),
                    Expanded(
                      child: Text(
                        '한자정습',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: HanjaColors.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Icon(Icons.share, color: HanjaColors.onSurface),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    SizedBox(
                      width: 320,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 6))],
                          ),
                          child: Stack(
                            children: [
                              const Positioned.fill(child: WonGoJiGrid(opacity: 0.12)),
                              Center(
                                child: Text(
                                  widget.hanja,
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontSize: 120,
                                    color: HanjaColors.primary,
                                    height: 1,
                                  ),
                                ),
                              ),
                              const Positioned(
                                top: 14,
                                right: 14,
                                child: Icon(Icons.star, color: HanjaColors.tertiary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '뜻과 음',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF9A9DA0),
                        letterSpacing: 3.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.meaning,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontSize: 40,
                        color: HanjaColors.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _DetailTab(label: '기본 정보', selected: _tab == HanjaDetailTab.info, onTap: () => setState(() => _tab = HanjaDetailTab.info)),
                    const Spacer(),
                    _DetailTab(label: '획순 보기', selected: _tab == HanjaDetailTab.strokes, onTap: () => setState(() => _tab = HanjaDetailTab.strokes)),
                    const Spacer(),
                    _DetailTab(label: '관련 단어', selected: _tab == HanjaDetailTab.words, onTap: () => setState(() => _tab = HanjaDetailTab.words)),
                  ],
                ),
                const SizedBox(height: 18),
                if (_tab == HanjaDetailTab.info) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: HanjaColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('부수', style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF9A9DA0), letterSpacing: 2.2, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 10),
                              Text(widget.radical, style: theme.textTheme.headlineSmall?.copyWith(color: HanjaColors.secondary, fontSize: 30)),
                              const SizedBox(height: 6),
                              Text(widget.radicalLabel, style: theme.textTheme.bodySmall?.copyWith(color: HanjaColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: HanjaColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('총획', style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF9A9DA0), letterSpacing: 2.2, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 10),
                              Text('${widget.totalStrokes}', style: theme.textTheme.headlineSmall?.copyWith(color: HanjaColors.primary, fontSize: 30)),
                              const SizedBox(height: 6),
                              Text('전체 획수', style: theme.textTheme.bodySmall?.copyWith(color: HanjaColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: HanjaColors.outlineVariant.withValues(alpha: 0.05)),
                    ),
                    child: Text(
                      '“사람(人)과 규범적 형태가 결합된 자형으로, 옥(圭)처럼 맑고 깨끗한 사람을 아름답다고 한 데서 유래했습니다.”',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: HanjaColors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ] else if (_tab == HanjaDetailTab.strokes) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('획순 보기', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 12),
                        AspectRatio(
                          aspectRatio: 1.3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Stack(
                              children: [
                                const Positioned.fill(child: WonGoJiGrid(opacity: 0.14)),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    widget.hanja,
                                    style: theme.textTheme.displayLarge?.copyWith(
                                      fontSize: 110,
                                      color: const Color(0xFF9A9DA0).withValues(alpha: 0.22),
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const Positioned.fill(child: StrokeHintOverlay()),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(
                            widget.totalStrokes,
                            (i) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: HanjaColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Stroke ${i + 1}',
                                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: HanjaColors.onSurfaceVariant),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('관련 단어', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 12),
                        _RelatedWordTile(hanja: '${widget.hanja}人', meaning: '아름다운 사람'),
                        _RelatedWordTile(hanja: '${widget.hanja}作', meaning: '좋은 작품'),
                        _RelatedWordTile(hanja: '${widget.hanja}話', meaning: '아름다운 말'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: GradientPrimaryButton(
                    label: '쓰기 연습 시작',
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudyScreen())),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTab extends StatelessWidget {
  const _DetailTab({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? HanjaColors.primaryContainer : const Color(0xFF9A9DA0);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? HanjaColors.primaryContainer : HanjaColors.outlineVariant.withValues(alpha: 0.15),
              width: selected ? 2 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: selected ? FontWeight.w900 : FontWeight.w600),
        ),
      ),
    );
  }
}

class PracticeResultScreen extends StatelessWidget {
  const PracticeResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "The Scholar's Editorial",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          color: HanjaColors.primaryContainer,
                        ),
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 18),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(color: HanjaColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                      ),
                      Container(
                        width: 128,
                        height: 128,
                        decoration: const BoxDecoration(color: HanjaColors.primaryFixed, shape: BoxShape.circle),
                        child: const Icon(Icons.auto_awesome, size: 64, color: HanjaColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text('오늘의 학습 완료!', textAlign: TextAlign.center, style: theme.textTheme.displaySmall?.copyWith(fontSize: 30)),
                const SizedBox(height: 8),
                Text(
                  '위대한 학문의 길에 한 걸음 더 다가섰습니다.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: HanjaColors.outlineVariant.withValues(alpha: 0.10))),
                  child: Column(
                    children: [
                      Text(
                        'TOTAL CHARACTERS LEARNED',
                        style: theme.textTheme.labelMedium?.copyWith(color: HanjaColors.onSurfaceVariant, letterSpacing: 2.4, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      Text('5', style: theme.textTheme.displayLarge?.copyWith(color: HanjaColors.primaryContainer, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: HanjaColors.secondaryContainer, borderRadius: BorderRadius.circular(999)),
                        child: Text('+150 EXP', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GradientPrimaryButton(
                  label: '홈으로 돌아가기',
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AppShell(initialIndex: 0)),
                    (route) => false,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HanjaColors.surfaceContainerHigh,
                      foregroundColor: HanjaColors.onSurface,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AppShell(initialIndex: 2)),
                      (route) => false,
                    ),
                    child: Text('학습 통계 보기', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlanSettingsScreen extends StatefulWidget {
  const PlanSettingsScreen({super.key});

  @override
  State<PlanSettingsScreen> createState() => _PlanSettingsScreenState();
}

class _PlanSettingsScreenState extends State<PlanSettingsScreen> {
  int _daily = 5;
  int _order = 0; // 0 가나다순, 1 랜덤
  final _days = List<bool>.generate(7, (i) => i < 5);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                Row(
                  children: [
                    IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back, color: HanjaColors.primaryContainer)),
                    Expanded(
                      child: Text('학습 계획 설정', textAlign: TextAlign.center, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: HanjaColors.primaryContainer)),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 16),
                Text('ACADEMIC DISCIPLINE', style: theme.textTheme.labelSmall?.copyWith(color: HanjaColors.primaryContainer, letterSpacing: 2.2, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('지속적인 학습을 위한 나만의 계획을 세워보세요.', style: theme.textTheme.displaySmall?.copyWith(fontSize: 28)),
                const SizedBox(height: 22),
                Text('하루 학습량 설정', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Row(
                  children: [5, 10, 15, 20].map((n) {
                    final selected = n == _daily;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _PlanChoiceCard(
                          selected: selected,
                          onTap: () => setState(() => _daily = n),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$n', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: selected ? Colors.white : HanjaColors.onSurface)),
                              const SizedBox(height: 6),
                              Text('CHARS', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 2.2, color: selected ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF9A9DA0))),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList()
                    ..removeLast(),
                ),
                const SizedBox(height: 22),
                Text('학습 순서', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                _RadioRow(
                  selected: _order == 0,
                  icon: Icons.format_list_numbered,
                  label: '가나다순',
                  onTap: () => setState(() => _order = 0),
                ),
                const SizedBox(height: 10),
                _RadioRow(
                  selected: _order == 1,
                  icon: Icons.shuffle,
                  label: '랜덤',
                  onTap: () => setState(() => _order = 1),
                ),
                const SizedBox(height: 22),
                Text('학습 요일', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(7, (i) {
                      final selected = _days[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () => setState(() => _days[i] = !_days[i]),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: selected ? HanjaColors.primaryContainer : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: selected ? HanjaColors.primaryContainer : HanjaColors.outlineVariant),
                            ),
                            child: Center(
                              child: Text(
                                ['월', '화', '수', '목', '금', '토', '일'][i],
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: selected ? Colors.white : const Color(0xFF9A9DA0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8)),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: SizedBox(
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [HanjaColors.primary, HanjaColors.primaryContainer]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 10))],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: Text('설정 완료', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanChoiceCard extends StatelessWidget {
  const _PlanChoiceCard({required this.selected, required this.onTap, required this.child});
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? null : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HanjaColors.outlineVariant),
            gradient: selected ? const LinearGradient(colors: [HanjaColors.primary, HanjaColors.primaryContainer]) : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({required this.selected, required this.icon, required this.label, required this.onTap});
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: HanjaColors.primaryContainer),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? HanjaColors.primaryContainer : HanjaColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelatedWordTile extends StatelessWidget {
  const _RelatedWordTile({required this.hanja, required this.meaning});
  final String hanja;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HanjaColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(hanja, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                meaning,
                style: theme.textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant, fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right, color: HanjaColors.outline),
          ],
        ),
      ),
    );
  }
}

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _PracticeTopBar(
              lessonLabel: '제 4강',
              title: '한자정습',
              progress: 0.6,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  '佳',
                                  style: theme.textTheme.displayMedium?.copyWith(
                                    color: HanjaColors.onSurface.withValues(alpha: 0.1),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('참조', style: theme.textTheme.labelSmall),
                                ),
                              ],
                            ),
                            const SizedBox(width: 18),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('아름다울 (가)', style: theme.textTheme.headlineSmall),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.draw, size: 16, color: HanjaColors.primaryContainer),
                                    const SizedBox(width: 6),
                                    Text(
                                      '획 3 / 8',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: HanjaColors.primaryContainer,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GhostButton(
                        label: '힌트',
                        icon: Icons.lightbulb_outline,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const AspectRatio(
                    aspectRatio: 1,
                    child: PracticeCanvasCard(
                      hanja: '佳',
                      showNudge: true,
                    ),
                  ),
                  const SizedBox(height: 22),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      PracticeActionTile(icon: Icons.restart_alt, label: '초기화', onTap: () {}),
                      PracticeActionTile(icon: Icons.undo, label: '되돌리기', onTap: () {}),
                      PracticeActionTile(icon: Icons.visibility, label: '정답 보기', onTap: () {}),
                      PracticeActionTile(
                        icon: Icons.arrow_forward,
                        label: '완료',
                        variant: PracticeActionTileVariant.primary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PracticeResultScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeTopBar extends StatelessWidget {
  const _PracticeTopBar({
    required this.lessonLabel,
    required this.title,
    required this.progress,
    required this.onBack,
  });

  final String lessonLabel;
  final String title;
  final double progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white.withValues(alpha: 0.8),
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lessonLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: HanjaColors.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(title, style: theme.textTheme.titleLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 4,
            color: HanjaColors.surfaceContainerLow,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0, 1),
              child: const DecoratedBox(decoration: BoxDecoration(color: HanjaColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

class PracticeCanvasCard extends StatelessWidget {
  const PracticeCanvasCard({super.key, required this.hanja, this.showNudge = false});

  final String hanja;
  final bool showNudge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 32, offset: Offset(0, 10)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                const Positioned.fill(child: WonGoJiGrid(opacity: 0.18)),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      hanja,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: const Color(0xFF9A9DA0).withValues(alpha: 0.25),
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const Positioned.fill(child: StrokeHintOverlay()),
              ],
            ),
          ),
        ),
        if (showNudge)
          Positioned(
            top: -16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: HanjaColors.secondary,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 10)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      '훌륭해요! 다음 획',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class StrokeHintOverlay extends StatelessWidget {
  const StrokeHintOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StrokeHintPainter());
  }
}

class _StrokeHintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..color = HanjaColors.primary.withValues(alpha: 0.3)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final p2 = Paint()
      ..color = HanjaColors.primary
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final x1 = size.width * 0.30;
    final x2 = size.width * 0.55;
    final yTop1 = size.height * 0.25;
    final yBot1 = size.height * 0.75;

    canvas.drawLine(Offset(x1, yTop1), Offset(x1, yBot1), p1);
    canvas.drawLine(Offset(x2, size.height * 0.30), Offset(x2, size.height * 0.70), p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WonGoJiGrid extends StatelessWidget {
  const WonGoJiGrid({super.key, this.opacity = 0.2});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _WonGoJiGridPainter(opacity));
  }
}

class _WonGoJiGridPainter extends CustomPainter {
  _WonGoJiGridPainter(this.opacity);
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HanjaColors.outlineVariant.withValues(alpha: opacity)
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WonGoJiGridPainter oldDelegate) => oldDelegate.opacity != opacity;
}

enum PracticeActionTileVariant { neutral, primary }

class PracticeActionTile extends StatelessWidget {
  const PracticeActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.variant = PracticeActionTileVariant.neutral,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final PracticeActionTileVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrimary = variant == PracticeActionTileVariant.primary;
    return Material(
      color: isPrimary ? null : HanjaColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isPrimary ? const LinearGradient(colors: [HanjaColors.primary, HanjaColors.primaryContainer]) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isPrimary ? Colors.white : HanjaColors.onSurface),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isPrimary ? Colors.white : HanjaColors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700));
  }
}

class _GhostDivider extends StatelessWidget {
  const _GhostDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: HanjaColors.outlineVariant.withValues(alpha: 0.2));
  }
}

class EditorialTextField extends StatelessWidget {
  const EditorialTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: HanjaColors.surfaceContainerLow,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class GradientPrimaryButton extends StatelessWidget {
  const GradientPrimaryButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [HanjaColors.primary, HanjaColors.primaryContainer],
          ),
          borderRadius: BorderRadius.all(Radius.circular(999)),
          boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 10))],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: const StadiumBorder(),
          ),
          onPressed: onPressed,
          child: Text(label, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, required this.icon, required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: HanjaColors.onSurface),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: HanjaColors.surfaceContainerLow,
        foregroundColor: HanjaColors.onSurface,
        side: BorderSide(color: HanjaColors.outlineVariant.withValues(alpha: 0.15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}

class HanjaTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: HanjaColors.primary,
        onPrimary: HanjaColors.onPrimary,
        secondary: HanjaColors.secondary,
        error: HanjaColors.error,
        surface: HanjaColors.surface,
        onSurface: HanjaColors.onSurface,
      ),
    );

    final inter = GoogleFonts.interTextTheme(base.textTheme);
    final serif = GoogleFonts.notoSerifTextTheme(inter);

    return base.copyWith(
      scaffoldBackgroundColor: HanjaColors.surface,
      textTheme: serif.copyWith(
        bodyLarge: inter.bodyLarge,
        bodyMedium: inter.bodyMedium,
        bodySmall: inter.bodySmall,
        labelLarge: inter.labelLarge,
        labelMedium: inter.labelMedium,
        labelSmall: inter.labelSmall,
      ).copyWith(
        displaySmall: serif.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
        headlineSmall: serif.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2),
        titleLarge: inter.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: HanjaColors.primaryContainer),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: inter.bodyMedium?.copyWith(color: HanjaColors.outline),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: HanjaColors.primaryContainer,
          textStyle: inter.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class HanjaColors {
  static const primary = Color(0xFF003FB1);
  static const primaryContainer = Color(0xFF1A56DB);
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF006C4A);
  static const tertiary = Color(0xFF98000C);

  static const surface = Color(0xFFF8F9FA);
  static const onSurface = Color(0xFF191C1D);
  static const surfaceVariant = Color(0xFFE1E3E4);
  static const onSurfaceVariant = Color(0xFF434654);
  static const outline = Color(0xFF737686);
  static const outlineVariant = Color(0xFFC3C5D7);

  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const surfaceContainer = Color(0xFFEDEEEF);
  static const surfaceContainerHigh = Color(0xFFE7E8E9);
  static const surfaceContainerHighest = Color(0xFFE1E3E4);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);

  static const primaryFixed = Color(0xFFDBE1FF);
  static const secondaryContainer = Color(0xFF82F5C1);

  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
}
