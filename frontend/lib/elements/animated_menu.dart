import 'dart:ui';
import 'package:flutter/material.dart';

enum AnimatedMenuDirection { auto, bottomLeft, bottomCenter, bottomRight, topLeft, topCenter, topRight }

typedef AnimatedMenuWidgetBuilder = Widget Function(BuildContext context, VoidCallback close);

class AnimatedMenu {
  AnimatedMenu._();

  static Future<void> show({
    required BuildContext context,
    required GlobalKey anchorKey,
    required double width,
    required double height,
    required AnimatedMenuWidgetBuilder builder,
    Color backgroundColor = Colors.white,
    Color barrierColor = const Color(0x14000000),
    // double startBorderRadius = 20,
    // double endBorderRadius = 28,
    ShapeBorder? shape,
    double elevation = 14,
    double blurSigma = 2,
    EdgeInsets padding = const EdgeInsets.all(0),
    Duration duration = const Duration(milliseconds: 260),
    Duration reverseDuration = const Duration(milliseconds: 220),
    bool closeOnTapOutside = true,
    double screenMargin = 16,
    double spacing = 8,
    Offset offset = Offset.zero,
    AnimatedMenuDirection preferredDirection = AnimatedMenuDirection.auto,
    Alignment closedAlignment = Alignment.center,
    Alignment openAlignment = Alignment.topRight,
  }) async {
    final overlayState = Overlay.of(context);
    final navigator = Navigator.of(context);

    final anchorContext = anchorKey.currentContext;
    if (anchorContext == null) return;

    final anchorRenderBox = anchorContext.findRenderObject() as RenderBox?;
    final overlayRenderBox = overlayState.context.findRenderObject() as RenderBox?;

    if (anchorRenderBox == null || overlayRenderBox == null || !anchorRenderBox.attached || !overlayRenderBox.attached) {
      return;
    }

    final anchorTopLeft = anchorRenderBox.localToGlobal(Offset.zero, ancestor: overlayRenderBox);

    final anchorSize = anchorRenderBox.size;
    final overlaySize = overlayRenderBox.size;

    final startRect = Rect.fromLTWH(anchorTopLeft.dx, anchorTopLeft.dy, anchorSize.width, anchorSize.height);

    final endRect = _calculateMenuRect(
      startRect: startRect,
      overlaySize: overlaySize,
      menuWidth: width,
      menuHeight: height,
      screenMargin: screenMargin,
      spacing: spacing,
      offset: offset,
      preferredDirection: preferredDirection,
    );

    final controller = AnimationController(vsync: navigator, duration: duration, reverseDuration: reverseDuration);

    OverlayEntry? entry;
    bool isClosing = false;

    Future<void> close() async {
      if (isClosing) return;
      isClosing = true;

      try {
        if (controller.status != AnimationStatus.dismissed) {
          await controller.reverse();
        }
      } finally {
        entry?.remove();
        entry = null;
        controller.dispose();
      }
    }

    entry = OverlayEntry(
      builder: (overlayContext) {
        return _AnimatedMenuOverlay(
          controller: controller,
          close: close,
          closeOnTapOutside: closeOnTapOutside,
          barrierColor: barrierColor,
          blurSigma: blurSigma,
          child: _AnimatedMenuSheet(
            controller: controller,
            startRect: startRect,
            endRect: endRect,
            // startBorderRadius: startBorderRadius,
            // endBorderRadius: endBorderRadius,
            shape: shape,
            backgroundColor: backgroundColor,
            elevation: elevation,
            padding: padding,
            closedAlignment: closedAlignment,
            openAlignment: openAlignment,
            childBuilder: builder,
            close: close,
          ),
        );
      },
    );

    overlayState.insert(entry!);
    await controller.forward(from: 0);
  }

  static Rect _calculateMenuRect({
    required Rect startRect,
    required Size overlaySize,
    required double menuWidth,
    required double menuHeight,
    required double screenMargin,
    required double spacing,
    required Offset offset,
    required AnimatedMenuDirection preferredDirection,
  }) {
    final spaceBelow = overlaySize.height - startRect.bottom - screenMargin;
    final spaceAbove = startRect.top - screenMargin;

    final _ResolvedMenuDirection resolvedDirection = _resolveDirection(
      preferredDirection: preferredDirection,
      spaceBelow: spaceBelow,
      spaceAbove: spaceAbove,
      menuHeight: menuHeight,
    );

    final bool openDown = resolvedDirection.vertical == _MenuVertical.bottom;

    double left = switch (resolvedDirection.horizontal) {
      _MenuHorizontal.left => startRect.left,
      _MenuHorizontal.center => startRect.center.dx - menuWidth / 2,
      _MenuHorizontal.right => startRect.right - menuWidth,
    };

    double top = openDown ? startRect.bottom + spacing : startRect.top - menuHeight - spacing;

    left += offset.dx;
    top += offset.dy;

    if (left < screenMargin) {
      left = screenMargin;
    }
    if (left + menuWidth > overlaySize.width - screenMargin) {
      left = overlaySize.width - screenMargin - menuWidth;
    }

    if (top < screenMargin) {
      top = screenMargin;
    }
    if (top + menuHeight > overlaySize.height - screenMargin) {
      top = overlaySize.height - screenMargin - menuHeight;
    }

    return Rect.fromLTWH(left, top, menuWidth, menuHeight);
  }

