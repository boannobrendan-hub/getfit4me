import 'package:flutter/material.dart';

class Coach {
  final String name;
  final String emoji;
  final String specialty;
  final String tagline;
  final Color accentColor;
  final Map<String, String> responses;

  const Coach({
    required this.name,
    required this.emoji,
    required this.specialty,
    required this.tagline,
    required this.accentColor,
    required this.responses,
  });
}

final List<Coach> kCoaches = [
  Coach(
    name: 'Brendan',
    emoji: '🔥',
    specialty: 'Wellness Coaching & Strength Training',
    tagline: 'Build strength. Rebuild yourself.',
    accentColor: const Color(0xFFE65100),
    responses: {
      'pain': "Brendan here — and first: thank you for telling me. Stopping the moment something feels wrong isn't weakness, that's exactly what a smart, strong athlete does. Let's note it down, ease off, and I'll have a modified plan ready. You're not behind, you're being smart.",
      'tired': "Hey, it's Brendan. Real talk — your body builds strength during rest, not just during the workout. Today's a recovery-priority day. Hydrate, eat well, and check back in with me in a couple hours. We push hard again when you're actually ready.",
      'stiff': "Brendan here. Stiffness before we start just means we warm up a little longer — totally normal, nothing to worry about. Let's do some gentle mobility work first. Ready when you are.",
      'default': "BRENDAN IN THE BUILDING! 🔥 Let's talk about where you're at today so I can make sure your session actually builds something real. What's on your mind?",
    },
  ),
  Coach(
    name: 'Justin',
    emoji: '💙',
    specialty: 'Conditioning & Endurance',
    tagline: 'Condition your body. Condition your mind.',
    accentColor: const Color(0xFF1565C0),
    responses: {
      'pain': "Justin here. Thank you for sharing that — I want to make sure we approach today thoughtfully. Let's pause, note exactly where it hurts, and adjust your conditioning plan so we're working with your body, not against it.",
      'tired': "Hey, it's Justin. I hear you on the fatigue — conditioning gains come from consistent, sustainable effort, not from grinding through exhaustion. Let's do a lighter session today and build back up from there.",
      'stiff': "Justin here. Stiffness is common, especially as your body adapts to new conditioning demands. Let's spend a little extra time on mobility before we get into the main session.",
      'default': "Justin checking in 💙. Conditioning is a long game — let's talk through where you're at today so your plan actually reflects that. What's on your mind?",
    },
  ),
  Coach(
    name: 'Cameron',
    emoji: '⚡',
    specialty: 'Power Training & Strength',
    tagline: 'Unlock power. Dominate every rep.',
    accentColor: const Color(0xFF6A1B9A),
    responses: {
      'pain': "Cameron here — and first: GOOD CALL stopping. The athletes who last longest are the ones who respect their signals. You just did the smart thing. Let's document this, let your body settle, and I'll have a modified power-safe plan ready.",
      'tired': "Cameron. Real talk — recovery is where power is actually built. Today is a high-value recovery day. Hydrate, eat real food, and let me know how you feel in two hours. We go hard again when your body says go.",
      'stiff': "Cameron here! Stiffness before a power session just means we need a longer activation warm-up — totally normal. You ready to activate?",
      'default': "CAMERON IS IN THE BUILDING! ⚡ Let's talk about where you're at today so I can make sure every rep you do is actually building something real. What's on your mind?",
    },
  ),
  Coach(
    name: 'Bell',
    emoji: '🌊',
    specialty: 'Recovery & Endurance',
    tagline: 'Recover smart. Endure longer.',
    accentColor: const Color(0xFF00ACC1),
    responses: {
      'pain': "Bell here. Thank you for telling me — pain is information, and recovery starts with listening to it. Let's ease off completely for now, ice if it helps, and reassess once things settle.",
      'tired': "Bell checking in. Fatigue is your body asking for recovery time, plain and simple — it's not weakness, it's biology. Today calls for a gentle, restorative session instead of pushing volume.",
      'stiff': "That stiffness is really common, especially as your body adapts to new training demands. A slow, gentle mobility flow helps circulation get to the area and supports recovery.",
      'default': "Bell here 🌊. Recovery and endurance are two sides of the same coin — the better you recover, the further you can go. What's on your mind today?",
    },
  ),
];
