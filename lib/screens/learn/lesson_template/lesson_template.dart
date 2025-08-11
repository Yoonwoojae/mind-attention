import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../../../core/utils/translation_utils.dart';
import '../../../core/utils/logger.dart';

class LessonTemplate extends StatefulWidget {
  final String moduleId;
  final String sessionId;
  final Map<String, dynamic> lessonData;
  final VoidCallback onComplete;

  const LessonTemplate({
    super.key,
    required this.moduleId,
    required this.sessionId,
    required this.lessonData,
    required this.onComplete,
  });

  @override
  State<LessonTemplate> createState() => _LessonTemplateState();
}

class _LessonTemplateState extends State<LessonTemplate> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  bool _hasReachedEnd = false;
  
  // 오디오 관련 변수
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioAvailable = false;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1.0;
  int _currentSectionIndex = -1;
  List<Map<String, dynamic>> _timestamps = [];
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
    
    // 오디오 초기화를 먼저 시작하고 UI는 바로 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAudio();
    });
    
    AppLogger.d('LessonTemplate initialized for module: ${widget.moduleId}, session: ${widget.sessionId}');
  }
  
  Future<void> _initializeAudio() async {
    // 오디오 데이터 확인
    final audioData = widget.lessonData['audio'];
    if (audioData == null || audioData['url'] == null) return;
    
    // 타임스탬프 데이터는 바로 로드 (네트워크 요청 없음)
    if (audioData['timestamps'] != null) {
      _timestamps = List<Map<String, dynamic>>.from(audioData['timestamps']);
    }
    
    // 스트림 리스너 먼저 설정 (빠른 반응성)
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      }
    });
    
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
        _updateCurrentSection(position);
      }
    });
    
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
    
    // UI를 먼저 표시하고 오디오 로딩은 비동기로
    setState(() {
      _isAudioAvailable = true; // 로딩 중에도 UI 표시
    });
    
    try {
      // 오디오 URL 설정 (버퍼링 최소화)
      await _audioPlayer.setUrl(
        audioData['url'],
        preload: true, // 미리 로드
        initialPosition: Duration.zero,
      );
      
      AppLogger.d('Audio initialized successfully');
    } catch (e) {
      AppLogger.e('Failed to initialize audio: $e');
      if (mounted) {
        setState(() {
          _isAudioAvailable = false;
        });
      }
    }
  }
  
  void _updateCurrentSection(Duration position) {
    if (_timestamps.isEmpty) return;
    
    final currentSeconds = position.inSeconds.toDouble();
    
    for (int i = 0; i < _timestamps.length; i++) {
      final startTime = _timestamps[i]['start_time'] ?? 0.0;
      final endTime = _timestamps[i]['end_time'] ?? 
          (i < _timestamps.length - 1 ? _timestamps[i + 1]['start_time'] : _duration.inSeconds.toDouble());
      
      if (currentSeconds >= startTime && currentSeconds < endTime) {
        if (_currentSectionIndex != i) {
          setState(() {
            _currentSectionIndex = i;
          });
          _scrollToSection(i);
        }
        break;
      }
    }
  }
  
  void _scrollToSection(int sectionIndex) {
    // 해당 섹션으로 자동 스크롤
    // 실제 구현은 섹션 위치 계산 필요
    final targetOffset = sectionIndex * 200.0; // 임시 값
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }
  
  void _seekBackward() async {
    final newPosition = _position - const Duration(seconds: 10);
    await _audioPlayer.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }
  
  void _seekForward() async {
    final newPosition = _position + const Duration(seconds: 10);
    await _audioPlayer.seek(newPosition > _duration ? _duration : newPosition);
  }
  
  void _changeSpeed() async {
    final speeds = [0.75, 1.0, 1.25, 1.5];
    final currentIndex = speeds.indexOf(_playbackSpeed);
    final nextIndex = (currentIndex + 1) % speeds.length;
    _playbackSpeed = speeds[nextIndex];
    await _audioPlayer.setSpeed(_playbackSpeed);
    setState(() {});
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _updateScrollProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      setState(() {
        _scrollProgress = maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;
        
        // 스크롤이 끝까지 도달했는지 확인
        if (currentScroll >= maxScroll - 50) {
          _hasReachedEnd = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.lessonData['title'] ?? '';
    final subtitle = widget.lessonData['subtitle'] ?? '';
    final dayInfo = widget.lessonData['dayInfo'] ?? 'Day 1 / 3';
    final image = widget.lessonData['image'] ?? '';
    final sections = widget.lessonData['sections'] ?? [];
    final highlights = widget.lessonData['highlights'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 상단 헤더
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    dayInfo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (image.isNotEmpty)
                        Image.asset(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade600,
                              ],
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              // 제목 섹션
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                          height: 1.3,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      
                      // 진행도 바
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _scrollProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D6A4F),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 콘텐츠 섹션들
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final section = sections[index];
                      return _buildSection(section, highlights, index);
                    },
                    childCount: sections.length,
                  ),
                ),
              ),
            ],
          ),
          
          // 하단 다음 버튼
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _hasReachedEnd ? widget.onComplete : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A4F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: Text(
                      tr('lesson_next_button'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 하단 오디오 플레이어
          if (_isAudioAvailable)
            _buildAudioPlayer(sections),
        ],
      ),
    );
  }
  
  Widget _buildAudioPlayer(List<dynamic> sections) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 클릭 가능한 진행 바
              GestureDetector(
                onTapDown: (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  final percentage = localPosition.dx / box.size.width;
                  final newPosition = Duration(seconds: (_duration.inSeconds * percentage).round());
                  _audioPlayer.seek(newPosition);
                },
                child: Container(
                  height: 8,
                  child: Stack(
                    children: [
                      // 배경 바
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                        ),
                      ),
                      // 진행 바
                      FractionallySizedBox(
                        widthFactor: _duration.inSeconds > 0 
                            ? _position.inSeconds / _duration.inSeconds
                            : 0.0,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D6A4F),
                          ),
                        ),
                      ),
                      // 현재 위치 인디케이터
                      if (_duration.inSeconds > 0)
                        Positioned(
                          left: (MediaQuery.of(context).size.width * 
                              (_position.inSeconds / _duration.inSeconds)).clamp(0.0, MediaQuery.of(context).size.width - 12),
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF2D6A4F),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // 시간 표시
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_currentSectionIndex >= 0 && _currentSectionIndex < sections.length)
                          Expanded(
                            child: Text(
                              _getSectionTitle(sections[_currentSectionIndex]),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Text(
                          _formatDuration(_duration),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 컨트롤 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 속도 버튼
                        TextButton(
                          onPressed: _changeSpeed,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_playbackSpeed}x',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 24),
                        
                        // 10초 뒤로
                        IconButton(
                          icon: const Icon(Icons.replay_10),
                          iconSize: 32,
                          color: const Color(0xFF2C3E50),
                          onPressed: _seekBackward,
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // 재생/일시정지
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D6A4F),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            iconSize: 32,
                            onPressed: _togglePlayPause,
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // 10초 앞으로
                        IconButton(
                          icon: const Icon(Icons.forward_10),
                          iconSize: 32,
                          color: const Color(0xFF2C3E50),
                          onPressed: _seekForward,
                        ),
                        
                        const SizedBox(width: 24),
                        
                        // 현재 섹션 표시
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_currentSectionIndex + 1}/${sections.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getSectionTitle(Map<String, dynamic> section) {
    final content = section['content'] ?? '';
    if (content.length > 30) {
      return content.substring(0, 30) + '...';
    }
    return content;
  }

  Widget _buildSection(Map<String, dynamic> section, List<String> highlights, [int? index]) {
    final type = section['type'] ?? 'text';
    final content = section['content'] ?? '';
    final isHighlighted = index != null && index == _currentSectionIndex;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.yellow.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(isHighlighted ? 8 : 0),
      child: _buildSectionContent(type, content, section, highlights),
    );
  }
  
  Widget _buildSectionContent(String type, String content, Map<String, dynamic> section, List<String> highlights) {
    
    switch (type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 24),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
              height: 1.3,
            ),
          ),
        );
        
      case 'subheading':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 16),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
              height: 1.3,
            ),
          ),
        );
        
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildHighlightedText(content, highlights),
        );
        
      case 'bullet_list':
        final items = section['items'] ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2D6A4F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: _buildHighlightedText(item, highlights),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
        
      case 'info_box':
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.shade200,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHighlightedText(content, highlights),
              ),
            ],
          ),
        );
        
      case 'quote':
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.orange.shade400,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHighlightedText(content, highlights),
              if (section['author'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  '— ${section['author']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
        
      case 'image':
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              content,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                  ),
                );
              },
            ),
          ),
        );
        
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        );
    }
  }
  
  Widget _buildHighlightedText(String text, List<String> highlights) {
    if (highlights.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
          height: 1.6,
          letterSpacing: 0.2,
        ),
      );
    }
    
    List<TextSpan> spans = [];
    String remainingText = text;
    
    for (String highlight in highlights) {
      if (remainingText.contains(highlight)) {
        final parts = remainingText.split(highlight);
        if (parts[0].isNotEmpty) {
          spans.add(TextSpan(
            text: parts[0],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ));
        }
        spans.add(TextSpan(
          text: highlight,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            height: 1.6,
            letterSpacing: 0.2,
            backgroundColor: Colors.yellow.withOpacity(0.3),
            fontWeight: FontWeight.w600,
          ),
        ));
        remainingText = parts.sublist(1).join(highlight);
      }
    }
    
    if (remainingText.isNotEmpty) {
      spans.add(TextSpan(
        text: remainingText,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
          height: 1.6,
          letterSpacing: 0.2,
        ),
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
