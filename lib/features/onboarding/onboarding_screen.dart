import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/screens/login_screen.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _slides = const [
    _Slide(
      icon: Icons.auto_awesome,
      gradient: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
      title: 'AI Financial Twin',
      subtitle: 'Your personal AI analyzes your spending patterns and predicts your financial future.',
    ),
    _Slide(
      icon: Icons.track_changes_rounded,
      gradient: [Color(0xFFE84393), Color(0xFFA29BFE)],
      title: 'Smart Goal Planning',
      subtitle: 'Set financial goals and let AI guide you with personalized recommendations.',
    ),
    _Slide(
      icon: Icons.shield_rounded,
      gradient: [Color(0xFF00B894), Color(0xFF00CEC9)],
      title: 'Fraud Detection',
      subtitle: 'Advanced AI monitors transactions 24/7 to protect you from scams and fraud.',
    ),
    _Slide(
      icon: Icons.trending_up_rounded,
      gradient: [Color(0xFFE17055), Color(0xFFFDAA47)],
      title: 'Financial Health Score',
      subtitle: 'Track your financial wellness with real-time insights and improvement tips.',
    ),
  ];

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_page + 1) / _slides.length,
                        backgroundColor: Colors.grey.withAlpha(50),
                        color: AppColors.primary,
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Skip', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlideWidget(slide: _slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: i == _page ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _page ? AppColors.primary : Colors.grey.withAlpha(80),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_page == _slides.length - 1 ? 'Get Started' : 'Next'),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  const _Slide({required this.icon, required this.gradient, required this.title, required this.subtitle});
}

class _SlideWidget extends StatelessWidget {
  final _Slide slide;
  const _SlideWidget({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: slide.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: slide.gradient.first.withAlpha(80),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(slide.icon, color: Colors.white, size: 52),
          ),
          const SizedBox(height: 48),
          Text(
            slide.title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            slide.subtitle,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