  static _ResolvedMenuDirection _resolveDirection({
    required AnimatedMenuDirection preferredDirection,
    required double spaceBelow,
    required double spaceAbove,
    required double menuHeight,
  }) {
    if (preferredDirection != AnimatedMenuDirection.auto) {
      return switch (preferredDirection) {
        AnimatedMenuDirection.bottomLeft => const _ResolvedMenuDirection(
          vertical: _MenuVertical.bottom,
          horizontal: _MenuHorizontal.left,
        ),
        AnimatedMenuDirection.bottomCenter => const _ResolvedMenuDirection(
          vertical: _MenuVertical.bottom,
          horizontal: _MenuHorizontal.center,
        ),
        AnimatedMenuDirection.bottomRight => const _ResolvedMenuDirection(
          vertical: _MenuVertical.bottom,
          horizontal: _MenuHorizontal.right,
        ),
        AnimatedMenuDirection.topLeft => const _ResolvedMenuDirection(
          vertical: _MenuVertical.top,
          horizontal: _MenuHorizontal.left,
        ),
        AnimatedMenuDirection.topCenter => const _ResolvedMenuDirection(
          vertical: _MenuVertical.top,
          horizontal: _MenuHorizontal.center,
        ),
        AnimatedMenuDirection.topRight => const _ResolvedMenuDirection(
          vertical: _MenuVertical.top,
          horizontal: _MenuHorizontal.right,
        ),
        AnimatedMenuDirection.auto => const _ResolvedMenuDirection(
          vertical: _MenuVertical.bottom,
          horizontal: _MenuHorizontal.right,
        ),
      };
    }

    final openDown = spaceBelow >= menuHeight || spaceBelow >= spaceAbove;

    return _ResolvedMenuDirection(
      vertical: openDown ? _MenuVertical.bottom : _MenuVertical.top,
      horizontal: _MenuHorizontal.right,
    );
  }
}

enum _MenuVertical { top, bottom }

enum _MenuHorizontal { left, center, right }

class _ResolvedMenuDirection {
  const _ResolvedMenuDirection({required this.vertical, required this.horizontal});

  final _MenuVertical vertical;
  final _MenuHorizontal horizontal;
}

class _AnimatedMenuOverlay extends StatelessWidget {
  const _AnimatedMenuOverlay({
    required this.controller,
    required this.close,
    required this.closeOnTapOutside,
    required this.barrierColor,
    required this.blurSigma,
    required this.child,
  });

  final AnimationController controller;
  final Future<void> Function() close;
  final bool closeOnTapOutside;
  final Color barrierColor;
  final double blurSigma;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final barrierAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOut, reverseCurve: Curves.easeIn);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: closeOnTapOutside ? close : null,
            child: AnimatedBuilder(
              animation: barrierAnimation,
              builder: (context, _) {
                final t = barrierAnimation.value;

                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurSigma * t, sigmaY: blurSigma * t),
                  child: ColoredBox(color: Color.lerp(Colors.transparent, barrierColor, t)!),
                );
              },
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _AnimatedMenuSheet extends StatefulWidget {
  const _AnimatedMenuSheet({
    required this.controller,
    required this.startRect,
    required this.endRect,
    // required this.startBorderRadius,
    // required this.endBorderRadius,
    required this.shape,
    required this.backgroundColor,
    required this.elevation,
    required this.padding,
    required this.closedAlignment,
    required this.openAlignment,
    required this.childBuilder,
    required this.close,
  });

  final AnimationController controller;
  final Rect startRect;
  final Rect endRect;
  // final double startBorderRadius;
  // final double endBorderRadius;
  final ShapeBorder? shape;
  final Color backgroundColor;
  final double elevation;
  final EdgeInsets padding;
  final Alignment closedAlignment;
  final Alignment openAlignment;
  final AnimatedMenuWidgetBuilder childBuilder;
  final Future<void> Function() close;

  @override
  State<_AnimatedMenuSheet> createState() => _AnimatedMenuSheetState();
}

class _AnimatedMenuSheetState extends State<_AnimatedMenuSheet> {
  late final Animation<Rect?> _rectAnimation;
  // late final Animation<double> _radiusAnimation;
  late final Animation<double> _contentOpacityAnimation;
  late final Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();
    final rectCurve = CurvedAnimation(parent: widget.controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

    _rectAnimation = RectTween(begin: widget.startRect, end: widget.endRect).animate(rectCurve);
    // _radiusAnimation = Tween<double>(begin: widget.startBorderRadius, end: widget.endBorderRadius).animate(rectCurve);
    _contentOpacityAnimation = CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(0.18, 1.0, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 0.65, curve: Curves.easeIn),
    );
    _alignmentAnimation = AlignmentTween(begin: widget.closedAlignment, end: widget.openAlignment).animate(rectCurve);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final isClosing = widget.controller.status == AnimationStatus.reverse;
        final rect = isClosing ? widget.endRect : _rectAnimation.value!;
        // final radius = isClosing ? widget.endBorderRadius : _radiusAnimation.value;
        final alignment = isClosing ? widget.openAlignment : _alignmentAnimation.value;
        final sheetOpacity = isClosing ? widget.controller.value : 1.0;

        return Positioned(
          left: rect.left,
          top: rect.top,
          width: rect.width,
          height: rect.height,
          child: Opacity(
            opacity: sheetOpacity.clamp(0.0, 1.0),
            child: Material(
              color: widget.backgroundColor,
              elevation: 6,
              // borderRadius: BorderRadius.circular(radius),
              shape: widget.shape,
              clipBehavior: Clip.antiAlias,
              child: Align(
                alignment: alignment,
                child: SizedBox(
                  width: rect.width,
                  height: rect.height,
                  child: Padding(
                    padding: widget.padding,
                    child: isClosing
                        ? const SizedBox.shrink()
                        : Opacity(
                            opacity: _contentOpacityAnimation.value,
                            child: IgnorePointer(
                              ignoring: _contentOpacityAnimation.value < 0.99,
                              child: widget.childBuilder(context, () {
                                widget.close();
                              }),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
