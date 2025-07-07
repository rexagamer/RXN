import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'package:flutter/animation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countdown',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue[900]!,
          secondary: Colors.blue[800]!,
          surface: Colors.blue[700]!,
        ),
        useMaterial3: true,
      ),
      home: const BirthdayCountdown(),
    );
  }
}

class BirthdayCountdown extends StatefulWidget {
  const BirthdayCountdown({super.key});

  @override
  State<BirthdayCountdown> createState() => _BirthdayCountdownState();
}

class _BirthdayCountdownState extends State<BirthdayCountdown> {
  final DateTime birthday = DateTime(2025, 8, 14);
  late ConfettiController _confettiController;
  bool isBirthday = false;
  late Timer _timer;
  Duration timeUntilBirthday = Duration.zero;
  final Color primary = Colors.lightGreen[900]!;
  final Color secondary = Colors.lightGreen[800]!;
  final Color surface = Colors.lightGreen[700]!;

  // Easter egg states
  bool showR = false;
  bool showX = false;
  bool showN = false;
  double rPosition = 0;
  double xPosition = 0;
  double nPosition = 0;
  double rDirection = 1;
  double xDirection = 1;
  double nDirection = 1;
  bool showScaryPage = true;
  bool showScaryText = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));

    // Show scary text after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => showScaryText = true);
    });

    // Hide scary page and start countdown after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => showScaryPage = false);
        _checkBirthday();
        _startTimer();
      }
    });

    // Easter egg animation timer (keep existing)
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (showR || showX || showN) {
        setState(() {
          if (showR) {
            rPosition += 2 * rDirection;
            if (rPosition > 300 || rPosition < 0) rDirection *= -1;
          }
          if (showX) {
            xPosition += 3 * xDirection;
            if (xPosition > 300 || xPosition < 0) xDirection *= -1;
          }
          if (showN) {
            nPosition += 4 * nDirection;
            if (nPosition > 300 || nPosition < 0) nDirection *= -1;
          }
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkBirthday();
      if (!isBirthday) {
        setState(() {
          timeUntilBirthday = _calculateTimeUntilBirthday();
        });
      }
    });
  }

  void _checkBirthday() {
    final now = DateTime.now();
    isBirthday = now.month == birthday.month && now.day == birthday.day;
    if (isBirthday) {
      _confettiController.play();
    }
  }

  Duration _calculateTimeUntilBirthday() {
    final now = DateTime.now();
    var nextBirthday = DateTime(now.year, birthday.month, birthday.day);
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }
    return nextBirthday.difference(now);
  }

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _toggleEasterEgg(String egg) {
    setState(() {
      switch (egg) {
        case 'R':
          showR = !showR;
          if (showR) rPosition = 0;
          break;
        case 'X':
          showX = !showX;
          if (showX) xPosition = 0;
          break;
        case 'N':
          showN = !showN;
          if (showN) nPosition = 0;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showScaryPage) {
      return _buildScaryPage();
    }
    if (isBirthday) {
      return _buildBirthdayCelebration();
    }

    final days = timeUntilBirthday.inDays;
    final hours = timeUntilBirthday.inHours.remainder(24);
    final minutes = timeUntilBirthday.inMinutes.remainder(60);
    final seconds = timeUntilBirthday.inSeconds.remainder(60);
    final totalHours = timeUntilBirthday.inHours;
    final totalMinutes = timeUntilBirthday.inMinutes;
    final totalSeconds = timeUntilBirthday.inSeconds;
    final weeks = days ~/ 7;

    return Scaffold(
      backgroundColor: primary,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main countdown
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        const Text(
                          'DAYS   HRS   MINS   SECS',
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 5.0,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${days.toString().padLeft(2, '0')} : ${hours.toString().padLeft(2, '0')} : ${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'RobotoMono',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Detailed breakdown
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: secondary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleEasterEgg('R'),
                          child: _buildTimeDetail('Weeks:', weeks.toString()),
                        ),
                        GestureDetector(
                          onTap: () => _toggleEasterEgg('X'),
                          child:
                              _buildTimeDetail('Hours:', totalHours.toString()),
                        ),
                        GestureDetector(
                          onTap: () => _toggleEasterEgg('N'),
                          child: _buildTimeDetail(
                              'Seconds:', totalSeconds.toString()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Easter egg letters
          if (showR)
            Positioned(
              left: rPosition,
              top: 100,
              child: const Text(
                'R',
                style: TextStyle(
                  fontSize: 100,
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (showX)
            Positioned(
              right: xPosition,
              top: 200,
              child: const Text(
                'X',
                style: TextStyle(
                  fontSize: 100,
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (showN)
            Positioned(
              left: nPosition,
              bottom: 100,
              child: const Text(
                'N',
                style: TextStyle(
                  fontSize: 100,
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayCelebration() {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, secondary],
              ),
            ),
          ),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'HAPPY BIRTHDAY',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'TODAY IS THE DAY',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaryPage() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedOpacity(
          opacity: showScaryText ? 1.0 : 0.0,
          duration: const Duration(seconds: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Something is coming...',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.red[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Icon(
                Icons.warning,
                color: Colors.red[800],
                size: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
