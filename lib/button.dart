// ignore_for_file: cascade_invocations

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

const _customCurve = Cubic(0.2, 0.8, 0, 1);
const _buttonOuterPadding = 24.5;
const _spinningTextPadding = 4.0;

class FeedbackButton extends StatefulWidget {
  const FeedbackButton({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  State<FeedbackButton> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends State<FeedbackButton>
    with TickerProviderStateMixin {
  final _isPressed = ValueNotifier(false);

  late final _spinningController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );

  late final _blueprintController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final _blueprintAnimation = CurveTween(curve: _customCurve).animate(
    _blueprintController,
  );

  late final _decorationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final _decorationAnimation = CurveTween(curve: _customCurve).animate(
    _decorationController,
  );

  final _labelTextStyle = GoogleFonts.dmMono(
    fontFeatures: [
      const FontFeature.tabularFigures(),
      const FontFeature.liningFigures(),
      FontFeature.stylisticSet(1),
    ],
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 24 / 14,
  );

  final _rotatedTextStyle = GoogleFonts.dmMono(
    fontFeatures: [
      const FontFeature.tabularFigures(),
      const FontFeature.liningFigures(),
      FontFeature.stylisticSet(1),
    ],
    fontWeight: FontWeight.w700,
    fontSize: 11,
    height: 1,
    letterSpacing: 6.1,
  );

  @override
  void initState() {
    super.initState();
    _spinningController.repeat();
  }

  @override
  void dispose() {
    _isPressed.dispose();
    _spinningController.dispose();
    _blueprintController.dispose();
    _decorationController.dispose();
    super.dispose();
  }

  void _showBlueprint() {
    _blueprintController.forward();
    _decorationController.forward();
  }

  void _hideBlueprint() {
    _blueprintController.value = 0.1;
    _decorationController.value = 0.1;
    _blueprintController.reverse();
    _decorationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _isPressed.value = true,
      onTapUp: (_) {
        widget.onPressed();
        _isPressed.value = false;
      },
      onTapCancel: () => _isPressed.value = false,
      child: MouseRegion(
        onEnter: (_) => _showBlueprint(),
        onExit: (_) => _hideBlueprint(),
        cursor: SystemMouseCursors.click,
        child: RepaintBoundary(
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle.
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _blueprintAnimation,
                    builder: (context, child) {
                      return DecoratedBox(
                        decoration: BoxDecoration.lerp(
                          const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Color.fromRGBO(240, 244, 250, 1),
                                Color.fromRGBO(240, 244, 250, 1),
                              ],
                              stops: [0, 1],
                            ),
                          ),
                          const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Color(0xFF6391E9), Color(0xFF385DE0)],
                              stops: [0.245, 1],
                              center: Alignment.topCenter,
                              radius: 1,
                            ),
                          ),
                          _blueprintAnimation.value,
                        )!,
                      );
                    },
                  ),
                ),
                // Background circle shadow.
                Positioned.fill(
                  child: ValueListenableBuilder(
                    valueListenable: _isPressed,
                    builder: (context, isPressed, _) {
                      if (!isPressed) {
                        return const SizedBox.shrink();
                      }

                      return const DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x22000000),
                        ),
                      );
                    },
                  ),
                ),
                // Label with decoration.
                _LabelDecoration(
                  blueprintAnimation: _blueprintAnimation,
                  decorationAnimation: _decorationAnimation,
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 1,
                      horizontal: 6,
                    ),
                    child: AnimatedBuilder(
                      animation: _decorationAnimation,
                      builder: (context, _) {
                        return Text(
                          'beta',
                          overflow: TextOverflow.ellipsis,
                          style: _labelTextStyle.copyWith(
                            color: Color.lerp(
                              const Color(0xFF15171B),
                              Colors.white,
                              _decorationAnimation.value,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Spinning text.
                Positioned.fill(
                  child: _SpinningText(
                    text: 'GIVE US YOUR FEEDBACK · ',
                    style: _rotatedTextStyle,
                    spinningAnimation: _spinningController,
                    blueprintAnimation: _blueprintAnimation,
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

class _LabelDecoration extends SingleChildRenderObjectWidget {
  const _LabelDecoration({
    required this.blueprintAnimation,
    required this.decorationAnimation,
    required Widget label,
  }) : super(child: label);

  /// Determines the blueprint appearance.
  final Animation<double> blueprintAnimation;

  /// Determines the decoration appearance.
  final Animation<double> decorationAnimation;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLabelDecoration(
      blueprintAnimation: blueprintAnimation,
      decorationAnimation: decorationAnimation,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderLabelDecoration renderObject,
  ) {
    renderObject
      ..blueprintAnimation = blueprintAnimation
      ..decorationAnimation = decorationAnimation;
  }
}

class _RenderLabelDecoration extends RenderAligningShiftedBox {
  _RenderLabelDecoration({
    required Animation<double> blueprintAnimation,
    required Animation<double> decorationAnimation,
  })  : _blueprintAnimation = blueprintAnimation,
        _decorationAnimation = decorationAnimation,
        super(
          alignment: Alignment.center,
          textDirection: TextDirection.ltr,
        );

  /// Determines the blueprint appearance.
  Animation<double> get blueprintAnimation => _blueprintAnimation;
  Animation<double> _blueprintAnimation;
  set blueprintAnimation(Animation<double> value) {
    if (_blueprintAnimation == value) {
      return;
    }

    final oldAnimation = _blueprintAnimation;
    _blueprintAnimation = value;

    if (attached) {
      oldAnimation.removeListener(markNeedsPaint);
      _blueprintAnimation.addListener(markNeedsPaint);
    }
  }

  /// Determines the decoration appearance.
  Animation<double> get decorationAnimation => _decorationAnimation;
  Animation<double> _decorationAnimation;
  set decorationAnimation(Animation<double> value) {
    if (_decorationAnimation == value) {
      return;
    }

    final oldAnimation = _decorationAnimation;
    _decorationAnimation = value;

    if (attached) {
      oldAnimation.removeListener(markNeedsPaint);
      _decorationAnimation.addListener(markNeedsPaint);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _blueprintAnimation.addListener(markNeedsPaint);
    _decorationAnimation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _blueprintAnimation.removeListener(markNeedsPaint);
    _decorationAnimation.removeListener(markNeedsPaint);
    super.detach();
  }

  BoxConstraints _computeLabelConstraints(BoxConstraints constraints) {
    // Subtracting two _buttonOuterPadding from the width to ensure padding
    // on the sides of the label.
    return constraints.copyWith(
      maxWidth: math.max(constraints.maxWidth - _buttonOuterPadding * 2, 0),
    );
  }

  Size _computeSize({
    required BoxConstraints constraints,
    required Size labelSize,
  }) {
    // Adding two _buttonOuterPadding to the longest side of the label to
    // ensure padding on the sides of the label.
    final longestSide = labelSize.longestSide + _buttonOuterPadding * 2;
    // Creating square with the side equal to the longestSide and constraint it
    // with the given constraints.
    final size = constraints.constrain(Size.square(longestSide));

    // If the result is square then return the size.
    if (size.width == size.height) {
      return size;
    }

    // If the result is rectangle, then return square created from it's shortest
    // side.
    return Size.square(size.shortestSide);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final labelSize = child!.getDryLayout(
      _computeLabelConstraints(constraints),
    );

    return _computeSize(constraints: constraints, labelSize: labelSize);
  }

  @override
  void performLayout() {
    final label = child!;

    label.layout(_computeLabelConstraints(constraints), parentUsesSize: true);
    size = _computeSize(constraints: constraints, labelSize: label.size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(this.child != null, 'child has to be set');
    final child = this.child!;

    alignChild();

    final rect = offset & size;
    final center = rect.center;

    final childParentData = child.parentData! as BoxParentData;
    final childRect = (offset + childParentData.offset) & child.size;

    final canvas = context.canvas;

    // Check if we need to draw blueprint lines.
    if (blueprintAnimation.value > 0) {
      final blueprintLinesScale = lerpDouble(1.5, 1, blueprintAnimation.value)!;

      final blueprintLinesColor = Color.lerp(
        const Color.fromRGBO(255, 255, 255, 0),
        const Color.fromRGBO(255, 255, 255, 0.2),
        blueprintAnimation.value,
      )!;

      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = blueprintLinesColor;

      canvas.save();

      // Scaling the canvas.
      canvas
        ..translate(center.dx, center.dy)
        ..scale(blueprintLinesScale)
        ..translate(-center.dx, -center.dy);

      // Drawing blueprint lines.
      canvas
        ..drawLine(
          Offset(childRect.left, rect.top),
          Offset(childRect.left, rect.bottom),
          strokePaint,
        )
        ..drawLine(
          Offset(childRect.right, rect.top),
          Offset(childRect.right, rect.bottom),
          strokePaint,
        )
        ..drawLine(
          Offset(rect.left, childRect.top),
          Offset(rect.right, childRect.top),
          strokePaint,
        )
        ..drawLine(
          Offset(rect.left, childRect.bottom),
          Offset(rect.right, childRect.bottom),
          strokePaint,
        );

      canvas.restore();
    }

    // Check if we need to draw label decoration.
    if (decorationAnimation.value > 0) {
      final decorationRect = Rect.fromCenter(
        center: childRect.center,
        width: lerpDouble(
          childRect.width + 20,
          childRect.width,
          decorationAnimation.value,
        )!,
        height: lerpDouble(
          childRect.height + 14,
          childRect.height,
          decorationAnimation.value,
        )!,
      );
      final decorationRRect = RRect.fromRectAndRadius(
        decorationRect,
        const Radius.circular(4),
      );

      final decorationFillColor = Color.lerp(
        const Color.fromRGBO(0, 0, 0, 0),
        const Color.fromRGBO(0, 0, 0, 0.1),
        decorationAnimation.value,
      )!;
      final decorationFillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = decorationFillColor;

      // Drawing label background.
      canvas.drawRRect(decorationRRect, decorationFillPaint);

      final decorationBorderColor = Color.lerp(
        const Color.fromRGBO(255, 255, 255, 0),
        const Color.fromRGBO(255, 255, 255, 0.7),
        decorationAnimation.value,
      )!;
      final decorationStrokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = decorationBorderColor;

      // Drawing label outline.
      canvas.drawRRect(decorationRRect, decorationStrokePaint);
    }

    // Drawing label.
    super.paint(context, offset);
  }
}

class _SpinningText extends SingleChildRenderObjectWidget {
  const _SpinningText({
    required this.text,
    required this.style,
    required this.spinningAnimation,
    required this.blueprintAnimation,
  })  : assert(text != '', 'text should not be empty'),
        super(child: const SizedBox.expand());

  /// The spinning text.
  final String text;

  /// The style of the spinning text.
  final TextStyle style;

  /// Determines the spinning progress of the text.
  final Animation<double> spinningAnimation;

  /// Determines the blueprint appearance.
  final Animation<double> blueprintAnimation;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSpinningText(
      text: text,
      style: style,
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: Directionality.of(context),
      blueprintAnimation: blueprintAnimation,
      spinningAnimation: spinningAnimation,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSpinningText renderObject,
  ) {
    renderObject
      ..text = text
      ..style = style
      ..textScaler = MediaQuery.textScalerOf(context)
      ..textDirection = Directionality.of(context)
      ..blueprintAnimation = blueprintAnimation
      ..spinningAnimation = spinningAnimation;
  }
}

class _RenderSpinningText extends RenderProxyBox {
  _RenderSpinningText({
    required String text,
    required TextStyle style,
    required TextScaler textScaler,
    required TextDirection textDirection,
    required Animation<double> blueprintAnimation,
    required Animation<double> spinningAnimation,
  })  : _text = text,
        _style = style,
        _textScaler = textScaler,
        _textDirection = textDirection,
        _blueprintAnimation = blueprintAnimation,
        _spinningAnimation = spinningAnimation;

  /// The text to paint.
  String get text => _text;
  String _text;
  set text(String value) {
    if (_text == value) {
      return;
    }
    _text = value;
    _markNeedsPaintWithClearCache();
  }

  /// The style to use when painting the text.
  TextStyle get style => _style;
  TextStyle _style;
  set style(TextStyle value) {
    if (_style == value) {
      return;
    }
    _style = value;
    _markNeedsPaintWithClearCache();
  }

  /// The font scaling strategy to use when laying out and rendering the text.
  TextScaler get textScaler => _textScaler;
  TextScaler _textScaler;
  set textScaler(TextScaler value) {
    if (_textScaler == value) {
      return;
    }
    _textScaler = value;
    _markNeedsPaintWithClearCache();
  }

  /// The directionality of the text.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    _markNeedsPaintWithClearCache();
  }

  /// Determines the spinning progress of the text.
  Animation<double> get spinningAnimation => _spinningAnimation;
  Animation<double> _spinningAnimation;
  set spinningAnimation(Animation<double> value) {
    if (_spinningAnimation == value) {
      return;
    }

    final oldAnimation = _spinningAnimation;
    _spinningAnimation = value;

    if (attached) {
      oldAnimation.removeListener(markNeedsPaint);
      _spinningAnimation.addListener(markNeedsPaint);
    }
  }

  /// Determines the blueprint appearance.
  Animation<double> get blueprintAnimation => _blueprintAnimation;
  Animation<double> _blueprintAnimation;
  set blueprintAnimation(Animation<double> value) {
    if (_blueprintAnimation == value) {
      return;
    }

    final oldAnimation = _blueprintAnimation;
    _blueprintAnimation = value;

    if (attached) {
      oldAnimation.removeListener(markNeedsPaint);
      _blueprintAnimation.addListener(markNeedsPaint);
    }
  }

  /// Rect for which [_picture] was recorded.
  Rect? _cachedRect;

  /// Text color for which [_picture] was recorded.
  Color? _cachedTextColor;

  /// Recorded picture of the text on path.
  Picture? _picture;

  /// Height of the the character used to draw blueprint circles.
  double _charHeight = 0;

  void _markNeedsPaintWithClearCache() {
    _clearCache();
    markNeedsPaint();
  }

  void _clearCache() {
    _cachedRect = null;
    _cachedTextColor = null;
    _picture?.dispose();
    _picture = null;
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _spinningAnimation.addListener(markNeedsPaint);
    _blueprintAnimation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _spinningAnimation.removeListener(markNeedsPaint);
    _blueprintAnimation.removeListener(markNeedsPaint);
    _clearCache();
    super.detach();
  }

  @override
  void dispose() {
    _clearCache();
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    final rect = offset & size;
    final center = rect.center;

    final textColor = {AnimationStatus.reverse, AnimationStatus.dismissed}
            .contains(_blueprintAnimation.status)
        ? Colors.black
        : Colors.white;

    // Check if we need to construct _picture.
    // This construction may happen in 3 cases:
    // 1) _picture == null || _cachedRect == null || _cachedTextColor == null
    //    (first paint or cache was cleared);
    // 2) _cachedRect != rect (size has changed);
    // 3) _cachedTextColor != textColor (_blueprintAnimation value has changed).
    if (_picture == null ||
        _cachedRect != rect ||
        _cachedTextColor != textColor) {
      _clearCache();

      _cachedRect = rect;
      _cachedTextColor = textColor;

      // Creating a recorder and canvas to record on.
      final recorder = PictureRecorder();
      final recordingCanvas = Canvas(recorder);

      // Creating path with circle to draw on.
      final path = Path()..addOval(rect.deflate(_spinningTextPadding));

      // Drawing text on path.
      _charHeight = recordingCanvas.drawTextOnPath(
        text: _text,
        textStyle: _style.copyWith(color: _cachedTextColor),
        path: path,
        textScaler: _textScaler,
        textDirection: _textDirection,
        isClosed: true,
        autoSpacing: true,
      );

      // Save recorded graphical operations.
      _picture = recorder.endRecording();
    }

    assert(_picture != null, 'On this step picture have to be initialized');

    // Check if we need to draw blueprint circles.
    if (_blueprintAnimation.value > 0) {
      canvas.save();

      final blueprintLinesScale =
          lerpDouble(1.5, 1, _blueprintAnimation.value)!;

      final blueprintLinesColor = Color.lerp(
        const Color.fromRGBO(255, 255, 255, 0),
        const Color.fromRGBO(255, 255, 255, 0.2),
        _blueprintAnimation.value,
      )!;

      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = blueprintLinesColor;

      // Scaling the canvas.
      canvas
        ..translate(center.dx, center.dy)
        ..scale(blueprintLinesScale)
        ..translate(-center.dx, -center.dy);

      // Drawing blueprint circles.
      canvas
        ..drawOval(rect.deflate(_spinningTextPadding), strokePaint)
        ..drawOval(
          rect.deflate(_spinningTextPadding + _charHeight - 3),
          strokePaint,
        );

      canvas.restore();
    }

    // Rotating canvas according to the spinningAnimation value.
    canvas
      ..translate(center.dx, center.dy)
      ..rotate(math.pi * 2 * spinningAnimation.value)
      ..translate(-center.dx, -center.dy);

    // Drawing the recorded picture.
    canvas.drawPicture(_picture!);
  }
}

// Slightly adjusted version of https://github.com/himanshugarg08/draw_on_path
extension on Canvas {
  double drawTextOnPath({
    required String text,
    required Path path,
    required TextStyle textStyle,
    required TextScaler textScaler,
    required TextDirection textDirection,
    double letterSpacing = 0.0,
    bool autoSpacing = false,
    bool isClosed = false,
  }) {
    if (text.isEmpty) {
      return 0;
    }

    var spacing = letterSpacing;

    final pathMetrics = path.computeMetrics();
    final pathMetricsList = pathMetrics.toList();

    if (autoSpacing && text.length > 1) {
      var totalLength = 0.0;

      for (final metric in path.computeMetrics()) {
        totalLength += metric.length;
      }

      final textSpan = TextSpan(text: text, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textScaler: textScaler,
        textDirection: textDirection,
      )..layout();
      final textSize = textPainter.size;
      textPainter.dispose();

      final chars = isClosed ? (text.length) : (text.length - 1);

      spacing = (totalLength - textSize.width) / chars;
    }

    var currentMetric = 0;
    var currentDist = 0.0;

    final charPainter = TextPainter(
      textScaler: textScaler,
      textDirection: textDirection,
    );

    for (var i = 0; i < text.length; i++) {
      charPainter
        ..text = TextSpan(text: text[i], style: textStyle)
        ..layout();
      final charSize = charPainter.size;

      final tangent = pathMetricsList[currentMetric].getTangentForOffset(
        currentDist + charSize.width / 2,
      )!;
      final currentLetterPos = tangent.position;
      final currentLetterAngle = tangent.angle;

      save();
      translate(currentLetterPos.dx, currentLetterPos.dy);
      rotate(-currentLetterAngle);
      charPainter.paint(
        this,
        currentLetterPos
            .translate(-currentLetterPos.dx, -currentLetterPos.dy)
            .translate(-charSize.width * 0.5, 0),
      );
      restore();
      currentDist += charSize.width + spacing;

      if (currentDist > pathMetricsList[currentMetric].length) {
        currentDist = 0;
        currentMetric++;
      }

      if (currentMetric == pathMetricsList.length) {
        break;
      }
    }

    final charHeight = charPainter.size.height;

    charPainter.dispose();

    return charHeight;
  }
}
