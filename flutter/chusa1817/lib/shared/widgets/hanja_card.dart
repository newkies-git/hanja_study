import 'package:flutter/material.dart';
import '../../core/theme/hanja_colors.dart';

/// 한자와 뜻을 보여주는 기본 범용 카드 UI
class HanjaCard extends StatelessWidget {
  const HanjaCard({
    super.key,
    required this.hanja,
    required this.meaning,
    required this.onTap,
  });

  final String hanja;
  final String meaning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: () {
            // 리플(터치) 애니메이션이 보일 수 있도록 아주 짧은 지연시간 부여
            Future.delayed(const Duration(milliseconds: 150), onTap);
          },
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hanja,
                  style: textTheme.displaySmall?.copyWith(
                    fontSize: 44,
                    height: 1.0,
                  ),
                ),
                const Spacer(),
                Text(
                  meaning,
                  style: textTheme.bodyMedium?.copyWith(
                    color: HanjaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
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
