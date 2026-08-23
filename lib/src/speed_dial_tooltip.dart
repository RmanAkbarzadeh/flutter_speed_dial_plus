import 'package:material_ui/material_ui.dart';

class SpeedDialTooltip extends StatefulWidget {
  final String message;
  final Widget child;

  const SpeedDialTooltip({
    Key? key,
    required this.message,
    required this.child,
  }) : super(key: key);

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
          top: position.dy + (renderBox.size.height / 2) - 16,
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
