import 'package:flutter/gestures.dart';
import '../../../core/constants/exports.dart';
import 'package:url_launcher/url_launcher.dart';

class AppMessageText extends StatefulWidget {
  final String content;
  final TextStyle? textStyle;
  final TextStyle? emojiStyle;
  final TextStyle? linkStyle;
  final int trimLength;
  final String? moreText;
  final String? lessText;
  final bool isMe;

  const AppMessageText(
    this.content, {
    super.key,
    this.textStyle,
    this.emojiStyle,
    this.linkStyle,
    this.trimLength = 150,
    this.moreText,
    this.lessText,
    this.isMe = false,
  });

  @override
  State<AppMessageText> createState() => _AppMessageTextState();
}

class _AppMessageTextState extends State<AppMessageText> {
  bool _isExpanded = false;

  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final normalStyle = widget.textStyle ?? const TextStyle(fontSize: 16);
    final emojiStyle =
        widget.emojiStyle ??
        const TextStyle(fontSize: 16, fontFamily: AppConstants.emojiFont);
    final linkStyle =
        widget.linkStyle ??
        TextStyle(
          color: widget.isMe ? Colors.cyanAccent : Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );

    final spans = _buildStyledSpans(
      widget.content,
      normalStyle,
      emojiStyle,
      linkStyle,
    );

    final needsTrimming = _textLength(spans) > widget.trimLength;
    final visibleSpans = needsTrimming && !_isExpanded
        ? _truncateWithEllipsis(spans, widget.trimLength, normalStyle)
        : List<TextSpan>.from(spans);

    if (needsTrimming) {
      final toggleRecognizer = TapGestureRecognizer()
        ..onTap = () => setState(() => _isExpanded = !_isExpanded);
      _recognizers.add(toggleRecognizer);

      visibleSpans.add(
        TextSpan(
          text: _isExpanded
              ? '  ${widget.lessText}'
              : ' ... ${widget.moreText}',
          style: linkStyle.copyWith(
            decoration: TextDecoration.none,
            color: Colors.cyan,
          ),
          recognizer: toggleRecognizer,
        ),
      );
    }

    return Text.rich(
      TextSpan(children: visibleSpans),
      textDirection: isArabic(widget.content)
          ? TextDirection.rtl
          : TextDirection.ltr,
    );
  }

  List<TextSpan> _buildStyledSpans(
    String text,
    TextStyle normalStyle,
    TextStyle emojiStyle,
    TextStyle linkStyle,
  ) {
    final spans = <TextSpan>[];
    final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
    final matches = urlRegex.allMatches(text);
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        final before = text.substring(currentIndex, match.start);
        spans.addAll(_splitEmojiAware(before, normalStyle, emojiStyle));
      }

      final url = match.group(0);
      if (url != null) {
        final linkRecognizer = TapGestureRecognizer()
          ..onTap = () async {
            final uri = Uri.tryParse(url);
            if (uri == null) return;
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (e) {
              debugPrint('Could not launch $url: $e');
            }
          };
        _recognizers.add(linkRecognizer);

        spans.add(
          TextSpan(text: url, style: linkStyle, recognizer: linkRecognizer),
        );
      }

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      final tail = text.substring(currentIndex);
      spans.addAll(_splitEmojiAware(tail, normalStyle, emojiStyle));
    }

    return spans;
  }

  List<TextSpan> _splitEmojiAware(
    String text,
    TextStyle normal,
    TextStyle emoji,
  ) {
    final spans = <TextSpan>[];
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]',
      unicode: true,
    );

    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      spans.add(
        TextSpan(text: char, style: emojiRegex.hasMatch(char) ? emoji : normal),
      );
    }

    return spans;
  }

  int _textLength(List<TextSpan> spans) {
    return spans.fold(0, (sum, s) => sum + (s.text?.length ?? 0));
  }

  List<TextSpan> _truncateWithEllipsis(
    List<TextSpan> spans,
    int maxLength,
    TextStyle fallbackStyle,
  ) {
    final result = <TextSpan>[];
    int current = 0;

    for (final span in spans) {
      final text = span.text ?? '';
      final remaining = maxLength - current;

      if (remaining <= 0) break;

      if (text.length <= remaining) {
        result.add(span);
        current += text.length;
      } else {
        result.add(
          TextSpan(
            text: text.substring(0, remaining),
            style: span.style ?? fallbackStyle,
          ),
        );
        result.add(
          TextSpan(
            text: '...',
            style: fallbackStyle.copyWith(fontWeight: FontWeight.w400),
          ),
        );
        break;
      }
    }

    return result;
  }

  bool isArabic(String text) {
    final arabicRegex = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    );
    return arabicRegex.hasMatch(text);
  }
}
