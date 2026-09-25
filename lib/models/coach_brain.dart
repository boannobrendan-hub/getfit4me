import 'dart:math';
import 'coach.dart';

class CoachReply {
  final String text;
  final bool isUrgent;
  const CoachReply({required this.text, this.isUrgent = false});
}

/// Offline, local, topic-based chatbot — no AI API calls. Routes user
/// messages to one of several dozen topics via keyword matching, with a
/// dedicated safety-escalation path for anything resembling a medical
/// emergency, severe distress, or crisis. Ported from the DartPad
/// prototype's CoachBrain class.
class CoachBrain {
  String? _lastTopic;
  final Map<String, String> _lastVariant = {};
  final Random _rand = Random();

  // ── Safety keyword tiers (checked in priority order) ─────────────────────
  static const List<String> _crisisPhrases = [
    'kill myself', 'want to die', 'suicide', 'suicidal', 'end my life',
    'not worth living', "don't want to be here", 'no reason to live',
    'better off dead', 'hurt myself', 'self harm', 'self-harm',
    'cutting myself', 'ending it all', 'cant go on', "can't go on",
    'give up on life', 'no point anymore', 'tired of living',
    'planning to die', 'overdose on purpose', 'want to disappear forever',
    'life is not worth it', 'nothing matters anymore', 'i want to end it',
    'thinking about suicide', 'thoughts of suicide', 'harm myself',
    'wish i was dead',
  ];

  static const List<String> _severeDistressPhrases = [
    'chest pain', 'chest hurts', 'tight chest', 'crushing pain in my chest',
    'cant breathe', "can't breathe", 'trouble breathing', 'shortness of breath',
    'gasping for air', 'face drooping', 'arm is numb', 'slurred speech',
    'sudden confusion', 'sudden numbness', 'sudden weakness', 'vision loss',
    'severe headache', 'worst headache of my life', 'fainted', 'passed out',
    'losing consciousness', 'throat closing', 'lips swelling',
    'swelling of my face', 'hives all over', 'severe allergic reaction',
    'anaphylaxis', 'cant feel my', "can't feel my", 'irregular heartbeat',
    'heart racing uncontrollably', 'severe dizziness', 'cant stand up',
    "can't stand up", 'blue lips', 'choking', 'seizure', 'convulsing',
    'unresponsive', 'severe bleeding', 'wont stop bleeding', "won't stop bleeding",
    'blood everywhere', 'broke my', 'compound fracture', 'bone sticking out',
    'severely burned', 'electric shock', 'electrocuted', 'heat stroke',
    'extremely high fever', 'cant keep anything down', "can't keep anything down",
    'severe abdominal pain', 'stabbing pain', 'pressure in my chest',
    'numbness on one side', 'difficulty speaking', 'room is spinning badly',
    'cold sweat and chest', 'pain radiating down my arm',
    'pain radiating to my jaw', 'severe asthma attack', 'inhaler not working',
    'turning blue', 'unconscious', 'collapsed', 'cant wake up', "can't wake up",
    'overdosed', 'took too many pills', 'poisoned', 'snake bite',
    'allergic reaction is getting worse', 'throat is closing',
    'severe chest tightness', 'heart attack', 'stroke symptoms',
    'paralyzed on one side', "can't move my arm", "can't move my leg",
    'severe head injury', 'hit my head hard', 'knocked unconscious',
    'deep cut', 'gushing blood', 'broken bone visible', 'limb at wrong angle',
    'severe burn', 'third degree burn', 'cant feel my legs', "can't feel my legs",
    'spinal injury', 'neck injury', 'fell from a height', 'car accident',
    'crushed', 'impaled', 'severe trauma', 'losing a lot of blood',
    'going into shock', 'pale and clammy', 'extremely weak suddenly',
    'severe dehydration', 'high fever and confusion', 'stiff neck and fever',
    'rash that wont go away', 'difficulty swallowing suddenly',
    'sudden severe pain', 'worst pain of my life', 'cant catch my breath',
    "can't catch my breath", 'wheezing badly', 'lips turning blue',
    'fingers turning blue', 'severe swelling',
  ];

  static const List<String> _emergencyPhrases = [
    'fracture', 'broken bone', 'broke my arm', 'broke my leg', 'broke my back',
    'broke my wrist', 'broke my ankle', 'compound fracture',
    'bleeding heavily', 'bleeding a lot', 'wont stop bleeding', "won't stop bleeding",
    'deep wound', 'gash', 'stitches needed', 'heart attack', 'cardiac arrest',
    'anaphylactic', 'anaphylaxis', 'allergic reaction', 'epipen',
    'stroke', 'face is drooping', 'one side of my body', 'seizure', 'seizing',
    'convulsion', 'unconscious', 'unresponsive', 'fainting', 'fainted',
    'passed out', 'heat stroke', 'heat exhaustion severe', 'hyperthermia',
    'hypothermia', 'frostbite', 'overdose', 'took too many', 'poisoning',
    'electric shock', 'electrocution', 'drowning', 'cant be woken',
    "can't be woken", 'not breathing', 'no pulse', 'severe trauma',
    'major injury', 'emergency', 'call 911', 'need an ambulance',
    'life threatening', 'critical condition',
  ];

