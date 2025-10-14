import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Exported bottom padding used by pages so scrollables clear the expanded arc.
const double kExpandableFabBottomPadding = 120;

/// Expandable FAB implemented using an OverlayEntry so the expanded actions
/// float above page content cleanly. Shows a dimmed scrim that closes on tap.
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({super.key});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  OverlayEntry? _overlay;
  bool get _open => _controller.status == AnimationStatus.forward || _controller.status == AnimationStatus.completed;

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlay != null) return;
    _overlay = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context, rootOverlay: true).insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _toggle() {
    if (_open) {
      HapticFeedback.lightImpact();
      _controller.reverse();
    } else {
      _showOverlay();
      HapticFeedback.lightImpact();
      _controller.forward();
    }
  }

  void _navigateAdd(BuildContext context, String type, {String? voicePrefill}) {
    HapticFeedback.selectionClick();
    _controller.reverse();
    context.push('/add?type=$type', extra: voicePrefill);
  }

  Widget _buildOverlay(BuildContext context) {
    final media = MediaQuery.of(context);
    final center = Offset(media.size.width / 2, media.size.height - 36 - 30); // FAB center estimate

    final actions = <_ActionSpec>[
      _ActionSpec('Income', Icons.add_circle_outline, Colors.green.shade600,
          (c) => _navigateAdd(c, 'income')),
      _ActionSpec('Expense', Icons.remove_circle_outline, Colors.red.shade400,
          (c) => _navigateAdd(c, 'expense')),
      _ActionSpec('Voice', Icons.mic_none, Colors.deepPurple,
          (c) => _navigateAdd(c, 'expense', voicePrefill: 'Voice note')),
      _ActionSpec('Receipt', Icons.receipt_long_outlined, Colors.indigo,
          (c) => _navigateAdd(c, 'expense')), // TODO specialized flow
    ];

    // Layout in an upward 100° fan (from 200° to 300° polar angles)
    const double sweepDeg = 100;
    final double startDeg = 200;
    final double radius = 110;

    return AnimatedBuilder(
      animation: _curve,
      builder: (context, _) {
        final progress = _curve.value;
        if (progress == 0 && _overlay != null && !_open) {
          // Delay removal to next frame so FAB rebuild can finish.
          WidgetsBinding.instance.addPostFrameCallback((_) => _removeOverlay());
        }
        return Stack(
          children: [
            // Scrim
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggle,
                child: AnimatedOpacity(
                  opacity: progress > 0 ? 0.35 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(color: Colors.black),
                ),
              ),
            ),
            // Action buttons
            ...List.generate(actions.length, (i) {
              final t = actions.length == 1 ? 0.5 : i / (actions.length - 1);
              final angleDeg = startDeg + t * sweepDeg;
              final angleRad = angleDeg * math.pi / 180;
              final offset = Offset(
                center.dx + radius * progress * math.cos(angleRad),
                center.dy + radius * progress * math.sin(angleRad),
              );
              final fade = Curves.easeOut.transform(progress);
              return Positioned(
                left: offset.dx - 24,
                top: offset.dy - 24,
                child: Opacity(
                  opacity: fade,
                  child: Transform.scale(
                    scale: fade,
                    child: _ActionButton(spec: actions[i]),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _toggle,
      child: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: _curve,
      ),
    );
  }
}

class _ActionSpec {
  final String label;
  final IconData icon;
  final Color color;
  final void Function(BuildContext) onTap;
  const _ActionSpec(this.label, this.icon, this.color, this.onTap);
}

class _ActionButton extends StatelessWidget {
  final _ActionSpec spec;
  const _ActionButton({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: spec.color,
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => spec.onTap(context),
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Center(child: _ActionIcon()),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            spec.label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// Separate stateless icon to avoid rebuilding label styling on animation frames.
class _ActionIcon extends StatelessWidget {
  const _ActionIcon();
  @override
  Widget build(BuildContext context) {
    // Icon color baked in by parent Material background.
    final parent = context.findAncestorWidgetOfExactType<_ActionButton>()?.spec;
    return Icon(parent?.icon, color: Colors.white, size: 26);
  }
}
