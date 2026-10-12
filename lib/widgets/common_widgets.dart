import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Chunky box: thick dark outline with a solid "3D" layer underneath.
BoxDecoration chunkyDecoration({
  Color color = AppColors.tile,
  double radius = 18,
  double depth = 5,
  Color depthColor = AppColors.depth,
  double borderWidth = 3,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.outline, width: borderWidth),
    boxShadow: depth <= 0
        ? null
        : [
            // Outline of the 3D layer.
            BoxShadow(
              color: AppColors.outline,
              offset: Offset(0, depth),
              blurRadius: 0,
            ),
            // Colored 3D layer, slightly smaller so the outline shows around it.
            BoxShadow(
              color: depthColor,
              offset: Offset(0, depth),
              blurRadius: 0,
              spreadRadius: -borderWidth,
            ),
          ],
  );
}

/// Any tappable box that "sinks" when pressed, like the template's buttons.
class Pressable3D extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color depthColor;
  final double radius;
  final double depth;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  const Pressable3D({
    super.key,
    required this.child,
    required this.onTap,
    this.color = AppColors.tile,
    this.depthColor = AppColors.depth,
    this.radius = 18,
    this.depth = 5,
    this.padding = EdgeInsets.zero,
    this.semanticLabel,
  });

  @override
  State<Pressable3D> createState() => _Pressable3DState();
}

class _Pressable3DState extends State<Pressable3D> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final currentDepth = _pressed ? 1.0 : widget.depth;

    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: Opacity(
          opacity: widget.onTap == null ? 0.55 : 1,
          child: Padding(
            // Reserve room for the 3D layer so the layout doesn't jump.
            padding: EdgeInsets.only(bottom: widget.depth),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 70),
              transform: Matrix4.translationValues(
                  0, widget.depth - currentDepth, 0),
              decoration: chunkyDecoration(
                color: widget.color,
                radius: widget.radius,
                depth: currentDepth,
                depthColor: widget.depthColor,
              ),
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Chunky button with a label and/or icon. Icon only = square button.
class ChunkyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final Color depthColor;
  final bool expand;
  final bool compact;
  final String? tooltip;

  const ChunkyButton({
    super.key,
    this.label,
    this.icon,
    required this.onPressed,
    this.color = AppColors.primary,
    this.textColor = AppColors.outline,
    this.depthColor = AppColors.depth,
    this.expand = false,
    this.compact = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final iconOnly = label == null;

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Icon(icon, color: textColor, size: compact ? 20 : 26),
        if (icon != null && !iconOnly) const SizedBox(width: 10),
        if (!iconOnly)
          Text(
            label!,
            style: AppTheme.font(
              size: compact ? 16 : 19,
              weight: FontWeight.w600,
              color: textColor,
            ),
          ),
      ],
    );

    Widget button = Pressable3D(
      onTap: onPressed,
      color: color,
      depthColor: depthColor,
      radius: iconOnly ? 14 : 22,
      depth: compact ? 4 : 6,
      semanticLabel: label ?? tooltip,
      padding: iconOnly
          ? EdgeInsets.all(compact ? 7 : 9)
          : EdgeInsets.symmetric(
              horizontal: compact ? 18 : 26, vertical: compact ? 9 : 13),
      child: content,
    );

    if (expand) button = SizedBox(width: double.infinity, child: button);
    if (tooltip != null) button = Tooltip(message: tooltip!, child: button);
    return button;
  }
}

/// AppBar with the title inside a cream pill and chunky square buttons.
class PastelAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const PastelAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(84);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 78,
      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: ChunkyButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            )
          : null,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.outline, width: 3),
        ),
        child: Text(
          title,
          style: AppTheme.font(size: 22, weight: FontWeight.w600),
        ),
      ),
      actions: actions,
    );
  }
}

/// Square chunky button for the AppBar's right side.
class AppBarAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const AppBarAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Center(
        child: ChunkyButton(icon: icon, tooltip: tooltip, onPressed: onPressed),
      ),
    );
  }
}

/// Big green "window" panel with a dashed inner border.
class PastelPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const PastelPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Container(
        decoration: chunkyDecoration(
          color: AppColors.primary,
          radius: 28,
          depth: 7,
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      const Radius.circular(20),
    );
    final paint = Paint()
      ..color = AppColors.depth.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 10), paint);
        distance += 18;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cream square with the post number (e.g. "12").
class IdBadge extends StatelessWidget {
  final int id;

  const IdBadge({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.outline, width: 2.5),
      ),
      child: Text('$id', style: AppTheme.font(size: 16, weight: FontWeight.w700)),
    );
  }
}

/// Small cream tile with an icon and text (used for counts in headers).
class StatTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const StatTile({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline, width: 2.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.outline),
          const SizedBox(width: 6),
          Text(text, style: AppTheme.font(size: 15, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Big outlined circle with an icon (empty, error and result states).
class CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const CircleIcon({
    super.key,
    required this.icon,
    this.color = AppColors.cream,
    this.size = 92,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline, width: 3),
        boxShadow: const [
          BoxShadow(color: AppColors.outline, offset: Offset(0, 5)),
        ],
      ),
      child: Icon(icon, size: size * 0.48, color: AppColors.outline),
    );
  }
}