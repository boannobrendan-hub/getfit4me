import 'package:flutter/material.dart';
import '../models/coach.dart';

/// Shown immediately after a workout is completed. Captures a quick star
/// rating, optional quick-tag chips, and an optional free-text note.
/// Ported from the DartPad prototype — UI is unchanged, but submission now
/// goes through FirestoreService (wired in MainShell) instead of an
/// in-memory list.
class WorkoutFeedbackScreen extends StatefulWidget {
  final Coach coach;
  final String activeSelection;
  final int exerciseCount;
  final void Function({required int rating, required List<String> tags, required String note}) onSubmit;

  const WorkoutFeedbackScreen({
    super.key,
    required this.coach,
    required this.activeSelection,
    required this.exerciseCount,
    required this.onSubmit,
  });

  @override
  State<WorkoutFeedbackScreen> createState() => _WorkoutFeedbackScreenState();
}

class _WorkoutFeedbackScreenState extends State<WorkoutFeedbackScreen> {
  int _rating = 0;
  final Set<String> _selectedTags = {};
  final _noteController = TextEditingController();

  static const _allTags = [
    'Loved it', 'Felt great', 'Too easy', 'Too hard',
    'Felt exhausted', 'Pain or discomfort', 'Needed more time', 'Right level',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSubmit(rating: _rating, tags: _selectedTags.toList(), note: _noteController.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.coach.accentColor;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('How did that go?', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
            child: Row(children: [
              Text(widget.coach.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${widget.activeSelection} session complete', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${widget.exerciseCount} exercises finished', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 28),
          const Text('Overall, how did this session feel?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              final filled = starIndex <= _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = starIndex),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 42,
                  color: filled ? Colors.amber.shade600 : Colors.grey.shade400,
                ),
              );
            }),
          ),
          if (_rating > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(child: Text(_ratingLabel(_rating), style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic))),
            ),
          const SizedBox(height: 28),
          const Text('Anything you want to flag? (optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text('Select any that apply — this helps tune your next session.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _allTags.map((tag) {
              final selected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? color.withOpacity(0.12) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? color : Colors.grey.shade300, width: selected ? 1.5 : 1),
                  ),
                  child: Text(tag, style: TextStyle(fontSize: 12.5, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? color : Colors.black87)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          const Text('Anything else? (optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g. "My left knee felt a bit tight during lunges"',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color, width: 2)),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _submit,
              child: const Text('Submit & View Trophy Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, height: 44,
            child: TextButton(
              onPressed: _submit,
              child: Text('Skip for now', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1: return 'That was rough — thanks for telling me';
      case 2: return 'Tougher than expected — noted';
      case 3: return 'Solid session';
      case 4: return 'Great session!';
      case 5: return 'Excellent — loved that!';
      default: return '';
    }
  }
}
