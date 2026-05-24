import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? editing;
  const AddHabitScreen({super.key, this.editing});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  late TextEditingController _nameCtrl;
  late int _selectedColor;
  late String _selectedEmoji;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.editing?.name ?? '');
    _selectedColor = widget.editing?.colorValue ?? kHabitColors[0]['color'].value;
    _selectedEmoji = widget.editing?.emoji ?? kHabitEmojis[0];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a habit name', style: GoogleFonts.dmSans()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    final habit = Habit(
      id: widget.editing?.id ?? const Uuid().v4(),
      name: name,
      colorValue: _selectedColor,
      emoji: _selectedEmoji,
      checkedDays: widget.editing?.checkedDays ?? {},
      createdAt: widget.editing?.createdAt,
    );
    Navigator.pop(context, habit);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Color(_selectedColor);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing != null ? 'Edit Habit' : 'New Habit'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji + Name preview
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(_selectedEmoji, style: const TextStyle(fontSize: 36)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _SectionLabel('Habit name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              autofocus: widget.editing == null,
              maxLength: 60,
              decoration: InputDecoration(
                hintText: 'e.g. Drink 2L of water',
                hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                filled: true,
                fillColor: isDark ? Colors.white10 : const Color(0xFFEEECE6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                counterStyle: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey),
              ),
              style: GoogleFonts.dmSans(fontSize: 16),
            ),
            const SizedBox(height: 20),

            _SectionLabel('Pick an emoji'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: kHabitEmojis.map((e) {
                final selected = e == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? accentColor.withOpacity(0.2)
                          : isDark
                              ? Colors.white10
                              : const Color(0xFFEEECE6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? accentColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            _SectionLabel('Pick a color'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: kHabitColors.map((c) {
                final color = c['color'] as Color;
                final selected = color.value == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? isDark
                                ? Colors.white
                                : Colors.black
                            : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: selected
                          ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
                          : [],
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }
}
