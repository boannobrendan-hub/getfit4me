/// Sport-performance exercise matrix (10 sports). Same data as the
/// DartPad prototype's `_sportMatrix`.
final Map<String, Map<String, dynamic>> kSportMatrix = {
  'Basketball': {
    'flag': '🏀 Explosive Power & Agility Protocol Active',
    'avoid': 'Untaped ankle rolls on hard cuts, skipping landing mechanics work, ignoring shoulder care after repetitive shooting.',
    'exercises': [
      {'name': '1. Lateral Bound to Stick (Single Leg)', 'target': '45 Sec', 'tip': 'Trains explosive lateral power and landing control for cuts and closeouts.'},
      {'name': '2. Box Jump with Soft Landing', 'target': '45 Sec', 'tip': 'Builds vertical power while reinforcing safe landing mechanics to protect your knees.'},
      {'name': '3. Defensive Slide Shuffles', 'target': '60 Sec', 'tip': 'Improves lateral quickness and hip mobility for staying in front of your matchup.'},
      {'name': '4. Medicine Ball Rotational Throw', 'target': '45 Sec', 'tip': 'Develops core rotational power for shooting and finishing through contact.'},
      {'name': '5. Single-Leg Calf Raises', 'target': '60 Sec', 'tip': 'Builds ankle stability and explosiveness for jumping and quick first steps.'},
    ],
  },
  'Soccer': {
    'flag': '⚽ Multi-Directional Speed Protocol Active',
    'avoid': 'Cold sprints without a dynamic warm-up, neglecting hamstring eccentric work, ignoring groin and adductor strength.',
    'exercises': [
      {'name': '1. Dynamic High Knee + Butt Kick Drill', 'target': '60 Sec', 'tip': 'Primes your hip flexors and hamstrings for sprinting and changes of direction.'},
      {'name': '2. Lateral Cone Shuffles', 'target': '45 Sec', 'tip': 'Sharpens lateral agility for tracking runs and defensive positioning.'},
      {'name': '3. Nordic Hamstring Curl (Assisted)', 'target': '30 Sec', 'tip': 'One of the best exercises for preventing hamstring strains, the most common soccer injury.'},
      {'name': '4. Single-Leg Romanian Deadlift', 'target': '45 Sec', 'tip': 'Builds posterior chain strength and balance for tackles and shots on the run.'},
      {'name': '5. Plank with Shoulder Taps', 'target': '60 Sec', 'tip': 'Core stability that holds up through 90 minutes of changing direction.'},
    ],
  },
  'Running / Track & Field': {
    'flag': '🏃 Aerobic Engine & Stride Efficiency Active',
    'avoid': 'Sudden mileage spikes, ignoring hip and glute strength, ramping up speed work without a proper warm-up.',
    'exercises': [
      {'name': '1. A-Skip Drill', 'target': '45 Sec', 'tip': 'Improves running mechanics, knee drive, and ground contact efficiency.'},
      {'name': '2. Glute Bridge March', 'target': '45 Sec', 'tip': 'Activates glutes to improve hip extension power for every stride.'},
      {'name': '3. Strides (Controlled Acceleration)', 'target': '60 Sec', 'tip': 'Builds top-end speed and turnover without max-effort sprinting risk.'},
      {'name': '4. Single-Leg Calf Raise (Slow Eccentric)', 'target': '45 Sec', 'tip': 'Builds Achilles and calf resilience to handle repetitive impact.'},
      {'name': '5. Core Anti-Rotation Hold', 'target': '60 Sec', 'tip': 'Keeps your trunk stable so energy goes into forward motion, not wasted rotation.'},
    ],
  },
  'Swimming': {
    'flag': '🏊 Shoulder Stability & Rotational Power Active',
    'avoid': 'Excessive volume without scapular control work, ignoring rotator cuff balance, skipping dryland core work.',
    'exercises': [
      {'name': '1. Band Pull-Aparts (Scapular Focus)', 'target': '60 Sec', 'tip': 'Builds the upper back strength that protects your shoulders through thousands of strokes.'},
      {'name': '2. Banded Internal/External Rotation', 'target': '45 Sec', 'tip': "Balances rotator cuff strength to help prevent swimmer's shoulder."},
      {'name': '3. Dolphin Kick Core Holds', 'target': '45 Sec', 'tip': 'Builds the core undulation strength that drives propulsion off every wall.'},
      {'name': '4. Single-Arm Dumbbell Row', 'target': '45 Sec', 'tip': 'Builds the pulling strength that translates directly into stroke power.'},
      {'name': '5. Thoracic Spine Rotation Stretch', 'target': '60 Sec', 'tip': 'Improves the rotational mobility needed for an efficient stroke and breathing.'},
    ],
  },
  'American Football': {
    'flag': '🏈 Contact Power & Tackling Readiness Active',
    'avoid': 'Skipping neck strengthening, untrained landing or falling mechanics, ignoring lateral hip strength for cutting.',
    'exercises': [
      {'name': '1. Sled Push (or Weighted Carry)', 'target': '45 Sec', 'tip': 'Builds the lower-body drive power essential for blocking and tackling.'},
      {'name': '2. Broad Jump to Stick', 'target': '45 Sec', 'tip': 'Trains explosive horizontal power with a controlled landing for first-step burst.'},
      {'name': '3. Neck Isometric Holds (All Directions)', 'target': '60 Sec', 'tip': 'Strengthens the neck muscles that help protect against contact-related injuries.'},
      {'name': '4. Lateral Lunge with Reach', 'target': '45 Sec', 'tip': 'Builds hip strength for cutting, pursuit angles, and lateral contact.'},
      {'name': "5. Farmer's Carry", 'target': '60 Sec', 'tip': 'Grip and core strength that translates to controlling blocks and ball carriers.'},
    ],
  },
  'Tennis': {
    'flag': '🎾 Rotational Power & Court Agility Active',
    'avoid': 'One-sided strength imbalances from dominant-arm overuse, skipping wrist and forearm care, neglecting split-step reaction training.',
    'exercises': [
      {'name': '1. Medicine Ball Rotational Slam', 'target': '45 Sec', 'tip': 'Builds the trunk rotation power behind every serve and groundstroke.'},
      {'name': '2. Lateral Shuffle to Split Step', 'target': '60 Sec', 'tip': 'Trains the reactive footwork that gets you to every ball.'},
      {'name': '3. Wrist Flexor/Extensor Curls (Light)', 'target': '45 Sec', 'tip': 'Builds forearm endurance and helps protect against tennis elbow.'},
      {'name': '4. Single-Leg Lateral Hop', 'target': '45 Sec', 'tip': 'Develops the lateral stability needed for wide groundstrokes and recovery steps.'},
      {'name': '5. Thoracic Rotation with Band', 'target': '60 Sec', 'tip': 'Improves shoulder and spine mobility for a full, fluid swing.'},
    ],
  },
  'Baseball / Softball': {
    'flag': '⚾ Rotational Power & Arm Care Active',
    'avoid': 'Skipping scapular and rotator cuff care, overusing the throwing arm without rest, neglecting hip-shoulder separation drills.',
    'exercises': [
      {'name': '1. Band External Rotation (Throwing Arm)', 'target': '60 Sec', 'tip': 'Protects the rotator cuff that takes repetitive stress with every throw.'},
      {'name': '2. Medicine Ball Rotational Throw', 'target': '45 Sec', 'tip': 'Builds the hip-to-shoulder power transfer behind every swing and throw.'},
      {'name': '3. Lateral Bound (Single Leg)', 'target': '45 Sec', 'tip': 'Develops the explosive push-off needed for stealing bases and first-step quickness.'},
      {'name': '4. Scapular Wall Slides', 'target': '60 Sec', 'tip': 'Improves shoulder blade mechanics for a healthier, more powerful throwing motion.'},
      {'name': '5. Hip-Shoulder Separation Drill', 'target': '45 Sec', 'tip': 'Trains the core disconnect that creates bat speed and throwing velocity.'},
    ],
  },
  'CrossFit / General Strength': {
    'flag': '🏋️ Functional Power & Work Capacity Active',
    'avoid': 'Sacrificing form for speed under fatigue, skipping mobility work, rushing progression on Olympic lift variations.',
    'exercises': [
      {'name': '1. Kettlebell Swing', 'target': '45 Sec', 'tip': 'Builds explosive hip power that transfers to nearly every functional movement.'},
      {'name': '2. Goblet Squat (Tempo)', 'target': '45 Sec', 'tip': 'Reinforces squat mechanics under control before adding speed or load.'},
      {'name': '3. Push-Up to Renegade Row', 'target': '45 Sec', 'tip': 'Combines upper body pressing and pulling with core stability.'},
      {'name': '4. Box Step-Up (Weighted)', 'target': '60 Sec', 'tip': 'Builds unilateral leg strength and power for climbing, jumping, and carrying.'},
      {'name': '5. Hollow Body Hold', 'target': '45 Sec', 'tip': 'The foundational core position behind nearly every gymnastics and lifting movement.'},
    ],
  },
  'Cycling': {
    'flag': '🚴 Sustained Power & Aerobic Threshold Active',
    'avoid': 'Neglecting posterior chain strength, skipping neck and upper back mobility, ignoring core stability for bike handling.',
    'exercises': [
      {'name': '1. Wall Sit (Isometric Quad Hold)', 'target': '60 Sec', 'tip': 'Builds the sustained quad endurance needed for long climbs and time trials.'},
      {'name': '2. Single-Leg Glute Bridge', 'target': '45 Sec', 'tip': 'Strengthens glutes to balance the quad-dominant nature of cycling.'},
      {'name': '3. Plank Hold', 'target': '60 Sec', 'tip': 'Core stability that keeps your power transfer efficient over long rides.'},
      {'name': '4. Thoracic Extension Stretch (Foam Roller)', 'target': '45 Sec', 'tip': 'Counteracts the rounded-back cycling posture and opens up breathing.'},
      {'name': '5. Step-Ups (Moderate Pace)', 'target': '60 Sec', 'tip': 'Builds unilateral leg power and pedal-stroke balance.'},
    ],
  },
  'Combat Sports (Boxing/MMA)': {
    'flag': '🥊 Explosive Power & Conditioning Active',
    'avoid': 'Sparring without a proper warm-up, neglecting neck strengthening, skipping grip and forearm endurance work.',
    'exercises': [
      {'name': '1. Shadow Boxing (High Intensity)', 'target': '60 Sec', 'tip': 'Builds striking conditioning and reinforces technique under fatigue.'},
      {'name': '2. Medicine Ball Rotational Slam', 'target': '45 Sec', 'tip': 'Develops the hip rotation power behind every punch and kick.'},
      {'name': '3. Neck Isometric Holds (All Directions)', 'target': '60 Sec', 'tip': 'Builds the neck strength that helps absorb impact safely.'},
      {'name': '4. Burpee to Squat Jump', 'target': '45 Sec', 'tip': 'Full-body explosive conditioning that mirrors the demands of a fight.'},
      {'name': "5. Farmer's Carry (Grip Focus)", 'target': '60 Sec', 'tip': 'Builds the grip and forearm endurance essential for clinching and grappling.'},
    ],
  },
};

