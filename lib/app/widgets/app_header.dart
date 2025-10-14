import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key, this.showSearch = true});

  final bool showSearch;

  @override
  Size get preferredSize => const Size.fromHeight(140);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withOpacity(.95),
                scheme.primary.withOpacity(.90),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _HeaderCirclesPainter(color: scheme.onPrimary.withOpacity(0.08)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/account'),
                        child: CircleAvatar(
                          backgroundColor: scheme.onPrimary.withOpacity(.15),
                          child: const Text('J'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good afternoon,', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onPrimary.withOpacity(.9))),
                            Text(
                              'Enjelin Morgeana',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      _NotificationButton(color: scheme.onPrimary.withOpacity(.18), iconColor: scheme.onPrimary),
                    ],
                  ),
                  if (showSearch) const SizedBox(height: 16),
                  if (showSearch)
                    TextField(
                      onTap: () => context.go('/search'),
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: scheme.onPrimary.withOpacity(.12),
                        hintText: 'Search transactions',
                        hintStyle: TextStyle(color: scheme.onPrimary.withOpacity(.9)),
                        prefixIcon: Icon(Icons.search, color: scheme.onPrimary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
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

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.color, required this.iconColor});
  final Color color;
  final Color iconColor;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: Icon(Icons.notifications_none, color: iconColor),
            onPressed: () {},
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCirclesPainter extends CustomPainter {
  final Color color;
  const _HeaderCirclesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 40..color = color;
    final center = Offset(size.width * .65, size.height * .2);
    canvas.drawCircle(center, size.width * .55, paint);
    canvas.drawCircle(center, size.width * .35, paint);
  }

  @override
  bool shouldRepaint(covariant _HeaderCirclesPainter oldDelegate) => oldDelegate.color != color;
}
