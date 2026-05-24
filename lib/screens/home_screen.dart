import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../services/habit_storage.dart';
import '../widgets/habit_card.dart';
import 'add_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await HabitStorage.loadHabits();
    setState(() {
      _habits = habits;
      _loading = false;
    });
  }

  Future<void> _saveHabits() async {
    await HabitStorage.saveHabits(_habits);
  }

  void _toggleDay(Habit habit, DateTime date) {
    HapticFeedback.lightImpact();
    setState(() {
      habit.toggleDay(date);
    });
    _saveHabits();
  }

  void _deleteHabit(Habit habit) {
    setState(() => _habits.removeWhere((h) => h.id == habit.id));
    _saveHabits();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${habit.emoji} ${habit.name} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() => _habits.add(habit));
            _saveHabits();
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openAddHabit({Habit? editing}) async {
    final result = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(
        builder: (_) => AddHabitScreen(editing: editing),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      setState(() {
        if (editing != null) {
          final idx = _habits.indexWhere((h) => h.id == editing.id);
          if (idx != -1) {
            _habits[idx].name = result.name;
            _habits[idx].colorValue = result.colorValue;
            _habits[idx].emoji = result.emoji;
          }
        } else {
          _habits.add(result);
        }
      });
      _saveHabits();
    }
  }

  String get _todayFormatted {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final weekday = days[now.weekday - 1];
    return '$weekday, ${months[now.month - 1]} ${now.day}';
  }

  int get _todayDoneCount =>
      _habits.where((h) => h.isCheckedOn(DateTime.now())).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Habits',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _todayFormatted,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      color: isDark ? Colors.white54 : const Color(0xFF888780),
                                    ),
                                  ),
                                ],
                              ),
                              if (_habits.isNotEmpty)
                                _SummaryBadge(
                                  done: _todayDoneCount,
                                  total: _habits.length,
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  if (_habits.isEmpty)
                    SliverFillRemaining(
                      child: _EmptyState(onAdd: _openAddHabit),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: AnimationLimiter(
                        child: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final habit = _habits[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50,
                                  child: FadeInAnimation(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: HabitCard(
                                        habit: habit,
                                        onToggleDay: (date) => _toggleDay(habit, date),
                                        onEdit: () => _openAddHabit(editing: habit),
                                        onDelete: () => _deleteHabit(habit),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: _habits.length,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddHabit,
        backgroundColor: const Color(0xFF1D9E75),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New Habit',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
        elevation: 4,
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  final int done;
  final int total;
  const _SummaryBadge({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allDone = done == total && total > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: allDone
            ? const Color(0xFF1D9E75).withOpacity(0.15)
            : isDark
                ? Colors.white12
                : const Color(0xFFEEECE6),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$done / $total today',
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: allDone
              ? const Color(0xFF1D9E75)
              : isDark
                  ? Colors.white70
                  : const Color(0xFF5F5E5A),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1D9E75).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_florist_rounded,
                size: 40,
                color: Color(0xFF1D9E75),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No habits yet',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building your daily routine\nby adding your first habit.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1D9E75),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Add your first habit',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
