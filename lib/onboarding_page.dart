import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';

/// Warna sesuai style guide
const kPrimary500 = Color(0xFF1778FB);
const kGreen200  = Color(0xFF8EE7C4);

/// Font options
enum AppFont { inter, openSans }

class OnboardingPage extends StatefulWidget {
  static const routeName = '/onboarding';

  /// Pilih font untuk seluruh teks di halaman ini
  final AppFont font;

  const OnboardingPage({
    Key? key,
    this.font = AppFont.inter, // default Inter
  }) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnbBackground extends StatelessWidget {
  final List<Color> gradientColors;
  final String imagePath;
  final double imageWidth;
  final double bottomPadding; // jarak dari bawah layar (hindari panel putih)

  const _OnbBackground({
    Key? key,
    required this.gradientColors,
    required this.imagePath,
    required this.bottomPadding,
    this.imageWidth = 240,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Image.asset(
                  imagePath,
                  width: imageWidth,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _bgController = PageController();
  int _index = 0;

  void _next() {
    if (_index < 2) {
      _bgController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final whitePanelHeight = size.height * 0.42;

    const gapFromWhite = 12.0;
    final artBottomPadding = whitePanelHeight + gapFromWhite;

    return Scaffold(
      body: Stack(
        children: [
          // === Latar + ilustrasi per halaman (sinkron dengan PageView)
          Positioned.fill(
            child: PageView(
              controller: _bgController,
              onPageChanged: (i) => setState(() => _index = i),
              children: [
                _OnbBackground(
                  gradientColors: const [kGreen200, kPrimary500, kGreen200],
                  imagePath: 'assets/onboarding1.png',
                  bottomPadding: artBottomPadding,
                  imageWidth: 230,
                ),
                _OnbBackground(
                  gradientColors: const [kGreen200, kPrimary500, kGreen200],
                  imagePath: 'assets/onboarding2.png',
                  bottomPadding: artBottomPadding,
                  imageWidth: 230,
                ),
                _OnbBackground(
                  gradientColors: const [kGreen200, kPrimary500, kGreen200],
                  imagePath: 'assets/onboarding3.png',
                  bottomPadding: artBottomPadding,
                  imageWidth: 230,
                ),
              ],
            ),
          ),

          // === Tombol Skip (regular 14)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, LoginPage.routeName),
                  child: Text(
                    'Skip',
                    style: _body14Regular(widget.font).copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          // === Panel putih melengkung (konten)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: whitePanelHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  children: [
                    // Indikator halaman
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _index == i ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _index == i ? kPrimary500 : Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Judul + Deskripsi
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _OnbCopy(
                          key: ValueKey(_index),
                          font: widget.font,
                          title: const [
                            'Manage Daily Tasks Effortlessly',
                            'Turn Small Actions into Daily Habits',
                            'See Your Progress Every Day',
                          ][_index],
                          subtitle: const [
                            'Write down everything in one app. Check off tasks with one tap.',
                            'Track your routines and stay consistent every day.',
                            'Stay motivated with clear insights into your tasks and habits.',
                          ][_index],
                        ),
                      ),
                    ),

                    // Tombol lanjut (regular 14)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary500,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _next,
                        child: Text(
                          _index == 2 ? "Let's Get Started" : 'Continue',
                          style: _body14Regular(widget.font),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- Text widgets with switchable fonts ----------

class _OnbCopy extends StatelessWidget {
  final String title;
  final String subtitle;
  final AppFont font;

  const _OnbCopy({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.font,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title: bold 28
        Text(
          title,
          textAlign: TextAlign.center,
          style: _titleBold28(font),
        ),
        const SizedBox(height: 8),
        // Subtitle: regular 14
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: _body14Regular(font).copyWith(color: Colors.black54, height: 1.4),
        ),
      ],
    );
  }
}

/// === Helpers gaya teks ===
TextStyle _titleBold28(AppFont f) {
  switch (f) {
    case AppFont.inter:
      return GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700);
    case AppFont.openSans:
      return GoogleFonts.openSans(fontSize: 28, fontWeight: FontWeight.w700);
  }
}

TextStyle _body14Regular(AppFont f) {
  switch (f) {
    case AppFont.inter:
      return GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400);
    case AppFont.openSans:
      return GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w400);
  }
}
