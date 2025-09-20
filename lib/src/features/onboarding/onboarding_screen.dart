import 'package:flutter/material.dart';
import '../auth/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_Slide> _slides = const [
    _Slide(
      title: 'Track your sugar levels effortlessly.',
      image: 'lib/assets/images/doctor1.png',
    ),
    _Slide(
      title: 'Your partner in the diabetic journey.',
      image: 'lib/assets/images/doctor2.png',
    ),
    _Slide(
      title: 'Stay connected with care and community.',
      image: 'lib/assets/images/doctor3.png',
    ),
  ];

  void _next() {
    if (_index < _slides.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Navigator.of(context).pushReplacementNamed(WelcomeScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed(WelcomeScreen.routeName),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _OnboardingSlide(slide: _slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(_slides.length, (i) {
                      final bool active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        height: 6,
                        width: active ? 18 : 6,
                        decoration: BoxDecoration(
                          color: active ? Theme.of(context).colorScheme.primary : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      );
                    }),
                  ),
                  FloatingActionButton.small(
                    onPressed: _next,
                    child: const Icon(Icons.arrow_forward),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final _Slide slide;
  const _OnboardingSlide({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset(
              slide.image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.image_not_supported_outlined, size: 96, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Image not found')
                  ],
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8)),
              ],
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(slide.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            ),
          ),
        )
      ],
    );
  }
}

class _Slide {
  final String title;
  final String image;
  const _Slide({required this.title, required this.image});
}


