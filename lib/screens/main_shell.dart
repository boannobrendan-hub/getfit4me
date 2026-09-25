import 'dart:async';
import 'package:flutter/material.dart';
import '../models/coach.dart';
import '../models/coach_brain.dart';
import '../models/exercise_matrices.dart';
import '../models/subscription_state.dart';
import '../services/firestore_service.dart';
import '../widgets/exercise_illustration.dart';
import 'workout_feedback_screen.dart';
import 'paywall_screen.dart';

class MainShell extends StatefulWidget {
  final SubscriptionState sub;
  const MainShell({super.key, required this.sub});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _firestoreService = FirestoreService();
  final _coachBrain = CoachBrain();

  int _currentIndex = 0;
  String _selectedSport = 'Basketball';
  String _selectedCondition = 'Rheumatoid Arthritis';
  bool _isSportMode = true;
  double _energyLevel = 5.0;
  bool _hasJointPain = false;

  bool _crossRefEnabled = false;
  String _crossRefSport = 'Basketball';
  String _crossRefCondition = 'Rheumatoid Arthritis';

  List<String> _activeSafetyFlags = [];
  List<String> _activeForbiddenList = [];
  List<Map<String, String>> _dynamicActiveWorkout = [];
  int _currentExerciseIndex = 0;
  bool _isResting = false;
  String? _crossRefNote;
  String? _workoutAdjustmentNote;
  int _workoutAdjustmentDirection = 0;

  Timer? _exerciseTimer;
  int _secondsRemaining = 0;
  bool _isTimerRunning = false;

  int _completedWorkoutsCount = 0;
  int _bodyListenerFlagsCount = 0;
  int _totalCheckInsCount = 0;
  List<DateTime> _completionTimestamps = [];
  List<Map<String, dynamic>> _feedbackHistory = [];

  String _profileEmoji = '💪';
  static const List<String> _avatarOptions = [
    '💪', '🏃', '🏀', '⚽', '🎾', '🚴', '🥊', '🏊', '🧘', '🦸',
    '🦁', '🐯', '🦅', '🐺', '🔥', '⚡', '🌟', '🌊', '🌿', '👑',
  ];

  int _activeCoachIndex = 0;
  final List<Map<String, dynamic>> _chatMessages = [];

  Coach get _coach => kCoaches[_activeCoachIndex];

  @override
  void initState() {
    super.initState();
    _activeCoachIndex = DateTime.now().millisecond % kCoaches.length;
    _loadInitialData();
  }