/// Medical-condition exercise matrix (10 conditions). Same data as the
/// DartPad prototype's `_medicalMatrix`.
final Map<String, Map<String, dynamic>> kMedicalMatrix = {
  'Rheumatoid Arthritis': {
    'flag': '🧡 Joint Protection Protocol Active',
    'avoid': 'High impact plyometrics, heavy loaded gripping, extreme end-range stretching.',
    'exercises': [
      {'name': '1. Isometric Wall Sit', 'target': '30 Sec', 'tip': 'Zero joint movement builds quad tracking strength safely.'},
      {'name': '2. Hands-Free Looped Band Rows', 'target': '45 Sec', 'tip': 'Hook band around forearms to keep fingers/wrists relaxed.'},
      {'name': '3. Seated Leg Extensions (Unloaded)', 'target': '60 Sec', 'tip': 'Pumps nourishing synovial fluid into the knees.'},
      {'name': '4. Standing Open-Palm Chest Press', 'target': '45 Sec', 'tip': 'Press against bands without clenching stiff hands.'},
      {'name': '5. Wall Slides (Open Hand)', 'target': '120 Sec', 'tip': 'Relieves morning upper body capsule tightness gently.'},
    ],
  },
  'Osteoporosis': {
    'flag': '💪 Progressive Axial Loading Active',
    'avoid': 'Spinal flexion (crunches, sit-ups), deep spinal twisting, high-impact jumping.',
    'exercises': [
      {'name': '1. Supported Dumbbell Box Squat', 'target': '45 Sec', 'tip': 'Safely applies vertical loads to increase skeletal bone density.'},
      {'name': '2. Standing Single-Leg Balance', 'target': '30 Sec', 'tip': 'Fall prevention drill to minimize fracture risks.'},
      {'name': '3. Standing Dumbbell Overhead Press', 'target': '45 Sec', 'tip': 'Keep your core braced and spine perfectly straight.'},
      {'name': '4. Light Kettlebell Farmer Walks', 'target': '60 Sec', 'tip': 'Improves posture and hip joint stability.'},
      {'name': '5. Banded Face Pulls (High Anchor)', 'target': '45 Sec', 'tip': 'Strengthens rhomboids to prevent kyphosis/rounding.'},
    ],
  },
  'Autoimmune / Fibromyalgia': {
    'flag': '🌿 Central Nervous System Regulated',
    'avoid': 'HIIT training, exhaustive training to failure, rapid explosive shifts.',
    'exercises': [
      {'name': '1. Cat-Cow Mobility Flow', 'target': '120 Sec', 'tip': 'Calms the nervous system and decreases chronic muscle pain.'},
      {'name': '2. Low-Resistance Incline Push-ups', 'target': '45 Sec', 'tip': 'Focus on a calm, rhythmic movement pace.'},
      {'name': '3. Dumbbell Romanian Deadlift (Light)', 'target': '45 Sec', 'tip': 'Hinge safely at the hips to activate hamstrings.'},
      {'name': '4. Seated Band Lat Pulldowns', 'target': '60 Sec', 'tip': 'Keep shoulders relaxed. Do not force tension blocks.'},
      {'name': '5. Diaphragmatic Box Breathing', 'target': '180 Sec', 'tip': 'Flushes cortisol out of the bloodstream.'},
    ],
  },
  'Hypertension / Cardiovascular': {
    'flag': '❤️ Valsalva Prevention Protocol Active',
    'avoid': 'Breath-holding under heavy load, inversion exercises, rapid standing-to-lying changes.',
    'exercises': [
      {'name': '1. Steady-Tempo Seated Cable Rows', 'target': '60 Sec', 'tip': 'Exhale on every exertion. Keep breathing fluid.'},
      {'name': '2. Low-Impact Marching in Place', 'target': '180 Sec', 'tip': 'Keeps heart rate in a safe, monitored aerobic zone.'},
      {'name': '3. Dumbbell Suitcase Carry (Light)', 'target': '60 Sec', 'tip': 'Improves core stability without dangerous spikes in blood pressure.'},
      {'name': '4. Seated Band Chest Flies', 'target': '45 Sec', 'tip': 'Keep movement rhythmic and breathe naturally.'},
      {'name': '5. Supported Step-Ups (Low Box)', 'target': '60 Sec', 'tip': 'Use a railing or wall to maintain perfect balance.'},
    ],
  },
  'Chronic Lower Back Pain': {
    'flag': '🛡️ Lumbar Spine Neutral Bracing Engaged',
    'avoid': 'Heavy deadlifts, loaded spinal rounding, unbraced twisting.',
    'exercises': [
      {'name': '1. Bird-Dog Stabilization', 'target': '60 Sec', 'tip': 'Brace your abdominal wall like a corset.'},
      {'name': '2. Unloaded Glute Bridges', 'target': '45 Sec', 'tip': 'Activates glutes to remove pressure from vertebrae.'},
      {'name': '3. Core Deadbug (Alternating)', 'target': '60 Sec', 'tip': 'Keep your lower back pressed flat against the floor.'},
      {'name': '4. Planks from Knees', 'target': '30 Sec', 'tip': 'Builds deep transverse abdominal endurance safely.'},
      {'name': '5. Standing Hip Hinges (Wall Touch)', 'target': '45 Sec', 'tip': 'Teaches hamstring tracking without spinal load.'},
    ],
  },
  'Type 2 Diabetes': {
    'flag': '🩸 Insulin Sensitivity Optimization Engaged',
    'avoid': 'Exercising during blood sugar extremes without a testing snack.',
    'exercises': [
      {'name': '1. Moderate Resistance Leg Press', 'target': '60 Sec', 'tip': 'Large muscle recruitment maximizes systemic glucose uptake.'},
      {'name': '2. Brisk Incline Treadmill Walk', 'target': '900 Sec', 'tip': 'Directly increases long-term cellular insulin sensitivity.'},
      {'name': '3. Dumbbell Goblet Squats (Light)', 'target': '45 Sec', 'tip': 'Keep movement controlled to burn glycogen reservoirs.'},
      {'name': '4. Dumbbell Floor Press', 'target': '45 Sec', 'tip': 'Floor stops deep shoulder extension for safety.'},
      {'name': '5. Standing Lat Band Pulldowns', 'target': '60 Sec', 'tip': 'Higher reps assist with peripheral glucose clearance.'},
    ],
  },
  'Pre-Natal (Trimester 2 & 3)': {
    'flag': '🤰 Vena Cava Compression Avoidance Engaged',
    'avoid': 'Supine positions (lying flat on back), heavy bracing, high core heat indices.',
    'exercises': [
      {'name': '1. Standing Bicep Curl to Press', 'target': '45 Sec', 'tip': 'Maintain an upright posture. Do not arch lower back.'},
      {'name': '2. Stability Ball Pelvic Tilts', 'target': '120 Sec', 'tip': 'Relieves lumbar and pelvic girdle pressure.'},
      {'name': '3. Bodyweight Sumo Squat (Wide)', 'target': '45 Sec', 'tip': 'Opens hips and strengthens pelvic floor safely.'},
      {'name': '4. Seated Cable Face Pulls', 'target': '45 Sec', 'tip': 'Combats shifts in center of gravity.'},
      {'name': '5. Side-Lying Clamshells', 'target': '60 Sec', 'tip': 'Stabilizes lateral hip compartments for labor mechanics.'},
    ],
  },
  'Asthma / COPD': {
    'flag': '🫁 Pulmonary Ramped Integration Active',
    'avoid': 'Cold dry training areas, sudden intensity shifts without extensions.',
    'exercises': [
      {'name': '1. Extended Ramped Warm-up Walk', 'target': '600 Sec', 'tip': 'Gently conditions lung tissue to avoid sudden bronchospasms.'},
      {'name': '2. Controlled Tempo Cable Rows', 'target': '45 Sec', 'tip': 'Sync your breathing pattern directly with the movement.'},
      {'name': '3. Seated Dumbbell Shoulder Press', 'target': '45 Sec', 'tip': 'Keep chest proud to maximize lung capacity expansion.'},
      {'name': '4. Low-Impact Recumbent Cycling', 'target': '480 Sec', 'tip': 'Easy aerobic conditioning that lets you breathe smoothly.'},
      {'name': '5. Pursed-Lip Breathing Recovery', 'target': '120 Sec', 'tip': 'Inhale through nose, exhale slowly through pursed lips.'},
    ],
  },
  'Osteoarthritis (Knee/Hip)': {
    'flag': '🦵 Articular Lubrication Protocol Engaged',
    'avoid': 'Jumping, running, deep unassisted knee bends.',
    'exercises': [
      {'name': '1. Straight Leg Raises (Floor)', 'target': '60 Sec', 'tip': 'Strengthens quads to reduce knee joint pressure.'},
      {'name': '2. Low-Resistance Stationary Bike', 'target': '600 Sec', 'tip': 'Lubricates joint spaces to ease morning arthritis stiffness.'},
      {'name': '3. Clamshells with Light Band', 'target': '45 Sec', 'tip': 'Builds gluteus medius to stop knee valgus collapse.'},
      {'name': '4. Standing Hip Abductions', 'target': '45 Sec', 'tip': 'Hold onto a wall or sturdy chair for safety.'},
      {'name': '5. Seated Calf Raises', 'target': '60 Sec', 'tip': 'Pumps lower extremity circulation without weight stress.'},
    ],
  },
  'Post-Stroke / Neuro Coordination': {
    'flag': '🧠 Neurological Plasticity Protocol Active',
    'avoid': 'Unassisted rapid directional tracking, unbraced standing weights.',
    'exercises': [
      {'name': '1. Seated Foot Taps to Spatial Targets', 'target': '60 Sec', 'tip': 'Rewires motor control signaling paths.'},
      {'name': '2. Wall-Supported Side Stepping', 'target': '60 Sec', 'tip': 'Keeps core stable while building lateral confidence.'},
      {'name': '3. Seated Alternating Knee Drives', 'target': '45 Sec', 'tip': 'Builds core and hip flexor coordination.'},
      {'name': '4. Contralateral Reach (Seated)', 'target': '60 Sec', 'tip': 'Reach right hand to left knee to cross brain hemispheres.'},
      {'name': '5. Supported Heel Raises (Wall Hold)', 'target': '45 Sec', 'tip': 'Focus on a slow, controlled lowering phase.'},
    ],
  },
};

