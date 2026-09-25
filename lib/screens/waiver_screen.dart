import 'package:flutter/material.dart';

// NOTE: This is honest, plain-language placeholder copy for a production
// build candidate. Have it reviewed and finalized by a lawyer familiar
// with health/fitness app liability in your jurisdiction(s) before this
// reaches real users.

class WaiverScreen extends StatefulWidget {
  final VoidCallback onAccepted;
  const WaiverScreen({super.key, required this.onAccepted});

  @override
  State<WaiverScreen> createState() => _WaiverScreenState();
}

class _WaiverScreenState extends State<WaiverScreen> {
  bool _agreed = false;
  bool _reachedEnd = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_reachedEnd && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 24) {
        setState(() => _reachedEnd = true);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.position.maxScrollExtent <= 0) {
        setState(() => _reachedEnd = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAgree = _reachedEnd;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF00BFA5).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.health_and_safety_outlined, color: Color(0xFF1DE9B6), size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(child: Text('Health & Safety Acknowledgment', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800))),
              ]),
              const SizedBox(height: 8),
              Text('Please read this carefully before continuing. Scroll to the bottom to enable the agreement checkbox.', style: TextStyle(color: Colors.grey.shade400, fontSize: 12, height: 1.4)),
            ]),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _heading('1. Not Medical Advice'),
                      _body('GetFit4Me provides general fitness information and exercise routines for informational and educational purposes only. Nothing in this app is, or should be treated as, medical advice, diagnosis, or treatment. The app does not replace the relationship you have with your physician, physical therapist, or other qualified healthcare provider.'),
                      _heading('2. Talk to Your Doctor First'),
                      _body('Before beginning this or any exercise or sport-performance training program — especially if you have any pre-existing medical condition, are pregnant, are recovering from an injury or surgery, or have any concerns about your ability to train safely — please consult your doctor or another qualified healthcare provider. Only they can assess what is appropriate for your individual situation.'),
                      _heading('3. How These Routines Are Designed'),
                      _body('Exercise selections and modifications within this app — across both the Sport Performance and Medical Condition categories — are informed by established strength and conditioning, sport-performance, and physical therapy / exercise science principles for the sports and conditions listed. They are general guidelines, not an individualized training or medical program, and have not been customized for your specific health history, sport level, or goals. Your individual needs may differ, sometimes significantly, from general guidance — especially if you are managing a medical condition while also training for a sport.'),
                      _heading('4. Assumption of Risk'),
                      _body('Physical exercise carries inherent risks, including but not limited to muscle strains, joint injuries, dizziness, and in rare cases more serious cardiovascular events. By using this app, you voluntarily assume all risks associated with participating in the exercises and programs offered, whether known or unknown.'),
                      _heading('5. Listen to Your Body'),
                      _body('If at any point you experience pain, dizziness, shortness of breath, chest discomfort, or any other concerning symptom, STOP exercising immediately. This app includes prompts to report pain and may suggest pausing or stopping a session, but these prompts are not a substitute for your own judgment or for professional medical evaluation.'),
                      _heading('6. Emergencies'),
                      _body('This app is not equipped to handle medical emergencies and does not monitor you in real time. If you are experiencing a medical emergency — such as chest pain, severe shortness of breath, fainting, or a severe injury — call your local emergency number (such as 911 in the US) immediately. Do not rely on this app for emergency response.'),
                      _heading('7. Release of Liability'),
                      _body('To the fullest extent permitted by law, by using this app you release GetFit4Me, its developers, and affiliated parties from any and all claims, liabilities, damages, losses, or expenses arising out of or in any way connected with your use of the app, including your participation in any exercise or program offered through it.'),
                      _heading('8. Acknowledgment'),
                      _body('By checking the box below and continuing, you confirm that you have read and understood this acknowledgment, that you are voluntarily choosing to participate, and that you have either consulted a healthcare provider about your ability to exercise safely or are confident in your own judgment that you do not need to.'),
                      const SizedBox(height: 8),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              GestureDetector(
                onTap: canAgree ? () => setState(() => _agreed = !_agreed) : null,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Checkbox(
                    value: _agreed,
                    onChanged: canAgree ? (v) => setState(() => _agreed = v ?? false) : null,
                    activeColor: const Color(0xFF00BFA5),
                    checkColor: Colors.black,
                    side: BorderSide(color: canAgree ? Colors.white : Colors.grey.shade700),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        canAgree ? 'I have read and understood this acknowledgment, and I agree to its terms.' : 'Please scroll through the full acknowledgment above to continue.',
                        style: TextStyle(color: canAgree ? Colors.white : Colors.grey.shade500, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5), disabledBackgroundColor: const Color(0xFF37474F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: _agreed ? widget.onAccepted : null,
                  child: const Text('I Agree & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _heading(String text) => Padding(padding: const EdgeInsets.only(top: 14, bottom: 6), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00897B))));
  Widget _body(String text) => Text(text, style: const TextStyle(fontSize: 12.5, height: 1.55, color: Colors.black87));
}
