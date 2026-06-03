import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
import 'package:frontend/txt_styles.dart';

enum NotifyType { success, error, info }

class AppNotify {
  static void show(BuildContext context, {required String message, NotifyType type = NotifyType.info}) {
    final overlay = Overlay.of(context);

    final color = switch (type) {
      NotifyType.success => darkGreenC,
      NotifyType.error => Color.fromRGBO(200, 0, 0, 1),
      NotifyType.info => lightBlackC,
    };

    final icon = switch (type) {
      NotifyType.success => Icons.check_circle,
      NotifyType.error => Icons.error_outline_rounded,
      NotifyType.info => Icons.info,
    };

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          right: 24,
          bottom: 24,
          child: _NotifyWidget(message: message, color: color, icon: icon, onClose: () => entry.remove()),
        );
      },
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class _NotifyWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onClose;

  const _NotifyWidget({required this.message, required this.color, required this.icon, required this.onClose});

  @override
  State<_NotifyWidget> createState() => _NotifyWidgetState();
}

class _NotifyWidgetState extends State<_NotifyWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _offset = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: FadeTransition(
        opacity: _opacity,
        child: Material(
          color: widget.color,
          shape: IOSLikeShape(20),
          child: SizedBox(
            width: 350,
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: milkC, size: 24),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 250,
                    child: Text(widget.message, style: TxtStyles.bodyMedium.copyWith(color: milkC)),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: widget.onClose,
                    child: const Icon(Icons.close, color: milkC, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