/// Tag-based cross-reference engine data — see CrossReferenceEngine for
/// the matching logic that uses these.
const Map<String, List<String>> kSportDemandTags = {
  'Basketball': ['impact', 'cardio', 'explosive', 'directionChange'],
  'Soccer': ['cardio', 'explosive', 'directionChange', 'endurance'],
  'Running / Track & Field': ['cardio', 'impact', 'endurance'],
  'Swimming': ['cardio', 'shoulderLoad', 'endurance'],
  'American Football': ['impact', 'explosive', 'contact', 'directionChange'],
  'Tennis': ['cardio', 'explosive', 'directionChange', 'shoulderLoad'],
  'Baseball / Softball': ['explosive', 'shoulderLoad', 'rotational'],
  'CrossFit / General Strength': ['heavyLoad', 'explosive', 'cardio'],
  'Cycling': ['cardio', 'endurance', 'lowImpact'],
  'Combat Sports (Boxing/MMA)': ['impact', 'contact', 'explosive', 'cardio'],
};

const Map<String, List<String>> kConditionSensitivityTags = {
  'Rheumatoid Arthritis': ['jointSensitive', 'gripSensitive', 'flareRisk'],
  'Osteoporosis': ['fractureRisk', 'noSpinalFlexion', 'noHighImpactBalance'],
  'Autoimmune / Fibromyalgia': ['fatigueSensitive', 'flareRisk', 'avoidHIIT'],
  'Hypertension / Cardiovascular': ['cardioCaution', 'noBreathHold', 'gradualIntensity'],
  'Chronic Lower Back Pain': ['spineSensitive', 'noLoadedTwisting', 'coreBracingNeeded'],
  'Type 2 Diabetes': ['glucoseAware', 'cardioBeneficial', 'extremityCare'],
  'Pre-Natal (Trimester 2 & 3)': ['noSupine', 'coreHeatCaution', 'balanceShift'],
  'Asthma / COPD': ['cardioCaution', 'breathingPaced', 'extendedWarmup'],
  'Osteoarthritis (Knee/Hip)': ['jointSensitive', 'lowImpactPreferred', 'noDeepFlexion'],
  'Post-Stroke / Neuro Coordination': ['balanceShift', 'coordinationFocus', 'unilateralCaution'],
};
