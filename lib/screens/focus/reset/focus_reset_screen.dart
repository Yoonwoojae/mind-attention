import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_attention/core/utils/translation_utils.dart';
import 'package:mind_attention/core/utils/logger.dart';
import 'package:audioplayers/audioplayers.dart';

class FocusResetScreen extends StatefulWidget {
  final String? mode;

  const FocusResetScreen({super.key, this.mode});

  @override
  State<FocusResetScreen> createState() => _FocusResetScreenState();
}

class _FocusResetScreenState extends State<FocusResetScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _pulseController;
  Timer? _timer;
  int _currentPhase = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  String _currentMode = 'sos';
  int _preFocusLevel = 3;
  int _postFocusLevel = 3;
  int _preTensionLevel = 3;
  int _postTensionLevel = 3;
  bool _showFeedback = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Map<String, List<ResetPhase>> _modes = {
    'sos': [
      ResetPhase(name: 'reset_breathe', duration: 20, icon: Icons.air),
      ResetPhase(name: 'reset_stretch', duration: 20, icon: Icons.accessibility_new),
      ResetPhase(name: 'reset_choose', duration: 20, icon: Icons.check_circle),
    ],
    '1min': [
      ResetPhase(name: 'reset_quick_breathe', duration: 60, icon: Icons.air),
    ],
    '3min': [
      ResetPhase(name: 'reset_body_scan', duration: 180, icon: Icons.self_improvement),
    ],
    '5min': [
      ResetPhase(name: 'reset_mindful', duration: 300, icon: Icons.spa),
    ],
    '10min': [
      ResetPhase(name: 'reset_deep_reset', duration: 600, icon: Icons.psychology),
    ],
  };

  String? _selectedNoise;
  bool _isNoiseLooping = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode != null) {
      _currentMode = widget.mode!;
    }

    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startReset() {
    setState(() {
      _isRunning = true;
      _currentPhase = 0;
      _remainingSeconds = _modes[_currentMode]![0].duration;
    });

    HapticFeedback.mediumImpact();
    _breathController.repeat(reverse: true);
    
    // 시작 알림 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tr('reset_${_currentMode}_title')} ${tr('reset_started')}'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _nextPhase();
        }
      });
    });

    AppLogger.i('Started reset mode: $_currentMode');
  }

  void _nextPhase() {
    final phases = _modes[_currentMode]!;
    
    if (_currentPhase < phases.length - 1) {
      setState(() {
        _currentPhase++;
        _remainingSeconds = phases[_currentPhase].duration;
      });
      HapticFeedback.lightImpact();
      _showPhaseNotification();
    } else {
      _completeReset();
    }
  }

  void _completeReset() {
    _timer?.cancel();
    _breathController.stop();
    
    setState(() {
      _isRunning = false;
      _showFeedback = true;
    });

    HapticFeedback.heavyImpact();
    _playCompletionSound();
  }

  void _showPhaseNotification() {
    final phase = _modes[_currentMode]![_currentPhase];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr(phase.name)),
        backgroundColor: const Color(0xFFFF9800),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _playCompletionSound() async {
    // 시각적 피드백으로 대체
    HapticFeedback.heavyImpact();
    
    // TODO: Add meditation bell sound file
    // 실제 사운드 파일이 추가되면 아래 주석을 해제하세요
    // try {
    //   await _audioPlayer.play(AssetSource('sounds/meditation_bell.mp3'));
    // } catch (e) {
    //   AppLogger.e('Failed to play sound: $e');
    // }
  }

  void _toggleNoise(String noiseType) async {
    HapticFeedback.mediumImpact();
    
    if (_selectedNoise == noiseType && _isNoiseLooping) {
      await _audioPlayer.stop();
      setState(() {
        _selectedNoise = null;
        _isNoiseLooping = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tr('reset_noise_$noiseType')} ${tr('reset_noise_stopped')}'),
          backgroundColor: Colors.grey,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      setState(() {
        _selectedNoise = noiseType;
        _isNoiseLooping = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tr('reset_noise_$noiseType')} ${tr('reset_noise_playing')}'),
          backgroundColor: const Color(0xFFFF9800),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
      // TODO: Add noise sound files (white.mp3, pink.mp3, brown.mp3)
      // 실제 사운드 파일이 추가되면 아래 주석을 해제하세요
      // try {
      //   await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      //   await _audioPlayer.play(AssetSource('sounds/$noiseType.mp3'));
      // } catch (e) {
      //   AppLogger.e('Failed to play noise: $e');
      // }
    }
  }

  void _saveFeedback() {
    AppLogger.i('Focus feedback - Pre: $_preFocusLevel, Post: $_postFocusLevel');
    AppLogger.i('Tension feedback - Pre: $_preTensionLevel, Post: $_postTensionLevel');
    
    setState(() {
      _showFeedback = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('reset_feedback_saved')),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            if (_isRunning) {
              _timer?.cancel();
              _breathController.stop();
            }
            if (_isNoiseLooping) {
              _audioPlayer.stop();
            }
            context.pop();
          },
        ),
        title: Text(
          tr('focus_reset'),
          style: const TextStyle(color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: _showFeedback
            ? _buildFeedbackView()
            : _isRunning
                ? _buildActiveResetView()
                : _buildModeSelectionView(),
      ),
    );
  }

  Widget _buildModeSelectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('reset_choose_mode'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr('reset_mode_hint'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          _buildModeCard(
            'sos',
            tr('reset_sos_title'),
            tr('reset_sos_desc'),
            const Color(0xFFFF5252),
            Icons.flash_on,
            true,
          ),
          _buildModeCard(
            '1min',
            tr('reset_1min_title'),
            tr('reset_1min_desc'),
            const Color(0xFF4CAF50),
            Icons.timer,
            false,
          ),
          _buildModeCard(
            '3min',
            tr('reset_3min_title'),
            tr('reset_3min_desc'),
            const Color(0xFF2196F3),
            Icons.self_improvement,
            false,
          ),
          _buildModeCard(
            '5min',
            tr('reset_5min_title'),
            tr('reset_5min_desc'),
            const Color(0xFF9C27B0),
            Icons.spa,
            false,
          ),
          _buildModeCard(
            '10min',
            tr('reset_10min_title'),
            tr('reset_10min_desc'),
            const Color(0xFF00BCD4),
            Icons.psychology,
            false,
          ),
          const SizedBox(height: 32),
          _buildNoiseSection(),
          const SizedBox(height: 40),
          _buildStartButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        onPressed: _currentMode.isNotEmpty ? _startReset : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 28),
            const SizedBox(width: 12),
            Text(
              '${tr('reset_${_currentMode}_title')} ${tr('reset_start_now')}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    String mode,
    String title,
    String description,
    Color color,
    IconData icon,
    bool isRecommended,
  ) {
    final isSelected = _currentMode == mode;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _currentMode = mode;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tr('reset_recommended'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoiseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('reset_background_noise'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNoiseButton('white', tr('reset_noise_white'), Colors.grey),
            _buildNoiseButton('pink', tr('reset_noise_pink'), Colors.pink),
            _buildNoiseButton('brown', tr('reset_noise_brown'), Colors.brown),
          ],
        ),
      ],
    );
  }

  Widget _buildNoiseButton(String type, String label, Color color) {
    final isActive = _selectedNoise == type && _isNoiseLooping;

    return GestureDetector(
      onTap: () => _toggleNoise(type),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isActive ? Icons.volume_up : Icons.volume_off,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? color : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveResetView() {
    final phases = _modes[_currentMode]!;
    final currentPhaseData = phases[_currentPhase];
    final progress = 1 - (_remainingSeconds / currentPhaseData.duration);

    return Column(
      children: [
        const SizedBox(height: 40),
        _buildPhaseIndicator(),
        const SizedBox(height: 40),
        _buildAnimatedIcon(currentPhaseData.icon),
        const SizedBox(height: 40),
        Text(
          tr(currentPhaseData.name),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _formatTime(_remainingSeconds),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF9800),
          ),
        ),
        const SizedBox(height: 40),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildInstructions(currentPhaseData.name),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(40),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              _timer?.cancel();
              _breathController.stop();
              setState(() {
                _isRunning = false;
              });
            },
            child: Text(
              tr('reset_stop'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseIndicator() {
    final phases = _modes[_currentMode]!;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(phases.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Container(
              width: 30,
              height: 2,
              color: index ~/ 2 < _currentPhase
                  ? const Color(0xFFFF9800)
                  : Colors.grey.shade300,
            );
          } else {
            final phaseIndex = index ~/ 2;
            final isActive = phaseIndex == _currentPhase;
            final isCompleted = phaseIndex < _currentPhase;

            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFFF9800)
                    : isActive
                        ? const Color(0xFFFF9800).withOpacity(0.3)
                        : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  phases[phaseIndex].icon,
                  size: 20,
                  color: isCompleted || isActive
                      ? Colors.white
                      : Colors.grey[600],
                ),
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon) {
    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_breathController.value * 0.3),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: const Color(0xFFFF9800),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructions(String phaseName) {
    String instruction = '';
    
    switch (phaseName) {
      case 'reset_breathe':
        instruction = tr('reset_breathe_instruction');
        break;
      case 'reset_stretch':
        instruction = tr('reset_stretch_instruction');
        break;
      case 'reset_choose':
        instruction = tr('reset_choose_instruction');
        break;
      case 'reset_quick_breathe':
        instruction = tr('reset_quick_breathe_instruction');
        break;
      case 'reset_body_scan':
        instruction = tr('reset_body_scan_instruction');
        break;
      case 'reset_mindful':
        instruction = tr('reset_mindful_instruction');
        break;
      case 'reset_deep_reset':
        instruction = tr('reset_deep_reset_instruction');
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        instruction,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFeedbackView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 64,
            color: Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16),
          Text(
            tr('reset_completed'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr('reset_how_feeling'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          _buildFeedbackSlider(
            tr('reset_focus_level'),
            _preFocusLevel,
            _postFocusLevel,
            (pre, post) {
              setState(() {
                _preFocusLevel = pre;
                _postFocusLevel = post;
              });
            },
            const Color(0xFF2196F3),
          ),
          const SizedBox(height: 24),
          _buildFeedbackSlider(
            tr('reset_tension_level'),
            _preTensionLevel,
            _postTensionLevel,
            (pre, post) {
              setState(() {
                _preTensionLevel = pre;
                _postTensionLevel = post;
              });
            },
            const Color(0xFFFF5252),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _showFeedback = false;
                    });
                  },
                  child: Text(tr('reset_skip_feedback')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _saveFeedback,
                  child: Text(tr('reset_save_feedback')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSlider(
    String label,
    int preValue,
    int postValue,
    Function(int, int) onChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    tr('reset_before'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: color.withOpacity(0.5),
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: color.withOpacity(0.5),
                      overlayColor: color.withOpacity(0.1),
                    ),
                    child: Slider(
                      value: preValue.toDouble(),
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: preValue.toString(),
                      onChanged: (value) {
                        onChanged(value.round(), postValue);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.arrow_forward, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Text(
                    tr('reset_after'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: color,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: color,
                      overlayColor: color.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: postValue.toDouble(),
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: postValue.toString(),
                      onChanged: (value) {
                        onChanged(preValue, value.round());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ResetPhase {
  final String name;
  final int duration;
  final IconData icon;

  ResetPhase({
    required this.name,
    required this.duration,
    required this.icon,
  });
}