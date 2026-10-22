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

    // ── Quick-reply chip topics ───────────────────────────────────────────────
    if (lower.contains('build my next workout') || lower.contains('next workout') || lower.contains('plan my workout') || lower.contains('what workout')) {
      _lastTopic = 'buildWorkout';
      return CoachReply(text: _quickReply('buildWorkout', coach));
    }
    if (lower.contains('feeling sore') || lower.contains('i\'m sore') || lower.contains('im sore') || lower.contains('so sore')) {
      _lastTopic = 'sore';
      return CoachReply(text: _quickReply('sore', coach));
    }
    if (lower.contains('make it harder') || lower.contains('too easy') || lower.contains('harder next') || lower.contains('increase the difficulty')) {
      _lastTopic = 'harder';
      return CoachReply(text: _quickReply('harder', coach));
    }
    if (lower.contains('only have 20') || lower.contains('short on time') || lower.contains('not much time') || lower.contains('20 minutes') || lower.contains('quick workout')) {
      _lastTopic = 'shortTime';
      return CoachReply(text: _quickReply('shortTime', coach));
    }
    if (lower.contains('what should i eat') || lower.contains('nutrition') || lower.contains('food today') || lower.contains('diet') || lower.contains('meal')) {
      _lastTopic = 'nutrition';
      return CoachReply(text: _quickReply('nutrition', coach));
    }
    if (lower.contains('traveling') || lower.contains('travelling') || lower.contains('on the road') || lower.contains('hotel') || lower.contains('no gym')) {
      _lastTopic = 'travel';
      return CoachReply(text: _quickReply('travel', coach));
    }
    if (lower.contains('joint pain') || lower.contains('knee') || lower.contains('hip pain') || lower.contains('shoulder pain') || lower.contains('joint')) {
      _lastTopic = 'jointPain';
      return CoachReply(text: _quickReply('jointPain', coach));
    }
    if (lower.contains('motivate') || lower.contains('motivation') || lower.contains('inspire') || lower.contains('pump me up') || lower.contains('hype')) {
      _lastTopic = 'motivate';
      return CoachReply(text: _quickReply('motivate', coach));
    }

    // ── Standard keyword topics ───────────────────────────────────────────────
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

  String _quickReply(String topic, Coach coach) {
    final name = coach.name;
    switch (topic) {
      case 'buildWorkout':
        return [
          "$name here! Head to the Workout tab and pick your sport or focus area — I'll line up a full 30-minute circuit built specifically for you. Let's get after it! 💪",
          "Love the energy! Tap the Workout tab, choose your category, and your next session is ready to go. I built it around your goals — no guessing needed. 🔥",
          "$name on it. Jump into the Workout tab and pick what you're training today. I've got warm-up, main circuit, and cool-down all dialed in for you.",
        ][_rand.nextInt(3)];

      case 'sore':
        return [
          "$name here — soreness means you put in real work! Today let's do a light recovery session. Prioritize mobility, foam rolling, and keep hydration up. You earned the rest. 💪",
          "Soreness is progress, not a problem. $name recommends: 10 min light walk, gentle stretching on the sore areas, and plenty of water. Active recovery is still recovery!",
          "$name says: listen to your body today. A 10–15 min cool-down flow or a walk goes a long way. Tomorrow you'll come back stronger. 🙏",
        ][_rand.nextInt(3)];

      case 'harder':
        return [
          "$name heard you — next session I'm turning it up. Expect shorter rest periods, heavier compound movements, and I'll push your rep count higher. Bring that energy! 🔥",
          "Challenge accepted. $name is adjusting your next circuit — more intensity, less rest, more grit. Make sure your sleep and nutrition are locked in too.",
          "You want harder? $name delivers. Next session: drop rest windows to 30 seconds, go heavier on your main lifts, and we add a finisher at the end. Let's go! 💥",
        ][_rand.nextInt(3)];

      case 'shortTime':
        return [
          "$name here — 20 minutes is plenty. Head to the Workout tab, pick your focus, and we'll hit a tight HIIT-style circuit: big compound moves, minimal rest. Zero filler. ⏱️",
          "No problem — $name specializes in efficiency. 20 minutes, full body, high output. Warm up for 3, go hard for 14, cool down for 3. Tap Workout and let's move.",
          "$name says: short on time = higher intensity. We'll superset the main lifts, cut rest to 20 seconds, and you'll be done and dripping in 20 flat. Let's go! 💪",
        ][_rand.nextInt(3)];

      case 'nutrition':
        return [
          "$name here! Focus on protein at every meal today — aim for 0.7–1g per pound of bodyweight. Lean meat, eggs, Greek yogurt. Pair with complex carbs around your workout and stay hydrated. 🥗",
          "Post-workout nutrition is key. $name recommends: 30–50g protein within 90 minutes of training, a fistful of carbs, and greens where you can. Keep it simple and consistent.",
          "Fuel smart today. $name's formula: protein + veggies at every meal, carbs timed around workouts, and cut the processed stuff. Water first — most people are under-hydrated. 💧",
        ][_rand.nextInt(3)];

      case 'travel':
        return [
          "$name here — no gym, no problem. Bodyweight circuits are your best friend on the road: push-ups, squats, lunges, planks. Hit the Workout tab and pick a bodyweight category. ✈️",
          "Traveling doesn't stop the grind. $name's travel protocol: 20-min hotel room circuit, 8–10 exercises, no equipment needed. Tap Workout → pick your focus. I've got you covered.",
          "$name says: use what you have. Stairs, resistance bands if you packed them, or a park nearby. A 20-min bodyweight session keeps your momentum going. No excuses! 💪",
        ][_rand.nextInt(3)];

      case 'jointPain':
        return [
          "$name here — joint pain is your body talking, so let's listen. Skip high-impact movements today. We'll work around it: upper body if it's lower, seated or banded work if needed. Tell me which joint and I'll adjust.",
          "Let's be smart about this. $name's rule: train around pain, never through it. Swap impact for resistance, reduce range of motion if needed, and ice it after. Which joint is bothering you? 🦵",
          "$name here — joint discomfort is common but we don't ignore it. Today focus on low-impact work, stay in a pain-free range, and prioritize the cool-down. If it persists more than a few days, see a physio.",
        ][_rand.nextInt(3)];

      case 'motivate':
        return [
          "LET'S GO! $name here — you showed up today and that's already half the battle. Most people don't even start. You're building something real, one session at a time. Now GO GET IT! 🚀🔥",
          "$name's message: Champions aren't made on the days they feel great — they're made on the days they don't. You're here. That's enough. Now let's make it count. 💪",
          "You want fire? $name's got fire. Every rep you do today is an investment in the version of you that's coming. That person is worth showing up for. LET'S WORK! 🔥🚀",
        ][_rand.nextInt(3)];

      default:
        return coach.responses['default']!;
    }
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