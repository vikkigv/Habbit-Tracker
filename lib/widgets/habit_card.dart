import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/habit.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final void Function(DateTime) onToggleDay;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggleDay,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _expanded = false;
  DateTime _focusedDay = DateTime.now();

  Color get _color => Color(widget.habit.colorValue);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  // Emoji + color dot
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.habit.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _StatChip(
                              icon: Icons.local_fire_department_rounded,
                              label: '${widget.habit.currentStreak}d streak',
                              color: widget.habit.currentStreak > 0
                                  ? const Color(0xFFD85A30)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            _StatChip(
                              icon: Icons.check_circle_outline_rounded,
                              label: '${widget.habit.totalDone} total',
                              color: _color,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Today toggle
                  GestureDetector(
                    onTap: () => widget.onToggleDay(DateTime.now()),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.habit.isCheckedOn(DateTime.now())
                            ? _color
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.habit.isCheckedOn(DateTime.now())
                              ? _color
                              : isDark
                                  ? Colors.white30
                                  : const Color(0xFFCCCAC4),
                          width: 1.5,
                        ),
                      ),
                      child: widget.habit.isCheckedOn(DateTime.now())
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expandable calendar
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: _buildCalendarSection(isDark),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),

          // Action bar when expanded
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text('Edit', style: GoogleFonts.dmSans(fontSize: 13)),
                    style: TextButton.styleFrom(
                      foregroundColor: _color,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: Text('Delete', style: GoogleFonts.dmSans(fontSize: 13)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE24B4A),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.now(),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF444441),
          ),
          leftChevronIcon: Icon(Icons.chevron_left_rounded,
              color: isDark ? Colors.white54 : Colors.grey),
          rightChevronIcon: Icon(Icons.chevron_right_rounded,
              color: isDark ? Colors.white54 : Colors.grey),
          headerPadding: const EdgeInsets.symmetric(vertical: 6),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: GoogleFonts.dmSans(
            fontSize: 13,
            color: isDark ? Colors.white70 : const Color(0xFF444441),
          ),
          weekendTextStyle: GoogleFonts.dmSans(
            fontSize: 13,
            color: isDark ? Colors.white54 : const Color(0xFF888780),
          ),
          todayDecoration: BoxDecoration(
            border: Border.all(color: _color, width: 1.5),
            shape: BoxShape.circle,
          ),
          todayTextStyle: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _color,
          ),
          selectedDecoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          outsideDaysVisible: false,
          cellMargin: const EdgeInsets.all(3),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white38 : const Color(0xFFB4B2A9),
          ),
          weekendStyle: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white38 : const Color(0xFFB4B2A9),
          ),
        ),
        selectedDayPredicate: (day) => widget.habit.isCheckedOn(day),
        onDaySelected: (selected, focused) {
          if (selected.isAfter(DateTime.now())) return;
          setState(() => _focusedDay = focused);
          widget.onToggleDay(selected);
        },
        onPageChanged: (focused) => setState(() => _focusedDay = focused),
      ),
    );
  }

  void _confirmDelete() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Delete "${widget.habit.name}"?',
              style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'This will permanently delete all your progress for this habit.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancel', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onDelete();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE24B4A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Delete', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
