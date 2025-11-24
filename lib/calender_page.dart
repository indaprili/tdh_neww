import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Halaman lain
import 'home_page.dart';
import 'notification_service.dart';
import 'stats_page.dart';
import 'profile_page.dart';
import 'add_edit_item_sheet.dart' as AddEditSheet;

// MODEL & DATABASE
import 'todo_item.dart';
import 'todo_database.dart';

// Biar nama _Item di UI tetap kepake
typedef _Item = TodoItem;

// --- KONSTANTA ---
const kPrimary500 = Color(0xFF1778FB); // blue
const kTaskGreen = Color(0xFF27AE60); // green (Task)

class CalendarPage extends StatefulWidget {
  static const routeName = '/calendar';
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _bottomIndex = 1; // Indeks 'Calendar'
  int _tabIndex = 0; // 0 = Task, 1 = Habit

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Data sekarang ambil dari database
  List<_Item> tasks = [];
  List<_Item> habits = [];

  @override
  void initState() {
    super.initState();
    _loadItemsFromDb();
  }

  Future<void> _loadItemsFromDb() async {
    final all = await TodoDatabase.instance.getAllItems();
    setState(() {
      tasks = all.where((e) => !e.isHabit).toList();
      habits = all.where((e) => e.isHabit).toList();
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<_Item> get _currentList {
    final src = _tabIndex == 0 ? tasks : habits;
    return src.where((e) => _isSameDay(e.dueDate, _selectedDay)).toList();
  }

  double get _currentPercent {
    final list = _currentList;
    if (list.isEmpty) return 0;
    final done = list.where((e) => e.done).length;
    return done / list.length;
  }

  String get _completedText {
    final list = _currentList;
    final done = list.where((e) => e.done).length;
    return '$done of ${list.length} completed';
  }

  String _formatDue(DateTime date) {
    if (_isSameDay(date, DateTime.now())) {
      final hh = date.hour.toString().padLeft(2, '0');
      final mm = date.minute.toString().padLeft(2, '0');
      return 'Today, $hh:$mm';
    }
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }

  void _toggleItem(_Item item) {
    setState(() {
      item.done = !item.done;
    });
    if (item.id != null) {
      // fire & forget, ga perlu di-await di sini
      TodoDatabase.instance.updateItem(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final Color accentColor = _tabIndex == 0 ? kTaskGreen : kPrimary500;

    return Scaffold(
      backgroundColor: cs.surface,
      extendBody: true,

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Calendar',
          style: GoogleFonts.inter(
            color: cs.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // --- FAB + bulatan ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 63,
            height: 63,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isLight ? 0.08 : 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: kPrimary500,
            onPressed: () async {
              final res = await AddEditSheet.AddEditItemSheet.show(
                context,
                isHabit: _tabIndex == 1,
                initial: AddEditSheet.ItemData(
                  title: '',
                  description: '',
                  tag: _tabIndex == 1 ? 'Daily' : 'Work',
                  isHabit: _tabIndex == 1,
                  dueDate: _selectedDay,
                  dueTime: TimeOfDay.now(),
                  recurrence: 'No Repeat',
                ),
              );
              if (res == null) return;

              if (res.action == AddEditSheet.AddEditAction.save &&
                  res.data != null) {
                final d = res.data!;
                final baseDate = d.dueDate ?? _selectedDay;
                DateTime due;

                if (d.dueTime != null) {
                  due = DateTime(
                    baseDate.year,
                    baseDate.month,
                    baseDate.day,
                    d.dueTime!.hour,
                    d.dueTime!.minute,
                  );
                } else {
                  due = baseDate;
                }

                final newItem = _Item(
                  title: d.title,
                  chip: d.tag,
                  dueDate: due,
                  done: d.done,
                  chipColor: d.chipColor,
                  isHabit: _tabIndex == 1,
                );

                final id = await TodoDatabase.instance.insertItem(newItem);
                newItem.id = id;
                if (newItem.dueDate != null) {
                  await NotificationService().scheduleReminder(newItem);
                }

                setState(() {
                  if (_tabIndex == 0) {
                    tasks.add(newItem);
                  } else {
                    habits.add(newItem);
                  }
                });
              }
            },
            child: Icon(Icons.add, color: isLight ? Colors.white : Colors.black),
          ),
        ],
      ),

      // --- Bottom bar ---
      bottomNavigationBar: BottomAppBar(
        color: cs.surface,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _BottomItem(
                icon: Image.asset('assets/Home.png', width: 24, height: 24),
                label: 'Home',
                selected: _bottomIndex == 0,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  HomePage.routeName,
                ),
              ),
              _BottomItem(
                icon: Image.asset(
                  'assets/calender_icon_habit.png',
                  width: 24,
                  height: 24,
                ),
                label: 'Calendar',
                selected: _bottomIndex == 1,
                onTap: () {}, // sudah di halaman ini
              ),
              const Spacer(),
              _BottomItem(
                icon: Image.asset('assets/Stats.png', width: 24, height: 24),
                label: 'Stats',
                selected: _bottomIndex == 2,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  StatsPage.routeName,
                ),
              ),
              _BottomItem(
                icon: Image.asset('assets/profile.png', width: 24, height: 24),
                label: 'Profile',
                selected: _bottomIndex == 3,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  ProfilePage.routeName,
                ),
              ),
            ],
          ),
        ),
      ),

      // --- BODY: kalender + panel bawah ---
      body: Column(
        children: [
          // KALENDER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2050, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => _isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: cs.onSurface),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: cs.onSurface),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.inter(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                weekendStyle: GoogleFonts.inter(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                dowTextFormatter: (date, locale) =>
                    DateFormat('EE', locale).format(date).substring(0, 2),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: TextStyle(color: cs.onSurface),
                weekendTextStyle: TextStyle(color: cs.onSurface),
                todayDecoration: BoxDecoration(
                  color: accentColor.withOpacity(.18),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: cs.onSurface),
                selectedDecoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          Divider(height: 1, color: theme.dividerColor),

          // PANEL BAWAH
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 110),
              children: [
                _SegmentedTabs(
                  index: _tabIndex,
                  onChanged: (v) => setState(() => _tabIndex = v),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Center(
                    child: Text(
                      DateFormat('EEEE, d MMMM y').format(_selectedDay),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ProgressCard(
                    isHabit: _tabIndex == 1,
                    percent: _currentPercent,
                    completedText: _completedText,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _currentList.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              _tabIndex == 0
                                  ? 'No tasks on this date'
                                  : 'No habits on this date',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children:
                              _currentList.asMap().entries.map((entry) {
                            final item = entry.value;
                            final source =
                                _tabIndex == 0 ? tasks : habits;
                            final realIndex = source.indexOf(item);
                            return _ItemTile(
                              item: item,
                              timeText: _formatDue(item.dueDate),
                              isHabit: _tabIndex == 1,
                              onToggle: () => _toggleItem(item),
                              onTap: () async {
                                final res = await AddEditSheet
                                    .AddEditItemSheet.show(
                                  context,
                                  isHabit: _tabIndex == 1,
                                  initial: AddEditSheet.ItemData(
                                    title: item.title,
                                    description: '',
                                    tag: item.chip,
                                    isHabit: item.isHabit,
                                    done: item.done,
                                    chipColor: item.chipColor,
                                    dueDate: item.dueDate,
                                  ),
                                );
                                if (res == null) return;

                                if (res.action ==
                                    AddEditSheet
                                        .AddEditAction.delete) {
                                  final removed =
                                      source.removeAt(realIndex);
                                  setState(() {});
                                  if (removed.id != null) {
                                    await TodoDatabase.instance
                                        .deleteItem(removed.id!);
                                  }
                                } else if (res.action ==
                                        AddEditSheet
                                            .AddEditAction.save &&
                                    res.data != null) {
                                  final d = res.data!;
                                  final baseDate =
                                      d.dueDate ?? item.dueDate;
                                  DateTime newDue;
                                  if (d.dueTime != null) {
                                    newDue = DateTime(
                                      baseDate.year,
                                      baseDate.month,
                                      baseDate.day,
                                      d.dueTime!.hour,
                                      d.dueTime!.minute,
                                    );
                                  } else {
                                    newDue = baseDate;
                                  }

                                  final updated = _Item(
                                    id: item.id,
                                    title: d.title,
                                    chip: d.tag,
                                    dueDate: newDue,
                                    done: d.done,
                                    chipColor: d.chipColor,
                                    isHabit: item.isHabit,
                                  );

                                  setState(() {
                                    source[realIndex] = updated;
                                  });
                                  await TodoDatabase.instance
                                      .updateItem(updated);
                                }
                              },
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================== UI PARTS ================== */

class _SegmentedTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _SegmentedTabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor.withOpacity(.35);
    return Row(
      children: [
        Expanded(
          child: _tabButton(
            context,
            'Task',
            selected: index == 0,
            color: kTaskGreen,
            divider: divider,
            onTap: () => onChanged(0),
          ),
        ),
        Expanded(
          child: _tabButton(
            context,
            'Habit',
            selected: index == 1,
            color: kPrimary500,
            divider: divider,
            onTap: () => onChanged(1),
          ),
        ),
      ],
    );
  }

  Widget _tabButton(
    BuildContext context,
    String text, {
    required bool selected,
    required Color color,
    required Color divider,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? color : divider,
              width: selected ? 2.0 : 1.0,
            ),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? color
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? kPrimary500
        : (theme.brightness == Brightness.dark
            ? Colors.white70
            : Colors.black54);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 24, height: 24, child: icon),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final bool isHabit;
  final double percent;
  final String completedText;
  const _ProgressCard({
    required this.isHabit,
    required this.percent,
    required this.completedText,
  });

  @override
  Widget build(BuildContext context) {
    final title = isHabit ? "Today's Habit" : "Today's Task";
    final sub =
        isHabit ? "Great progress! Almost there 💪" : "Focus on What Matters! 🔥";
    final colors = isHabit
        ? [kPrimary500, const Color(0xFF4FC3F7)]
        : [const Color(0xFF2ECC71), const Color(0xFF00C48C)];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 5,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    backgroundColor: Colors.white24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${(percent * 100).round()}%',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  completedText,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color chipBg =
        isLight ? color.withOpacity(.18) : color.withOpacity(0.3);
    final Color chipFg = isLight
        ? color
        : HSLColor.fromColor(color).withLightness(0.7).toColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: chipFg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool checked;
  final Color color;
  final Color? borderColor;
  const _CheckCircle({
    required this.checked,
    required this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? color : Colors.transparent,
        border: checked
            ? null
            : Border.all(color: effectiveBorderColor, width: 2),
      ),
      child: checked
          ? const Icon(Icons.check, color: Colors.white, size: 20)
          : null,
    );
  }
}

class _ItemTile extends StatelessWidget {
  final _Item item;
  final String timeText;
  final bool isHabit;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  const _ItemTile({
    required this.item,
    required this.timeText,
    required this.isHabit,
    required this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final accent = isHabit ? kPrimary500 : kTaskGreen;
    final Color bgSoft =
        isLight ? accent.withOpacity(.10) : cs.surfaceVariant.withOpacity(0.3);
    final Color border = cs.outlineVariant.withOpacity(isLight ? 0.35 : 0.6);
    final Color subtleColor = cs.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bgSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: _CheckCircle(
                checked: item.done,
                color: accent,
                borderColor: isLight ? accent : cs.outlineVariant,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Chip(text: item.chip, color: item.chipColor),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time_rounded,
                          size: 14, color: subtleColor),
                      const SizedBox(width: 4),
                      Text(
                        timeText,
                        style:
                            GoogleFonts.inter(color: subtleColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.more_horiz_rounded, color: subtleColor),
          ],
        ),
      ),
    );
  }
}
