import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import '../main.dart'; // assuming navigatorKey is defined here

class MarkdownWithCopy extends StatelessWidget {
  final String data;

  const MarkdownWithCopy({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        code: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Colors.white,
          backgroundColor: Color(0xFF2D2D2D),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        a: const TextStyle( // 👈 paste this inside styleSheet
          color: Colors.blueAccent,
          decoration: TextDecoration.underline,
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      builders: {
        'code': CodeBlockBuilder(),
      },
        onTapLink: (text, href, title) async {
          if (href != null) {
            final uri = Uri.tryParse(href);
            if (uri != null) {
              await launchUrl(uri, mode: LaunchMode
                  .externalApplication); // ✅ this opens link externally
            }
          }
        }
    );
  }
}


class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final codeText = element.children
        ?.map((child) => child is md.Text ? child.text : '')
        .join()
        .trim() ?? '';
    final lineCount = '\n'.allMatches(codeText).length + 1;
    final showCopyButton = lineCount > 3;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 12,
              right: 32,
              left: 12,
              bottom: 12,
            ),
            child: SelectableText(
              codeText,
              style: const TextStyle(
                fontFamily: 'Courier',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          if (showCopyButton)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.paste_outlined, size: 16, color: Colors.white),
                tooltip: 'Copy code',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: codeText))
                    .then((_) {
                    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                       const SnackBar(
                         content: Text('✅ Code copied!'),
                         duration: Duration(seconds: 2),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
