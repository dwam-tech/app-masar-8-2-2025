import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 5;
  bool _isLoading = false;

  // Animations
  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScale;
  late AnimationController _dotsAnimController;
  late Animation<double> _dotsFade;
  late AnimationController _pageTransitionController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'حجز عقار وديكور',
      'description':
      'استكشف أفضل العقارات والشقق والفلل، واحجز مباشرة من التطبيق مع إمكانية طلب خدمات الديكور والتجهيز حسب ذوقك وميزانيتك.',
      'image': 'assets/images/real_estate.png',
    },
    {
      'title': 'طلب وجبة',
      'description':
      'اطلب أشهى الوجبات من أفضل المطاعم المحلية والدولية مع إمكانية تتبع الطلب حتى باب بيتك وخيارات متعددة للدفع.',
      'image': 'assets/images/food_delivery.png',
    },
    {
      'title': 'طلب توصيلة أو تأجير سيارة',
      'description':
      'اطلب سيارة أجرة أو استأجر سيارة بسهولة لأي مشوار أو مناسبة. أسعار تنافسية وسائقون محترفون وخدمة 24 ساعة.',
      'image': 'assets/images/car_rental.png',
    },
    {
      'title': 'حجز فندق',
      'description':
      'احجز غرفتك الفندقية في أفضل الفنادق وبأقل الأسعار، مع إمكانية مشاهدة تقييمات الزوار وخدمات إضافية أثناء الإقامة.',
      'image': 'assets/images/splashHotel.png',
    },
    {
      'title': 'طلب تصريح أمني',
      'description':
      'سهّل إجراءات الحصول على التصاريح الأمنية اللازمة بسرعة وسهولة من خلال التطبيق، مع متابعة الطلب خطوة بخطوة.',
      'image': 'assets/images/sec.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialAnimations();
  }

  void _initializeAnimations() {
    _buttonAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimController,
      curve: Curves.elasticOut,
    ));

    _dotsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _dotsFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dotsAnimController,
      curve: Curves.easeInOut,
    ));

    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    ));
  }

  void _startInitialAnimations() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buttonAnimController.forward();
      _dotsAnimController.forward();
      _pageTransitionController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonAnimController.dispose();
    _dotsAnimController.dispose();
    _pageTransitionController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    if (_currentPage < _numPages - 1) {
      await Future.wait([
        _buttonAnimController.reverse(),
        _dotsAnimController.reverse(),
        _pageTransitionController.reverse(),
      ]);
      setState(() => _currentPage += 1);
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
      await Future.wait([
        _buttonAnimController.forward(),
        _dotsAnimController.forward(),
        _pageTransitionController.forward(),
      ]);
    } else {
      await _buttonAnimController.reverse();
      if (mounted) {
        context.go('/login');
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: _isLoading
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              onPageChanged: (int page) async {
                if (_isLoading) return;
                setState(() => _isLoading = true);
                await Future.wait([
                  _buttonAnimController.reverse(),
                  _dotsAnimController.reverse(),
                  _pageTransitionController.reverse(),
                ]);
                setState(() => _currentPage = page);
                await Future.wait([
                  _buttonAnimController.forward(),
                  _dotsAnimController.forward(),
                  _pageTransitionController.forward(),
                ]);
                setState(() => _isLoading = false);
              },
              itemCount: _numPages,
              itemBuilder: (context, index) {
                final data = _onboardingData[index];
                return OnboardingPage(
                  screenSize: screenSize,
                  isTablet: isTablet,
                  title: data['title']!,
                  description: data['description']!,
                  imageUrl: data['image']!,
                  currentPage: _currentPage,
                  numPages: _numPages,
                  onNext: _nextPage,
                  buttonAnim: _buttonScale,
                  dotsAnim: _dotsFade,
                  slideAnim: _slideAnimation,
                  fadeAnim: _fadeAnimation,
                  isLast: _currentPage == _numPages - 1,
                  isLoading: _isLoading,
                );
              },
            ),
            _buildSkipButton(context, isTablet, screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton(BuildContext context, bool isTablet, Size screenSize) {
    return Positioned(
      top: screenSize.height * 0.03,
      left: screenSize.width * 0.05,
      child: AnimatedOpacity(
        opacity: _isLoading ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: _isLoading ? null : () => context.go('/login'),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.04,
              vertical: screenSize.height * 0.01,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
              border: Border.all(color: Colors.orange.shade700),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'تخطي',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final Size screenSize;
  final bool isTablet;
  final String title;
  final String description;
  final String imageUrl;
  final int currentPage;
  final int numPages;
  final VoidCallback onNext;
  final Animation<double> buttonAnim;
  final Animation<double> dotsAnim;
  final Animation<Offset> slideAnim;
  final Animation<double> fadeAnim;
  final bool isLast;
  final bool isLoading;

  const OnboardingPage({
    super.key,
    required this.screenSize,
    required this.isTablet,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.currentPage,
    required this.numPages,
    required this.onNext,
    required this.buttonAnim,
    required this.dotsAnim,
    required this.slideAnim,
    required this.fadeAnim,
    required this.isLast,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final width = screenSize.width * (isTablet ? 0.7 : 0.88);
    final imageHeight = screenSize.height * (isTablet ? 0.33 : 0.28);

    return Center(
      child: SlideTransition(
        position: slideAnim,
        child: FadeTransition(
          opacity: fadeAnim,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final verticalSpace = constraints.maxHeight;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Ellipse background
                  Positioned(
                    top: verticalSpace * 0.01,
                    right: -width * 0.07,
                    child: Image.asset(
                      'assets/images/Ellipse.png',
                      width: width * 0.65,
                      height: width * 0.65,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(height: verticalSpace * 0.07),
                      Hero(
                        tag: 'onboarding_image_$currentPage',
                        child: Image.asset(
                          imageUrl,
                          height: imageHeight,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: verticalSpace * 0.02),
                      Container(
                        width: width,
                        margin: EdgeInsets.symmetric(
                          horizontal: isTablet ? 40 : 20,
                        ),
                        padding: EdgeInsets.fromLTRB(
                          isTablet ? 32 : 20,
                          verticalSpace * 0.04,
                          isTablet ? 32 : 20,
                          verticalSpace * 0.09,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.09),
                              blurRadius: isTablet ? 24 : 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: isTablet ? 28 : 24,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0D0700),
                              ),
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: isTablet ? 20 : 15),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                color: const Color(0xFF5D554A),
                                height: 1.5,
                              ),
                              child: Text(
                                description,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: isTablet ? 40 : 30),
                            FadeTransition(
                              opacity: dotsAnim,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  numPages,
                                      (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOutCubic,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 6 : 4,
                                    ),
                                    height: isTablet ? 10 : 7,
                                    width: currentPage == index
                                        ? (isTablet ? 40 : 30)
                                        : (isTablet ? 16 : 12),
                                    decoration: BoxDecoration(
                                      color: currentPage == index
                                          ? Colors.orange
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(
                                        isTablet ? 8 : 5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Next Button (responsive position)
                  Positioned(

                    left: 0,
                    right: 0,
                    bottom: screenSize.height * 0.18,
                    child: Center(
                      child: ScaleTransition(
                        scale: buttonAnim,
                        child: GestureDetector(
                          onTap: isLoading ? null : onNext,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isTablet
                                ? screenSize.width * 0.16
                                : screenSize.width * 0.19,
                            height: isTablet
                                ? screenSize.width * 0.16
                                : screenSize.width * 0.19,
                            decoration: BoxDecoration(
                              color: isLoading
                                  ? Colors.orange.withOpacity(0.6)
                                  : Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: isTablet ? 10 : 7,
                                style: BorderStyle.solid,
                                color: const Color(0xFFF5F5F5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: isLoading
                                ? SizedBox(
                              width: isTablet ? 30 : 24,
                              height: isTablet ? 30 : 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                                : Icon(
                              isLast ? Icons.check : Icons.arrow_forward,
                              color: Colors.white,
                              size: isTablet ? 44 : 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
