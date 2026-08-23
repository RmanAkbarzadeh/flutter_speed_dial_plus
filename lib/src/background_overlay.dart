library flutter_speed_dial_plus;

import 'package:material_ui/material_ui.dart';
import 'global_key_extension.dart';

class BackgroundOverlay extends AnimatedWidget {
  final Color color;
  final double opacity;
  final GlobalKey dialKey;
  final LayerLink layerLink;
  final ShapeBorder shape;
  final VoidCallback? onTap;
  final bool closeManually;
  final String? tooltip;

  const BackgroundOverlay({
    Key? key,
    this.onTap,
    required this.shape,
    required Animation<double> animation,
    required this.dialKey,
    required this.layerLink,
    required this.closeManually,
    required this.tooltip,
    this.color = Colors.white,
    this.opacity = 0.7,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    return ColorFiltered(
        colorFilter: ColorFilter.mode(
            color.withOpacity(opacity * animation.value), BlendMode.srcOut),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: closeManually ? null : onTap,
              child: Container(
                decoration: BoxDecoration(
                    color: color, backgroundBlendMode: BlendMode.dstOut),
              ),
            ),
            Positioned(
              width: dialKey.globalPaintBounds?.size.width,
              child: CompositedTransformFollower(
                link: layerLink,
                showWhenUnlinked: false,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: () {
                    final Widget child = GestureDetector(
                      onTap: onTap,
                      child: Container(
                        width: dialKey.globalPaintBounds?.size.width,
                        height: dialKey.globalPaintBounds?.size.height,
                        decoration: ShapeDecoration(
                          shape: shape == const CircleBorder()
                              ? const StadiumBorder()
                              : shape,
                          color: Colors.white,
                        ),
                      ),
                    );
                    return tooltip != null && tooltip!.isNotEmpty
                        ? SpeedDialTooltip(
                            message: tooltip!,
                            child: child,
                          )
                        : child;
                  }(),
                ),
              ),
            ),
          ],
        ));
  }
}

class SpeedDialTooltip extends StatefulWidget {
  final String message;
  final Widget child;

  const SpeedDialTooltip({
    required this.message,
    required this.child,
  });

  @override
  State<SpeedDialTooltip> createState() => _SpeedDialTooltipState();
}

class _SpeedDialTooltipState extends State<SpeedDialTooltip> {
  OverlayEntry? _overlayEntry;

  void _showTooltip() {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox;

    final position = renderBox.localToGlobal(
      Offset.zero,
    );

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx + renderBox.size.width + 8,
          top: position.dy +
              (renderBox.size.height / 2) -
              16,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _showTooltip(),
      onExit: (_) => _hideTooltip(),
      child: widget.child,
    );
  }
}
