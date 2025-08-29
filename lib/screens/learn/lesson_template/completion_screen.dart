import 'package:flutter/material.dart';
import '../../../core/utils/translation_utils.dart';

enum CompletionType {
  perfect,     // 완벽해요
  great,       // 잘했어요
  encourage,   // 괜찮아요/수고했어요
  enough,      // 이미 충분해요
}

class CompletionScreen extends StatefulWidget {
  final CompletionType type;
  final VoidCallback onContinue;
  final String? customMessage;

  const CompletionScreen({
    super.key,
    required this.type,
    required this.onContinue,
    this.customMessage,
  });

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _particleController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _fadeController.forward();
    
    if (widget.type == CompletionType.perfect || widget.type == CompletionType.great) {
      _particleController.repeat();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 애니메이션 아이콘
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildAnimatedIcon(),
                ),
                
                const SizedBox(height: 40),
                
                // 메인 텍스트
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    _getMainText(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: _getTextColor(),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 서브 텍스트
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    widget.customMessage ?? _getSubText(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // 계속하기 버튼
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ElevatedButton(
                    onPressed: widget.onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getButtonColor(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                      minimumSize: const Size(200, 52),
                    ),
                    child: Text(
                      tr('continue'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 파티클 효과 (성공 타입일 때만)
        if (widget.type == CompletionType.perfect || widget.type == CompletionType.great)
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(120, 120),
                painter: ParticlePainter(_particleAnimation.value),
              );
            },
          ),
        
        // 메인 아이콘
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: _getIconBackgroundColor(),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getIconBackgroundColor().withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            _getIcon(),
            size: 60,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor() {
    // 모든 타입에서 동일한 배경색 사용
    return const Color(0xFFF8F9FA);
  }

  Color _getIconBackgroundColor() {
    switch (widget.type) {
      case CompletionType.perfect:
        return const Color(0xFFFFB300); // 황금색
      case CompletionType.great:
        return const Color(0xFF4CAF50); // 초록색
      case CompletionType.encourage:
        return const Color(0xFF2196F3); // 파란색
      case CompletionType.enough:
        return const Color(0xFF9C27B0); // 보라색
    }
  }

  Color _getTextColor() {
    // 모든 타입에서 동일한 텍스트 색상 사용
    return const Color(0xFF2C3E50);
  }

  Color _getButtonColor() {
    return _getIconBackgroundColor();
  }

  IconData _getIcon() {
    switch (widget.type) {
      case CompletionType.perfect:
        return Icons.star;
      case CompletionType.great:
        return Icons.check_circle;
      case CompletionType.encourage:
        return Icons.favorite;
      case CompletionType.enough:
        return Icons.self_improvement;
    }
  }

  String _getMainText() {
    switch (widget.type) {
      case CompletionType.perfect:
        return tr('completion_perfect');
      case CompletionType.great:
        return tr('completion_great');
      case CompletionType.encourage:
        return tr('completion_encourage');
      case CompletionType.enough:
        return tr('completion_enough');
    }
  }

  String _getSubText() {
    switch (widget.type) {
      case CompletionType.perfect:
        return tr('completion_perfect_sub');
      case CompletionType.great:
        return tr('completion_great_sub');
      case CompletionType.encourage:
        return tr('completion_encourage_sub');
      case CompletionType.enough:
        return tr('completion_enough_sub');
    }
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;
  
  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 8개의 파티클을 원형으로 배치
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180) + (animationValue * 2 * 3.14159);
      final particleRadius = radius * 0.8 * animationValue;
      
      final x = center.dx + particleRadius * (animationValue * 0.5 + 0.5) * 
          (1 + 0.3 * (animationValue * 2 - 1).abs()) * 
          (animationValue < 0.5 ? animationValue * 2 : 2 - animationValue * 2);
      final y = center.dy + particleRadius * (animationValue * 0.5 + 0.5) * 
          (1 + 0.3 * (animationValue * 2 - 1).abs()) * 
          (animationValue < 0.5 ? animationValue * 2 : 2 - animationValue * 2);

      final particleX = center.dx + (x - center.dx) * (animationValue < 0.5 ? animationValue * 2 : 1.0);
      final particleY = center.dy + (y - center.dy) * (animationValue < 0.5 ? animationValue * 2 : 1.0);

      canvas.drawCircle(
        Offset(particleX, particleY),
        3 * (1 - animationValue * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}