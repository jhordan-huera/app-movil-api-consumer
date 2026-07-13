import 'package:flutter/material.dart';
import 'dart:math';

class ThreeDotsLoader extends StatefulWidget {
  final Color? color;
  const ThreeDotsLoader({super.key, this.color});

  @override
  State<ThreeDotsLoader> createState() => _ThreeDotsLoaderState();
}

class _ThreeDotsLoaderState extends State<ThreeDotsLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loaderColor = widget.color ?? Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Desfase para crear una ola
            final t = (_controller.value * 2 * pi) - (index * 1.5);
            // Calculamos desplazamiento vertical usando seno
            final offset = sin(t) * 5; 
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Transform.translate(
                offset: Offset(0, offset),
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: loaderColor,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
