import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class DoubtPage extends StatelessWidget {
  const DoubtPage({super.key});

  static const String expression = r'\frac{11 + x}{x^{3}} + 2x(5 - x)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doubt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Question',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                // Render the LaTeX
                Math.tex(
                  expression,
                  mathStyle: MathStyle.display,
                  textStyle: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'LaTeX',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  expression,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