  @override
  void dispose() {
    _exerciseTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final timestamps = await _firestoreService.fetchCompletionTimestamps();
      final feedback = await _firestoreService.fetchRecentFeedback(limit: 20);
      if (!mounted) return;
      setState(() {
        _completionTimestamps = timestamps;
        _feedbackHistory = feedback;
        _completedWorkoutsCount = timestamps.length;
      });
    } catch (_) {
      // Non-fatal — trophy/feedback views will just show empty states
      // until connectivity is restored.
    }
  }

  // ── Active category helpers ──────────────────────────────────────────────
  Map<String, Map<String, dynamic>> get _activeMatrix => _isSportMode ? kSportMatrix : kMedicalMatrix;
  String get _activeSelection => _isSportMode ? _selectedSport : _selectedCondition;

  void _setActiveSelection(String value) {
    setState(() {
      if (_isSportMode) {
        _selectedSport = value;
      } else {
        _selectedCondition = value;
      }
    });
    _firestoreService.updateSelection(isSportMode: _isSportMode, sport: _selectedSport, condition: _selectedCondition);
  }

  // ── Cross-reference engine ────────────────────────────────────────────────
  String? _crossReferenceNote(String sport, String condition) {
    final sportTags = kSportDemandTags[sport] ?? [];
    final condTags = kConditionSensitivityTags[condition] ?? [];
    bool has(String t) => condTags.contains(t);
    bool sportHas(String t) => sportTags.contains(t);

    if (sportHas('cardio') && has('breathingPaced')) {
      return "Because $sport involves sustained cardio output and you're managing $condition, "
          "we've extended your warm-up ramp and added breathing-pattern cues during interval-style work. "
          "If you ever feel your breathing tightening up, ease off immediately — don't try to push through it.";
    }
    if ((sportHas('impact') || sportHas('explosive')) && has('jointSensitive')) {
      return "$sport places repeated load on your joints, and with $condition we want to be extra "
          "thoughtful about that. We've prioritized lower-impact variations where possible and added "
          "extra joint-prep work before anything explosive. Listen closely to any joint-specific signals today.";
    }
    if (sportHas('impact') && has('fractureRisk')) {
      return "$sport involves repeated impact, and with $condition, bone health is something to be "
          "mindful of. We've leaned your session toward controlled strength work that supports bone "
          "density without unnecessary high-impact loading. Please make sure your doctor has cleared "
          "this combination specifically.";
    }
    if (sportHas('contact') && has('fractureRisk')) {
      return "$sport involves contact, and with $condition that's worth flagging directly — please "
          "discuss contact-sport participation with your doctor specifically, as bone fragility changes "
          "the risk profile here more than with most other conditions.";
    }
    if ((sportHas('cardio') || sportHas('explosive')) && has('cardioCaution')) {
      return "$sport can spike intensity quickly, and with $condition we're keeping a closer eye on "
          "gradual intensity build-up today. We've smoothed out sudden bursts where we can and added "
          "more transition time between higher-effort segments.";
    }
    if ((sportHas('explosive') || sportHas('heavyLoad')) && has('fatigueSensitive')) {
      return "$sport tends to demand a lot of explosive output, and with $condition, energy "
          "management matters as much as the workout itself. We've built in more recovery between "
          "high-effort segments — if today is a higher-fatigue day, scaling back further is always the right call.";
    }
    if ((sportHas('rotational') || sportHas('heavyLoad')) && has('spineSensitive')) {
      return "$sport involves rotational or loaded movements, and with $condition we've adjusted "
          "core-bracing cues throughout your session and substituted any exercises with loaded spinal "
          "twisting for safer alternatives that still build the strength $sport demands.";
    }
    if (sportHas('shoulderLoad') && has('gripSensitive')) {
      return "$sport places repetitive demand on your shoulders and grip, and with $condition we've "
          "added extra shoulder-stability and hand-friendly variations so you can keep training without "
          "overloading joints that are already working hard day to day.";
    }
    if (sportHas('directionChange') && has('balanceShift')) {
      return "$sport involves quick changes of direction, and with $condition we've added extra "
          "balance and coordination work as a foundation before any agility drills — building that base "
          "first makes the faster movements safer and more effective.";
    }
    if (sportHas('cardio') && has('glucoseAware')) {
      return "Good news — $sport's cardio demands actually work well alongside managing $condition, "
          "since sustained aerobic effort supports insulin sensitivity. We've kept your session "
          "structured around steady, sustained effort rather than short extreme bursts for that reason.";
    }
    if (sportHas('lowImpact') && has('lowImpactPreferred')) {
      return "$sport is a great match here — its low-impact nature lines up well with managing "
          "$condition, so you can build real fitness without the joint stress that higher-impact "
          "sports would add. We've kept the structure built around that strength.";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildDiagnosticsView(),
      _buildEngineView(),
      _buildSupportView(),
      _buildTrophyRoomView(),
      _buildAccountView(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.healing), label: 'Diagnostics'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Engine'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Trophies'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }

  // ── DIAGNOSTICS TAB ────────────────────────────────────────────────────────
  Widget _buildDiagnosticsView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF00897B)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Today, are you training for...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _modeButton('🏆 Sport Performance', _isSportMode, () => setState(() => _isSportMode = true)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _modeButton('🩺 Medical Condition', !_isSportMode, () => setState(() => _isSportMode = false)),
            ),
          ]),

          const SizedBox(height: 16),
          Text(_isSportMode ? "Select Your Sport:" : "Select Your Condition:", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00897B))),
          const SizedBox(height: 6),
          DropdownButton<String>(
            value: _activeSelection,
            isExpanded: true,
            borderRadius: BorderRadius.circular(10),
            items: _activeMatrix.keys.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => _setActiveSelection(v!),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _isSportMode ? "Also managing a medical condition?" : "Also training for a specific sport?",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: Text(
                  _isSportMode
                      ? "We'll explain how your $_selectedSport training adjusts for it."
                      : "We'll explain how managing $_selectedCondition affects your $_crossRefSport training.",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                value: _crossRefEnabled,
                activeColor: const Color(0xFF00897B),
                onChanged: (v) => setState(() => _crossRefEnabled = v),
              ),
              if (_crossRefEnabled) ...[
                const SizedBox(height: 4),
                Text(_isSportMode ? "Select Your Condition:" : "Select Your Sport:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF00897B))),
                const SizedBox(height: 4),
                DropdownButton<String>(
                  value: _isSportMode ? _crossRefCondition : _crossRefSport,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(10),
                  items: (_isSportMode ? kMedicalMatrix.keys : kSportMatrix.keys)
                      .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) => setState(() {
                    if (_isSportMode) {
                      _crossRefCondition = v!;
                    } else {
                      _crossRefSport = v!;
                    }
                  }),
                ),
              ],
            ]),
          ),

          const Divider(height: 36),
          const Text('How is your energy today?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Slider(
            value: _energyLevel,
            min: 1, max: 10, divisions: 9,
            activeColor: const Color(0xFF00897B),
            label: _energyLevel.round().toString(),
            onChanged: (v) => setState(() => _energyLevel = v),
          ),
          Text(_energyLevel < 4 ? 'Low energy — we\'ll keep things gentle today.' : 'Good to go.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),

          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Any joint pain today?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            value: _hasJointPain,
            activeColor: Colors.orange,
            onChanged: (v) => setState(() => _hasJointPain = v),
          ),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _compileDynamicMedicalWorkout,
              child: const Text('Compile My Workout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _modeButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00897B).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF00897B) : Colors.grey.shade300, width: selected ? 2 : 1),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: selected ? const Color(0xFF00897B) : Colors.grey.shade700)),
      ),
    );
  }

  // ── WORKOUT COMPILATION ────────────────────────────────────────────────────
  void _compileDynamicMedicalWorkout() {
    _pauseExerciseTimer();
    setState(() => _totalCheckInsCount++);
    final matrixData = _activeMatrix[_activeSelection]!;
    List<String> flags = [matrixData['flag'] as String];
    List<String> avoidances = [matrixData['avoid'] as String];
    List<Map<String, String>> routine = List<Map<String, String>>.from(
      (matrixData['exercises'] as List).map((e) => Map<String, String>.from(e as Map)),
    );

    String? feedbackAdjustmentNote;
    int adjustmentDirection = 0;
    final lastRelevantFeedback = _feedbackHistory.firstWhere(
      (f) => f['activity'] == _activeSelection,
      orElse: () => {},
    );

    if (lastRelevantFeedback.isNotEmpty) {
      final rating = lastRelevantFeedback['rating'] as int? ?? 0;
      final tags = List<String>.from(lastRelevantFeedback['tags'] as List? ?? []);
      final flaggedPain = tags.contains('Pain or discomfort');
      final flaggedTooHard = tags.contains('Too hard');
      final flaggedExhausted = tags.contains('Felt exhausted');
      final flaggedTooEasy = tags.contains('Too easy');
      final lowRating = rating > 0 && rating <= 2;

      if (flaggedPain) {
        routine = _scaleRoutineIntensity(routine, 0.7);
        adjustmentDirection = -1;
        feedbackAdjustmentNote =
            "Last time you flagged some pain or discomfort during ${_activeSelection}, so I've scaled "
            "today's session back and lightened the load on anything that might aggravate it. If it's "
            "still bothering you at all, stop and let me know before continuing.";
      } else if (flaggedTooHard || lowRating) {
        routine = _scaleRoutineIntensity(routine, 0.8);
        adjustmentDirection = -1;
        feedbackAdjustmentNote =
            "You let me know last time felt like too much, so I've eased the intensity back a bit "
            "today — shorter holds, a gentler ramp. We'll build back up gradually.";
      } else if (flaggedExhausted) {
        routine = _scaleRoutineIntensity(routine, 0.85);
        adjustmentDirection = -1;
        feedbackAdjustmentNote =
            "Since you mentioned feeling exhausted after your last session, I've trimmed today's "
            "volume slightly so we keep building without digging too deep into fatigue.";
      } else if (flaggedTooEasy && rating >= 4) {
        routine = _scaleRoutineIntensity(routine, 1.15);
        adjustmentDirection = 1;
        feedbackAdjustmentNote =
            "You said last time felt too easy, so I've bumped up today's intensity a notch — let's "
            "keep that progress moving.";
      }
    }

    if (_energyLevel < 4) {
      setState(() => _bodyListenerFlagsCount++);
      flags = ['🌿 Systemic Fatigue Protocol Overwrite Enforced'];
      avoidances = ['All heavy resistance training blocks today.'];
      routine = [
        {'name': '1. Diaphragmatic Deep Breathing', 'target': '300 Sec', 'tip': 'Inhale into your stomach for 4s, exhale for 6s.'},
        {'name': '2. Gentle Unloaded Full Body Stretching', 'target': '600 Sec', 'tip': 'Move slowly within a safe, pain-free window.'},
      ];
      feedbackAdjustmentNote = null;
      adjustmentDirection = 0;
      _addCoachMessage(_lowEnergyMessage());
    } else {
      _addCoachMessage(_workoutStartMessage());
    }

    if (feedbackAdjustmentNote != null) {
      _addCoachMessage("📝 $feedbackAdjustmentNote");
    }

    if (_hasJointPain) {
      setState(() => _bodyListenerFlagsCount++);
      _addCoachMessage(_jointPainMessage());
    }

    String? crossNote;
    if (_crossRefEnabled) {
      final sport = _isSportMode ? _selectedSport : _crossRefSport;
      final condition = _isSportMode ? _crossRefCondition : _selectedCondition;
      crossNote = _crossReferenceNote(sport, condition);
      if (crossNote != null) {
        _addCoachMessage("🔗 $crossNote");
      } else {
        _addCoachMessage(
          "🔗 I've noted that you're working with both $sport and $condition. There's no specific "
          "extra adjustment needed for this combination beyond your existing safety flags, but I'm "
          "keeping both in mind as we go — let me know if anything feels different than usual.",
        );
      }
    }

    setState(() {
      _activeSafetyFlags = flags;
      _activeForbiddenList = avoidances;
      _dynamicActiveWorkout = routine;
      _currentExerciseIndex = 0;
      _secondsRemaining = _extractDurationSeconds(_dynamicActiveWorkout[0]['target']!);
      _currentIndex = 1;
      _crossRefNote = crossNote;
      _workoutAdjustmentNote = feedbackAdjustmentNote;
      _workoutAdjustmentDirection = adjustmentDirection;
    });
  }

  List<Map<String, String>> _scaleRoutineIntensity(List<Map<String, String>> routine, double factor) {
    return routine.map((exercise) {
      final target = exercise['target'] ?? '30 Sec';
      final parts = target.split(' ');
      final seconds = int.tryParse(parts[0]) ?? 30;
      final unit = parts.length > 1 ? parts.sublist(1).join(' ') : 'Sec';
      final scaled = (seconds * factor).round().clamp(10, 1800);
      return {'name': exercise['name']!, 'target': '$scaled $unit', 'tip': exercise['tip']!};
    }).toList();
  }

  int _extractDurationSeconds(String targetText) {
    try {
      return int.parse(targetText.split(' ')[0]);
    } catch (_) {
      return 30;
    }
  }

  String _workoutStartMessage() {
    final msgs = {
      'Brendan': "Let's GET IT! I've compiled your ${_activeSelection} protocol. Your safety flags are set, your forbidden list is locked in. Now let's go build something. I'm with you every rep.",
      'Justin': "Your personalized ${_activeSelection} session is ready. I've carefully chosen every exercise to work WITH your body today, not against it. Take your time, breathe through it, and message me if anything feels off. I'm right here.",
      'Cameron': "BOOM — your custom ${_activeSelection} workout just dropped! ${_dynamicActiveWorkout.length} exercises, all designed for YOUR body today. Hit that Start Timer and let's make history. I'm tracking everything!",
      'Bell': "Your ${_activeSelection} session is ready, paced for exactly where you're at today. ${_dynamicActiveWorkout.length} exercises, each chosen to build you up without tipping you into overtraining. Let's move at a pace that lasts.",
    };
    return msgs[_coach.name] ?? "Your customized workout is ready! Let's go.";
  }

  String _lowEnergyMessage() {
    final msgs = {
      'Brendan': "I see your energy is low today, and I want to say clearly: that's not a failure, that's information. We're switching to a recovery-focused protocol. Rest is part of training.",
      'Justin': "Thank you for being honest about your energy today. We're shifting to gentle recovery work — your body needs this just as much as a hard session.",
      'Cameron': "Low energy today — got it, no judgment here. Recovery days are where the real gains lock in. Let's do gentle work and come back stronger.",
      'Bell': "I hear you on the low energy. Today's session is built around recovery — gentle, restorative, exactly what your body's asking for.",
    };
    return msgs[_coach.name] ?? "Today we're focusing on gentle recovery work.";
  }

  String _jointPainMessage() {
    final msgs = {
      'Brendan': "Noted on the joint pain — I've kept today's session light on anything that could aggravate it. Speak up immediately if anything feels wrong.",
      'Justin': "Thank you for flagging the joint pain. I'm watching for that throughout today's session — please stop immediately if it worsens.",
      'Cameron': "Got the joint pain flag — today's plan respects that. Smart athletes communicate, and that's exactly what you just did.",
      'Bell': "Joint pain noted — today's session is built to work around it gently. Listen to your body throughout.",
    };
    return msgs[_coach.name] ?? "I've noted the joint pain and adjusted today's session.";
  }

  void _addCoachMessage(String text) {
    setState(() {
      _chatMessages.add({'fromCoach': true, 'text': text, 'time': _nowTime()});
    });
  }

  String _nowTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _pauseExerciseTimer() {
    _exerciseTimer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _startExerciseTimer() {
    _exerciseTimer?.cancel();
    setState(() => _isTimerRunning = true);
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
        _advanceExerciseLogic();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _advanceExerciseLogic() {
    if (_currentExerciseIndex < _dynamicActiveWorkout.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _secondsRemaining = _extractDurationSeconds(_dynamicActiveWorkout[_currentExerciseIndex]['target']!);
        _isTimerRunning = false;
      });
      return;
    }

    _firestoreService.recordWorkoutCompletion(activity: _activeSelection);
    setState(() {
      _completedWorkoutsCount++;
      _completionTimestamps.add(DateTime.now());
    });
    _addCoachMessage(_coach.responses['default']!.replaceFirst(RegExp(r'^[^\s]+'), '🎉 PROGRAM COMPLETE!'));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('🎉 ${_coach.name} says: Done!', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00897B))),
        content: Text(_completionSpeech(), style: const TextStyle(fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => WorkoutFeedbackScreen(
                  coach: _coach,
                  activeSelection: _activeSelection,
                  exerciseCount: _dynamicActiveWorkout.length,
                  onSubmit: _recordWorkoutFeedback,
                ),
              ));
            },
            child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00897B))),
          ),
        ],
      ),
    );
  }

  String _completionSpeech() {
    final lines = {
      'Brendan': "Full program done. I want you to take a real moment and be proud — not just of finishing, but of deciding to start. That decision is everything. Recovery drink, light stretch, and I'll have your next plan dialed in by tomorrow. You've earned this badge.",
      'Justin': "You completed every single exercise in your clinical program today. For someone managing what you manage every day, that is not just fitness — that is resilience in action. Please rest fully, nourish your body, and know that I see how hard you work. Your badge is waiting for you.",
      'Cameron': "FULL PROGRAM COMPLETE! Do you know what just happened? You just proved — with data, with time logged, with real sweat — that you are capable. Not someday. Today. Go collect your badge, rest up, and we go again tomorrow. The streak starts NOW.",
      'Bell': "Session complete — and completed at a pace that respects where you're at today. That's exactly the kind of consistency that builds real recovery and endurance over time. Hydrate, give your body what it needs, and I'll see you for the next one.",
    };
    return lines[_coach.name] ?? "Incredible work. Your badge has been unlocked!";
  }

  void _recordWorkoutFeedback({required int rating, required List<String> tags, required String note}) {
    _firestoreService.recordFeedback(activity: _activeSelection, rating: rating, tags: tags, note: note);
    setState(() {
      _feedbackHistory.insert(0, {
        'rating': rating,
        'tags': tags,
        'note': note,
        'activity': _activeSelection,
        'time': _nowTime(),
      });
      _currentExerciseIndex = 0;
      _dynamicActiveWorkout.clear();
      _crossRefNote = null;
      _workoutAdjustmentNote = null;
      _workoutAdjustmentDirection = 0;
      _currentIndex = 3;
    });

    if (rating > 0) {
      _addCoachMessage(_feedbackResponseMessage(rating, tags));
    }
  }

  String _feedbackResponseMessage(int rating, List<String> tags) {
    final low = rating <= 2;
    final high = rating >= 4;
    final mentionsPain = tags.contains('Pain or discomfort');
    final mentionsTooEasy = tags.contains('Too easy');
    final mentionsTooHard = tags.contains('Too hard');
    final mentionsLoved = tags.contains('Loved it');
    final mentionsTired = tags.contains('Felt exhausted');

    if (mentionsPain) {
      final msgs = {
        'Brendan': "Thanks for flagging the pain/discomfort in your feedback — I've noted it. If it's still bothering you, don't push through it next session; message me here and we'll adjust the plan before you start.",
        'Justin': "I really appreciate you being honest about the discomfort. I've logged it alongside today's session. If anything is still lingering, let's talk it through before your next workout — adjusting early is always better than pushing through.",
        'Cameron': "Got it — discomfort noted. Real talk: if something's bugging you, that's data, not weakness. I'll have a modified version ready next time. Let me know if it's still there later today.",
        'Bell': "Thank you for sharing that. I've logged the discomfort with today's session — if it's still there later, let's check in before your next workout so we can adjust before you train again.",
      };
      return msgs[_coach.name] ?? "Thanks for the feedback — I've noted the discomfort and will keep an eye on it.";
    }
    if (mentionsTooHard || low) {
      final msgs = {
        'Brendan': "Thanks for the honest feedback. If today felt like too much, that's useful — I'll scale the next session back a notch so we build momentum instead of burnout. No shame in that, that's smart training.",
        'Justin': "I really value this feedback. If today was harder than it should've been, I'll recalibrate your next session to better match where you're at. This is exactly the kind of input that makes your plan actually work for you.",
        'Cameron': "Appreciate the real feedback. If it was too much today, I'm dialing it back next time — not because you couldn't handle it, but because the BEST programs build up gradually. Trust the process.",
        'Bell': "Thank you for telling me. If today felt like too much, I'll ease the intensity for your next session — recovery and sustainable progress matter more than any single hard day.",
      };
      return msgs[_coach.name] ?? "Thanks for the feedback — I'll adjust your next session accordingly.";
    }
    if (mentionsTooEasy) {
      final msgs = {
        'Brendan': "Love that — sounds like you've got more in the tank. I'll bump up the intensity for next time so we keep making real progress.",
        'Justin': "Thank you for letting me know. If today felt manageable, that's a great sign — I'll gradually increase the challenge for your next session so we keep building.",
        'Cameron': "THAT'S what I like to hear! Too easy means you're ready for more. Next session's getting an upgrade — let's keep climbing.",
        'Bell': "Good to know — that tells me your body's adapting well. I'll add a bit more challenge next time, gradually, so the progress stays sustainable.",
      };
      return msgs[_coach.name] ?? "Good to know — I'll increase the challenge slightly for next time.";
    }
    if (mentionsLoved || high) {
      final msgs = {
        'Brendan': "That's what I love to hear! Keep that energy — I'll keep building sessions that hit just as well. Great work today.",
        'Justin': "I'm really glad to hear that. Sessions that feel good AND do good for your body are exactly what we're aiming for — thank you for sharing this.",
        'Cameron': "BOOM. That's the energy! Let's keep this momentum rolling into the next one. Great session.",
        'Bell': "That's wonderful to hear. A session that feels right is exactly what sustainable progress looks like — see you for the next one.",
      };
      return msgs[_coach.name] ?? "Glad to hear it — see you for the next one!";
    }
    if (mentionsTired) {
      final msgs = {
        'Brendan': "Makes sense — that was a real session. Make sure you refuel and rest well tonight. I'll keep an eye on your energy trend for next time.",
        'Justin': "Thank you for sharing that. Feeling tired after a completed session is normal — please prioritize rest and hydration tonight. I'll factor this into your next plan.",
        'Cameron': "Good — that means you put in real work. Refuel, rest, and let's go again when you're ready.",
        'Bell': "Noted — and that's completely normal after a full session. Prioritize rest and recovery tonight, and I'll keep this in mind for your next plan.",
      };
      return msgs[_coach.name] ?? "Thanks for sharing — make sure to rest and refuel tonight.";
    }
    return "Thanks for the feedback — it helps me keep your plan tuned to you.";
  }

  // ── ENGINE TAB (workout tracker) ──────────────────────────────────────────
  Widget _buildEngineView() {
    if (_dynamicActiveWorkout.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Engine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF00897B)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.fitness_center, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No active workout yet.', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Head to Diagnostics to compile a personalized session.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ]),
          ),
        ),
      );
    }

    final currentExercise = _dynamicActiveWorkout[_currentExerciseIndex];
    final progress = (_currentExerciseIndex + 1) / _dynamicActiveWorkout.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Engine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF00897B)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation(Color(0xFF00897B)), minHeight: 6),
          const SizedBox(height: 6),
          Text('Exercise ${_currentExerciseIndex + 1} of ${_dynamicActiveWorkout.length}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),

          const SizedBox(height: 16),
          ..._activeSafetyFlags.map((f) => Text(f, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12))),
          Text('🚫 Avoid: ${_activeForbiddenList.join(' | ')}', style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.w500)),

          if (_workoutAdjustmentNote != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _workoutAdjustmentDirection < 0 ? Colors.blue.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _workoutAdjustmentDirection < 0 ? Colors.blue.shade200 : Colors.green.shade200),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: _workoutAdjustmentDirection < 0 ? Colors.blue.shade600 : Colors.green.shade600, borderRadius: BorderRadius.circular(6)),
                  child: Text(_workoutAdjustmentDirection < 0 ? 'SCALED DOWN' : 'SCALED UP', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.4)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(_workoutAdjustmentNote!, style: TextStyle(fontSize: 11.5, height: 1.4, color: _workoutAdjustmentDirection < 0 ? Colors.blue.shade800 : Colors.green.shade800))),
              ]),
            ),
          ],
          if (_crossRefNote != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: _coach.accentColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: _coach.accentColor.withOpacity(0.25))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('🔗 ', style: TextStyle(fontSize: 12)),
                Expanded(child: Text(_crossRefNote!, style: TextStyle(fontSize: 11.5, height: 1.4, color: _coach.accentColor))),
              ]),
            ),
          ],
          const Divider(height: 20),

          Text(currentExercise['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 6),
          Text(currentExercise['tip']!, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),

          const SizedBox(height: 16),
          ExerciseIllustration(exerciseName: currentExercise['name']!, color: _coach.accentColor),

          const SizedBox(height: 24),
          Center(
            child: Text('$_secondsRemaining', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Color(0xFF00897B))),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _isTimerRunning ? _pauseExerciseTimer : _startExerciseTimer,
                child: Text(_isTimerRunning ? 'Pause' : 'Start Timer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  _pauseExerciseTimer();
                  _advanceExerciseLogic();
                },
                child: const Text('Skip / Next', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  // ── SUPPORT TAB (coach chat) ──────────────────────────────────────────────
  final _chatController = TextEditingController();
  final _chatScrollController = ScrollController();

  void _sendChatMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _chatController.clear();

    setState(() {
      _chatMessages.add({'fromCoach': false, 'text': text, 'time': _nowTime()});
    });

    final reply = _coachBrain.respond(text, _coach);
    setState(() {
      _chatMessages.add({'fromCoach': true, 'text': reply.text, 'time': _nowTime(), 'isUrgent': reply.isUrgent});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _alertLiveTrainer() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 10),
          const Text('Connecting...', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        content: const Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 8),
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Notifying a live trainer now...', textAlign: TextAlign.center),
        ]),
      ),
    );

    // NOTE: in production this calls the alertLiveTrainer Cloud Function
    // (see functions/src/liveTrainerAlert.ts), which writes to the
    // liveTrainerAlerts collection for a staff dashboard to pick up. Wire
    // that call in here via FirebaseFunctions.instance.httpsCallable(...).
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 10),
          Text('Trainer Notified', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        content: const Text(
          'A live trainer has been notified and will reach out as soon as possible. '
          'If this is a medical emergency, please call 911 (or your local emergency number) right now — do not wait for a response here.',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildSupportView() {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text(_coach.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(_coach.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        backgroundColor: const Color(0xFF00897B),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
            tooltip: 'Alert Live Trainer',
            onPressed: _alertLiveTrainer,
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
            tooltip: 'Switch Coach',
            onSelected: (i) => setState(() => _activeCoachIndex = i),
            itemBuilder: (context) => List.generate(kCoaches.length, (i) {
              final c = kCoaches[i];
              return PopupMenuItem(value: i, child: Row(children: [Text(c.emoji), const SizedBox(width: 8), Text(c.name)]));
            }),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: _chatMessages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(_coach.emoji, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(_coach.tagline, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                    ]),
                  ),
                )
              : ListView.builder(
                  controller: _chatScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, i) {
                    final msg = _chatMessages[i];
                    final fromCoach = msg['fromCoach'] as bool;
                    final isUrgent = msg['isUrgent'] as bool? ?? false;
                    return Align(
                      alignment: fromCoach ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isUrgent ? Colors.red.shade50 : (fromCoach ? Colors.grey.shade100 : _coach.accentColor.withOpacity(0.12)),
                          borderRadius: BorderRadius.circular(14),
                          border: isUrgent ? Border.all(color: Colors.red.shade300, width: 1.5) : null,
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (isUrgent)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Row(children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
                                SizedBox(width: 4),
                                Text('URGENT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 10)),
                              ]),
                            ),
                          Text(msg['text'] as String, style: TextStyle(fontSize: 13.5, height: 1.4, color: isUrgent ? Colors.red.shade900 : Colors.black87)),
                          const SizedBox(height: 4),
                          Text(msg['time'] as String, style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
                          if (isUrgent) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, padding: const EdgeInsets.symmetric(vertical: 10)),
                                onPressed: _alertLiveTrainer,
                                icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                                label: const Text('Alert Live Trainer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          ],
                        ]),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))]),
          child: SafeArea(
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Message ${_coach.name}...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _sendChatMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFF00897B),
                child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: _sendChatMessage),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── TROPHY ROOM TAB ────────────────────────────────────────────────────────
  static const _dailyTiers = [1, 3, 5];
  static const _weeklyTiers = [2, 5, 10];
  static const _monthlyTiers = [4, 12, 24];
  static const _streakTiers = [3, 7, 30];

  Map<String, dynamic> _computeTrophyStats() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: todayStart.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final todayCount = _completionTimestamps.where((t) => !t.isBefore(todayStart)).length;
    final weekCount = _completionTimestamps.where((t) => !t.isBefore(weekStart)).length;
    final monthCount = _completionTimestamps.where((t) => !t.isBefore(monthStart)).length;

    final daysWithWorkout = _completionTimestamps.map((t) => DateTime(t.year, t.month, t.day)).toSet();
    int streak = 0;
    DateTime cursor = todayStart;
    while (daysWithWorkout.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return {'today': todayCount, 'week': weekCount, 'month': monthCount, 'streak': streak};
  }

  int _tierFor(int value, List<int> tiers) {
    if (value >= tiers[2]) return 3;
    if (value >= tiers[1]) return 2;
    if (value >= tiers[0]) return 1;
    return 0;
  }

  Widget _buildTrophyRoomView() {
    final stats = _computeTrophyStats();
    final dailyTier = _tierFor(stats['today'], _dailyTiers);
    final weeklyTier = _tierFor(stats['week'], _weeklyTiers);
    final monthlyTier = _tierFor(stats['month'], _monthlyTiers);
    final streakTier = _tierFor(stats['streak'], _streakTiers);

    return Scaffold(
      appBar: AppBar(title: const Text('Trophy Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF00897B)),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 24),
          Text('$_completedWorkoutsCount', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF00897B))),
          const Text('Total Workouts Completed', style: TextStyle(fontSize: 14, color: Colors.grey)),

          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              const Icon(Icons.military_tech, size: 18, color: Color(0xFF00897B)),
              const SizedBox(width: 8),
              const Text('Your Trophies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                _trophyCard('Daily', '🔥', dailyTier, stats['today'], _dailyTiers, 'session${stats['today'] == 1 ? '' : 's'} today'),
                _trophyCard('Weekly', '⚡', weeklyTier, stats['week'], _weeklyTiers, 'this week'),
                _trophyCard('Monthly', '🏆', monthlyTier, stats['month'], _monthlyTiers, 'this month'),
                _trophyCard('Streak', '🌟', streakTier, stats['streak'], _streakTiers, 'day streak'),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              _statRow(Icons.favorite, 'Self-Care Points', '$_bodyListenerFlagsCount'),
              _statRow(Icons.check_circle, 'Total Sessions', '$_totalCheckInsCount'),
              _statRow(Icons.timer, 'Current Plan', widget.sub.planLabel),
              _statRow(Icons.hourglass_bottom, 'Access Remaining', widget.sub.daysRemaining),
            ]),
          ),

          const SizedBox(height: 28),
          if (_completedWorkoutsCount > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade200)),
              child: Text(
                '"${_coach.name} says: Every completed session is a promise you made and kept to yourself. That\'s integrity in action."',
                textAlign: TextAlign.center,
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, height: 1.5),
              ),
            ),
          if (_feedbackHistory.isNotEmpty) ...[
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [
                const Icon(Icons.history, size: 18, color: Color(0xFF00897B)),
                const SizedBox(width: 8),
                const Text('Recent Session Feedback', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ]),
            ),
            const SizedBox(height: 12),
            ..._feedbackHistory.take(5).map(_feedbackHistoryCard),
          ],
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _trophyCard(String label, String emoji, int tier, int value, List<int> tiers, String unitLabel) {
    final tierMeta = [
      {'name': 'Locked', 'color': Colors.grey.shade400, 'bg': Colors.grey.shade100},
      {'name': 'Bronze', 'color': const Color(0xFFB87333), 'bg': const Color(0xFFFBEEE0)},
      {'name': 'Silver', 'color': const Color(0xFF9AA5B1), 'bg': const Color(0xFFEFF2F5)},
      {'name': 'Gold', 'color': const Color(0xFFD4A017), 'bg': const Color(0xFFFFF6DD)},
    ][tier];

    final nextTierTarget = tier < 3 ? tiers[tier] : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tierMeta['bg'] as Color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (tierMeta['color'] as Color).withOpacity(tier == 0 ? 0.25 : 0.5), width: tier == 3 ? 2 : 1.4),
        boxShadow: tier == 3 ? [BoxShadow(color: (tierMeta['color'] as Color).withOpacity(0.35), blurRadius: 12, spreadRadius: 1)] : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Opacity(opacity: tier == 0 ? 0.35 : 1, child: Text(emoji, style: const TextStyle(fontSize: 26))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: (tierMeta['color'] as Color).withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
            child: Text(tierMeta['name'] as String, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: tierMeta['color'] as Color, letterSpacing: 0.4)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(
          nextTierTarget != null ? '$value / $nextTierTarget $unitLabel' : '$value $unitLabel',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: nextTierTarget != null ? (value / nextTierTarget).clamp(0.0, 1.0) : 1.0,
            minHeight: 5,
            backgroundColor: (tierMeta['color'] as Color).withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation(tierMeta['color'] as Color),
          ),
        ),
      ]),
    );
  }

  Widget _feedbackHistoryCard(Map<String, dynamic> entry) {
    final rating = entry['rating'] as int? ?? 0;
    final tags = List<String>.from(entry['tags'] as List? ?? []);
    final note = entry['note'] as String? ?? '';
    final activity = entry['activity'] as String? ?? '';
    final time = entry['time'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(activity, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ]),
        if (rating > 0) ...[
          const SizedBox(height: 6),
          Row(children: List.generate(5, (i) => Icon(
            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 16,
            color: i < rating ? Colors.amber.shade600 : Colors.grey.shade300,
          ))),
        ],
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFF00897B).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Text(t, style: const TextStyle(fontSize: 10, color: Color(0xFF00897B), fontWeight: FontWeight.bold)),
            )).toList(),
          ),
        ],
        if (note.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('"$note"', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic, height: 1.4)),
        ],
      ]),
    );
  }

  Widget _statRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF00897B), size: 18),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ]),
    );
  }

  // ── ACCOUNT TAB ────────────────────────────────────────────────────────────
  void _openAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Choose Your Avatar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: _avatarOptions.map((emoji) {
              final selected = emoji == _profileEmoji;
              return GestureDetector(
                onTap: () {
                  setState(() => _profileEmoji = emoji);
                  _firestoreService.updateProfileEmoji(emoji);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? _coach.accentColor.withOpacity(0.15) : Colors.grey.shade100,
                    border: Border.all(color: selected ? _coach.accentColor : Colors.grey.shade300, width: selected ? 2 : 1),
                  ),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('You can sign back in anytime with your email and password.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    // NOTE: call AuthService().signOut() here — _RootRouter's authStateChanges
    // listener will automatically route back to AuthScreen once signed out.
  }

  Widget _buildAccountView() {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF00897B)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Column(children: [
              GestureDetector(
                onTap: _openAvatarPicker,
                child: Stack(children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [_coach.accentColor, _coach.accentColor.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      boxShadow: [BoxShadow(color: _coach.accentColor.withOpacity(0.3), blurRadius: 16, spreadRadius: 1)],
                    ),
                    child: Center(child: Text(_profileEmoji, style: const TextStyle(fontSize: 44))),
                  ),
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: const Color(0xFF00897B), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.edit, color: Colors.white, size: 14),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              Text('Your GetFit4Me Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey.shade800)),
              const SizedBox(height: 2),
              Text('Tap your avatar to change it', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ]),
          ),

          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00897B), Color(0xFF26A69A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ACTIVE PLAN', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(widget.sub.planLabel, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(widget.sub.daysRemaining, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF00897B))),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaywallScreen(sub: widget.sub))),
              child: const Text('Change Plan', style: TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 28),
          const Text('Switch Coach', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ...kCoaches.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            final selected = i == _activeCoachIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: selected ? c.accentColor.withOpacity(0.08) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? c.accentColor : Colors.grey.shade200, width: selected ? 2 : 1),
              ),
              child: ListTile(
                leading: Text(c.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(c.specialty, style: const TextStyle(fontSize: 11)),
                trailing: selected ? Icon(Icons.check_circle, color: c.accentColor) : null,
                onTap: () => setState(() => _activeCoachIndex = i),
              ),
            );
          }),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              onPressed: _signOut,
              icon: const Icon(Icons.logout, color: Colors.red, size: 18),
              label: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}