  static const List<String> _dismissiveAfterEmergency = [
    "i'll keep going", 'ill keep going', "i'm fine", 'im fine',
    'just ignore it', "it's fine", 'its fine', 'keep going anyway',
    'push through it', "i'll push through", 'never mind', 'forget it',
    "it's nothing", 'its nothing', "i don't care", "i'll just continue",
  ];

  static const Map<String, List<String>> _keywordMap = {
    'crisis': _crisisPhrases,
    'severeDistress': _severeDistressPhrases,
    'emergency': _emergencyPhrases,
  };

  /// Main entry point — pass the user's raw message and the active coach;
  /// returns a CoachReply with the appropriate response and an isUrgent
  /// flag the UI can use to show the "Alert Live Trainer" button.
  CoachReply respond(String message, Coach coach) {
    final lower = message.toLowerCase().trim();

    // Dismissive follow-up after a recent emergency-tier message routes
    // back into the emergency-follow-up topic rather than letting the
    // conversation casually move on.
    if (_lastTopic != null &&
        ['emergency', 'severeDistress', 'crisis'].contains(_lastTopic) &&
        _dismissiveAfterEmergency.any((p) => lower.contains(p))) {
      _lastTopic = 'emergencyFollowup';
      return CoachReply(text: _emergencyFollowupMessage(coach), isUrgent: true);
    }

    // Priority-ordered safety tier checks.
    for (final entry in _keywordMap.entries) {
      if (entry.value.any((phrase) => lower.contains(phrase))) {
        _lastTopic = entry.key;
        return CoachReply(text: _safetyMessage(entry.key, coach), isUrgent: true);
      }
    }

    // Pain / tired / stiff topic routing (maps to Coach.responses keys).
    if (lower.contains('pain') || lower.contains('hurt') || lower.contains('sore') || lower.contains('ache')) {
      _lastTopic = 'pain';
      return CoachReply(text: coach.responses['pain'] ?? coach.responses['default']!, isUrgent: false);
    }
    if (lower.contains('tired') || lower.contains('exhausted') || lower.contains('fatigue') || lower.contains('no energy')) {
      _lastTopic = 'tired';
      return CoachReply(text: coach.responses['tired'] ?? coach.responses['default']!, isUrgent: false);
    }
    if (lower.contains('stiff') || lower.contains('tight') || lower.contains('cant move') || lower.contains("can't move")) {
      _lastTopic = 'stiff';
      return CoachReply(text: coach.responses['stiff'] ?? coach.responses['default']!, isUrgent: false);
    }

    _lastTopic = 'default';
    return CoachReply(text: coach.responses['default']!, isUrgent: false);
  }

  String _safetyMessage(String tier, Coach coach) {
    switch (tier) {
      case 'crisis':
        return "${coach.name} here. I'm really glad you told me this, and I want you to know you don't have to go through this alone. "
            "Please reach out right now to the 988 Suicide & Crisis Lifeline — call or text 988, available 24/7, free and confidential. "
            "If you're outside the US, please contact your local emergency services or a crisis line in your country. "
            "I'm not equipped to provide the support you need right now, but real help is available immediately. Please reach out.";
      case 'severeDistress':
        return "${coach.name} here. What you're describing sounds serious. Please stop exercising immediately and call your local emergency number "
            "(911 in the US) right now, or have someone nearby call for you. This app cannot provide emergency medical care — please get real help immediately.";
      case 'emergency':
        return "${coach.name} here. Please stop what you're doing right now. If this feels like a medical emergency, call 911 (or your local emergency number) immediately, "
            "or have someone get you to urgent care. I want to make sure you're safe — please prioritize getting real medical help right now.";
      default:
        return coach.responses['default']!;
    }
  }

  String _emergencyFollowupMessage(Coach coach) {
    return "${coach.name} here — I want to gently push back on that. What you described a moment ago sounds like it could be serious, and "
        "minimizing it isn't the safe move here. Please don't continue exercising. If you're at all unsure, calling 911 or a healthcare provider "
        "is the right call, not a wasted call. Your safety matters more than finishing today's session.";
  }

  void reset() {
    _lastTopic = null;
    _lastVariant.clear();
  }
}
