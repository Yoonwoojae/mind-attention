import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_attention/core/utils/translation_utils.dart';
import 'package:mind_attention/core/utils/logger.dart';
import 'package:mind_attention/widgets/help_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnvironmentSetupScreen extends StatefulWidget {
  const EnvironmentSetupScreen({super.key});

  @override
  State<EnvironmentSetupScreen> createState() => _EnvironmentSetupScreenState();
}

class _EnvironmentSetupScreenState extends State<EnvironmentSetupScreen>
    with TickerProviderStateMixin {
  String _selectedLocation = 'home';
  List<ChecklistItem> _activeChecklist = [];
  Timer? _cleanupTimer;
  int _cleanupSeconds = 120;
  bool _isCleanupRunning = false;
  late AnimationController _checkAnimationController;
  late SharedPreferences _prefs;

  final Map<String, EnvironmentRecipe> _recipes = {
    'home': EnvironmentRecipe(
      name: 'env_home',
      icon: Icons.home,
      color: const Color(0xFF4CAF50),
      checklist: [
        ChecklistItem(id: 'dnd', title: 'env_check_dnd', icon: Icons.do_not_disturb),
        ChecklistItem(id: 'desk', title: 'env_check_desk', icon: Icons.cleaning_services),
        ChecklistItem(id: 'water', title: 'env_check_water', icon: Icons.local_drink),
        ChecklistItem(id: 'light', title: 'env_check_light', icon: Icons.light_mode),
        ChecklistItem(id: 'temp', title: 'env_check_temp', icon: Icons.thermostat),
        ChecklistItem(id: 'noise', title: 'env_check_noise', icon: Icons.headphones),
      ],
    ),
    'office': EnvironmentRecipe(
      name: 'env_office',
      icon: Icons.business,
      color: const Color(0xFF2196F3),
      checklist: [
        ChecklistItem(id: 'dnd', title: 'env_check_dnd', icon: Icons.do_not_disturb),
        ChecklistItem(id: 'calendar', title: 'env_check_calendar', icon: Icons.event),
        ChecklistItem(id: 'email', title: 'env_check_email', icon: Icons.email),
        ChecklistItem(id: 'tabs', title: 'env_check_tabs', icon: Icons.tab),
        ChecklistItem(id: 'phone', title: 'env_check_phone', icon: Icons.phone_android),
        ChecklistItem(id: 'notes', title: 'env_check_notes', icon: Icons.note),
      ],
    ),
    'cafe': EnvironmentRecipe(
      name: 'env_cafe',
      icon: Icons.coffee,
      color: const Color(0xFF795548),
      checklist: [
        ChecklistItem(id: 'seat', title: 'env_check_seat', icon: Icons.chair),
        ChecklistItem(id: 'power', title: 'env_check_power', icon: Icons.power),
        ChecklistItem(id: 'wifi', title: 'env_check_wifi', icon: Icons.wifi),
        ChecklistItem(id: 'headphones', title: 'env_check_headphones', icon: Icons.headphones),
        ChecklistItem(id: 'order', title: 'env_check_order', icon: Icons.coffee),
        ChecklistItem(id: 'time', title: 'env_check_time', icon: Icons.schedule),
      ],
    ),
  };

  List<String> _distractions = [];
  final TextEditingController _distractionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _activeChecklist = List.from(_recipes[_selectedLocation]!.checklist);
    _checkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _distractions = _prefs.getStringList('focus_distractions') ?? [];
    });
  }

  Future<void> _saveDistractions() async {
    await _prefs.setStringList('focus_distractions', _distractions);
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    _checkAnimationController.dispose();
    _distractionController.dispose();
    super.dispose();
  }

  void _startCleanup() {
    setState(() {
      _isCleanupRunning = true;
      _cleanupSeconds = 120;
    });

    HapticFeedback.mediumImpact();

    _cleanupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_cleanupSeconds > 0) {
          _cleanupSeconds--;
          
          if (_cleanupSeconds == 30) {
            HapticFeedback.lightImpact();
            _showNotification(tr('env_cleanup_30s'));
          }
        } else {
          _completeCleanup();
        }
      });
    });
  }

  void _completeCleanup() {
    _cleanupTimer?.cancel();
    setState(() {
      _isCleanupRunning = false;
    });

    HapticFeedback.heavyImpact();
    _showNotification(tr('env_cleanup_complete'));
    
    AppLogger.i('2-minute cleanup completed');
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF9C27B0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _toggleChecklistItem(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _activeChecklist[index].isChecked = !_activeChecklist[index].isChecked;
    });
    _checkAnimationController.forward(from: 0);
    
    if (_activeChecklist.every((item) => item.isChecked)) {
      _showReadyDialog();
    }
  }

  void _showReadyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.rocket_launch,
              color: Color(0xFF9C27B0),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              tr('env_ready_title'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr('env_ready_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr('env_stay_here')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/focus/timer');
                  },
                  child: Text(tr('env_start_focus')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addDistraction() {
    if (_distractionController.text.isNotEmpty) {
      setState(() {
        _distractions.add(_distractionController.text);
        _distractionController.clear();
      });
      _saveDistractions();
      HapticFeedback.lightImpact();
    }
  }

  void _removeDistraction(int index) {
    setState(() {
      _distractions.removeAt(index);
    });
    _saveDistractions();
    HapticFeedback.lightImpact();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _recipes[_selectedLocation]!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            if (_isCleanupRunning) {
              _cleanupTimer?.cancel();
            }
            context.pop();
          },
        ),
        title: Text(
          tr('focus_environment'),
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {
              HelpDialog.show(
                context,
                titleKey: 'help_environment_title',
                purposeKey: 'help_environment_purpose',
                benefitsKey: 'help_environment_benefits',
                howToUseKey: 'help_environment_how_to_use',
                tipKeys: [
                  'help_environment_tip1',
                  'help_environment_tip2',
                  'help_environment_tip3',
                ],
                primaryColor: const Color(0xFF9C27B0),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              icon: const Icon(Icons.save, size: 20),
              label: Text(tr('env_save')),
              onPressed: () {
                _showNotification(tr('env_saved'));
                AppLogger.i('Environment setup saved');
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationSelector(),
              const SizedBox(height: 32),
              _buildChecklist(recipe),
              const SizedBox(height: 32),
              _buildCleanupTimer(),
              const SizedBox(height: 32),
              _buildDistractionsList(),
              const SizedBox(height: 32),
              _buildRoutines(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildStartButton(),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('env_select_location'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: _recipes.entries.map((entry) {
            final isSelected = _selectedLocation == entry.key;
            final recipe = entry.value;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedLocation = entry.key;
                    _activeChecklist = List.from(recipe.checklist);
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: entry.key != 'cafe' ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? recipe.color.withOpacity(0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? recipe.color : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        recipe.icon,
                        color: isSelected ? recipe.color : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tr(recipe.name),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? recipe.color : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChecklist(EnvironmentRecipe recipe) {
    final checkedCount = _activeChecklist.where((item) => item.isChecked).length;
    final progress = _activeChecklist.isEmpty 
        ? 0.0 
        : checkedCount / _activeChecklist.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tr('env_checklist'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: recipe.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$checkedCount/${_activeChecklist.length}',
                style: TextStyle(
                  color: recipe.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(recipe.color),
          ),
        ),
        const SizedBox(height: 16),
        ..._activeChecklist.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return GestureDetector(
            onTap: () => _toggleChecklistItem(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.isChecked 
                    ? recipe.color.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: item.isChecked 
                      ? recipe.color
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: item.isChecked ? recipe.color : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: item.isChecked ? recipe.color : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: item.isChecked
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    item.icon,
                    color: item.isChecked ? recipe.color : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tr(item.title),
                      style: TextStyle(
                        fontSize: 15,
                        color: item.isChecked ? recipe.color : Colors.black87,
                        decoration: item.isChecked 
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCleanupTimer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B6B).withOpacity(0.1),
            const Color(0xFFFFE66D).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.cleaning_services,
                color: Color(0xFFFF6B6B),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('env_2min_cleanup'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      tr('env_cleanup_desc'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isCleanupRunning) ...[
            Text(
              _formatTime(_cleanupSeconds),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_cleanupSeconds / 120),
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _cleanupTimer?.cancel();
                setState(() {
                  _isCleanupRunning = false;
                });
              },
              child: Text(tr('env_stop_cleanup')),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: Text(tr('env_start_cleanup')),
                onPressed: _startCleanup,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDistractionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('env_distractions'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr('env_distractions_desc'),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _distractionController,
                decoration: InputDecoration(
                  hintText: tr('env_add_distraction'),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _addDistraction(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _addDistraction,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_distractions.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _distractions.asMap().entries.map((entry) {
              final index = entry.key;
              final distraction = entry.value;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF5252)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning,
                      size: 16,
                      color: Color(0xFFFF5252),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      distraction,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFF5252),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _removeDistraction(index),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFFFF5252),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildRoutines() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('env_routines'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildRoutineCard(
          title: tr('env_start_routine'),
          icon: Icons.play_circle,
          color: const Color(0xFF4CAF50),
          items: [
            tr('env_routine_dnd'),
            tr('env_routine_water'),
            tr('env_routine_goals'),
          ],
        ),
        const SizedBox(height: 12),
        _buildRoutineCard(
          title: tr('env_end_routine'),
          icon: Icons.stop_circle,
          color: const Color(0xFFFF5252),
          items: [
            tr('env_routine_save'),
            tr('env_routine_cleanup'),
            tr('env_routine_next'),
          ],
        ),
      ],
    );
  }

  Widget _buildRoutineCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    final allChecked = _activeChecklist.every((item) => item.isChecked);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (allChecked) {
          context.push('/focus/timer');
        } else {
          _showNotification(tr('env_complete_checklist'));
        }
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: allChecked
                ? [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)]
                : [Colors.grey.shade400, Colors.grey.shade500],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: allChecked
                  ? const Color(0xFF9C27B0).withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          allChecked ? Icons.rocket_launch : Icons.lock,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

class EnvironmentRecipe {
  final String name;
  final IconData icon;
  final Color color;
  final List<ChecklistItem> checklist;

  EnvironmentRecipe({
    required this.name,
    required this.icon,
    required this.color,
    required this.checklist,
  });
}

class ChecklistItem {
  final String id;
  final String title;
  final IconData icon;
  bool isChecked;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.icon,
    this.isChecked = false,
  });
}