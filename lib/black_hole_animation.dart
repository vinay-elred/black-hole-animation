import 'dart:math';

import 'package:flutter/material.dart';

class BlackHoleAnimation extends StatefulWidget {
  const BlackHoleAnimation({super.key});

  @override
  State<BlackHoleAnimation> createState() => _BlackHoleAnimationState();
}

class _BlackHoleAnimationState extends State<BlackHoleAnimation>
    with TickerProviderStateMixin {
  late AnimationController cardController;
  late AnimationController holeController;
  late Animation<double> cardTranslateAnimation;
  late Animation<double> cardRotateAnimation;
  late Animation<double> cardElevationAnimation;

  late Animation<double> holeAnimation;
  final cardSize = 200.0;

  @override
  void initState() {
    super.initState();
    cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    holeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    initAnimation();
  }

  void initAnimation() {
    cardRotateAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: cardController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeInBack),
      ),
    );
    cardElevationAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(
        parent: cardController,
        curve: Curves.easeInOut,
      ),
    );
    cardTranslateAnimation = Tween<double>(begin: 1.2, end: -0.6).animate(
      CurvedAnimation(
        parent: cardController,
        curve: Curves.elasticInOut,
      ),
    );
    holeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: holeController,
        curve: Curves.easeInSine,
        reverseCurve: Curves.easeOutSine,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ClipPath(
          clipper: CardClipper(),
          child: SizedBox(
            height: cardSize * 2,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                transformHole(),
                transformCard(),
              ],
            ),
          ),
        ),
        SizedBox(height: cardSize),
        controlButtons(),
        const SizedBox(height: 50),
      ],
    );
  }

  Row controlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: !cardController.isCompleted
              ? () async {
                  holeController.forward();
                  await cardController.forward();
                  holeController.reverse();
                  setState(() {});
                }
              : null,
          child: const Text('Forward'),
        ),
        ElevatedButton(
          onPressed: cardController.isCompleted
              ? () async {
                  holeController.forward();
                  await cardController.reverse();
                  holeController.reverse();
                  setState(() {});
                }
              : null,
          child: const Text('Reverse'),
        ),
      ],
    );
  }

  Widget transformHole() {
    return AnimatedBuilder(
      animation: holeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: holeAnimation.value,
          child: blackHole(),
        );
      },
    );
  }

  Widget transformCard() {
    return AnimatedBuilder(
      animation: cardController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, cardSize * cardTranslateAnimation.value),
          child: Transform.rotate(
            angle: pi / 8 * cardRotateAnimation.value,
            child: giftCard(cardElevationAnimation.value),
          ),
        );
      },
    );
  }

  Widget blackHole() {
    return ClipOval(
      child: ColoredBox(
        color: Colors.black,
        child: SizedBox(
          height: 100,
          width: cardSize * 1.8,
        ),
      ),
    );
  }

  Widget giftCard(double elevation) {
    return Card(
      elevation: elevation,
      color: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox.square(
        dimension: cardSize,
        child: const Center(
          child: Text(
            "Gift Card",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cardController.dispose();
    holeController.dispose();
    super.dispose();
  }
}

class CardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final height = size.height;
    final width = size.width;
    final path = Path();

    path.lineTo(0, height - 50);
    path.arcToPoint(
      Offset(width, height - 50),
      radius: Radius.elliptical(width / 2, 50),
      clockwise: false,
    );
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
