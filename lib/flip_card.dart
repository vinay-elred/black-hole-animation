import 'dart:math';

import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  const FlipCard({super.key});

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController flipController;
  late Animation<double> flipAnimation;
  double anglePlus = 0;
  bool isFront = true;

  @override
  void initState() {
    super.initState();
    flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: flipController, curve: Curves.ease),
    );
  }

  bool isFrontCard(double angle) {
    const d90 = pi / 2;
    const d270 = 3 * pi / 2;
    return (angle <= d90 || angle >= d270);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AnimatedBuilder(
          animation: flipAnimation,
          builder: (context, child) {
            double angle = pi * flipAnimation.value;
            if (isFront) angle += anglePlus;
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              alignment: Alignment.center,
              child:
                  isFrontCard(angle) ? card(Colors.yellow) : card(Colors.blue),
            );
          },
        ),
        SizedBox(
          width: 200,
          child: ElevatedButton(
            onPressed: () async {
              if (flipController.isAnimating) return;
              isFront = !isFront;
              await flipController.forward(from: 0);
              anglePlus = pi;
            },
            child: const Text("Flip"),
          ),
        ),
      ],
    );
  }

  Card card(Color color) {
    return Card(
      color: color,
      child: const SizedBox(
        height: 200,
        width: 350,
      ),
    );
  }

  @override
  void dispose() {
    flipController.dispose();
    super.dispose();
  }
}
