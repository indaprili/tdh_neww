import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Halaman lain
import 'calender_page.dart';
import 'notification_service.dart';
import 'stats_page.dart';
import 'add_edit_item_sheet.dart';
import 'profile_page.dart';

// model & database
import 'todo_item.dart';
import 'todo_database.dart';

// alias supaya kode lama tetap pakai _Item
typedef _Item = TodoItem;

// KONSTANTA
const kPrimary500 = Color(0xFF1778FB); // blue
const kGreen200  = Color(0xFF8EE7C4);  // green
const kTaskGreen = Color(0xFF27AE60);

const double kDarkMixPercent = 0.3;

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomIndex = 0;
  int _tabIndex = 0; // 0 = Task, 1 = Habit

  final DateTime _today = DateTime.now();
  int _selectedOffset = 0;

  List<_Item> tasks = [];
  List<_Item> habits = [];

  DateTime get _selectedDate => _today.add(Duration(days: _selectedOffset));

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<_Item> get _currentList {
    final src = _tabIndex == 0 ? tasks : habits;
    return src.where((e) => _isSameDay(e.dueDate, _selectedDate)).toList();
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

  String _todayFormatted(DateTime d) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December',
    ];
    final dd = d.day.toString().padLeft(2, '0');
    return 'Today, $dd ${months[d.month - 1]} ${d.year}';
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

  @override
  void initState() {
    super.initState();
    NotificationService().requestPermission();
    //NotificationService().scheduleDebugNotification();
    _loadItemsFromDb();
  }

  Future<void> _loadItemsFromDb() async {
    try {
      final all = await TodoDatabase.instance.getAllItems();
      setState(() {
        tasks  = all.where((e) => !e.isHabit).toList();
        habits = all.where((e) =>  e.isHabit).toList();
      });
    } catch (e) {
      debugPrint('Error load items: $e');
    }
  }

  Future<void> _toggleDone(List<_Item> source, int index) async {
    final item = source[index];
    setState(() {
      item.done = !item.done;
    });
    try {
      if (item.id != null) {
        await TodoDatabase.instance.updateItem(item);
        // (opsional) di sini bisa cancel notif kalau mau, tapi sekarang fokusnya hanya schedule
      }
    } catch (e) {
      debugPrint('Error update done: $e');
    }
  }

  // Wrapper supaya kalau nanti logika reminder berubah, cukup di sini
  
  Future<void> _scheduleReminder(_Item item) async {
    await NotificationService().scheduleReminder(item);
  }

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final cs      = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final panelColor  = cs.surface;
    final shadowColor = Colors.black.withOpacity(isLight ? 0.08 : 0.35);

    return Scaffold(
      extendBody: true,

      // FAB
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
                  color: shadowColor,
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
              final res = await AddEditItemSheet.show(
                context,
                isHabit: _tabIndex == 1,
              );
              if (res == null) return;
              if (res.action == AddEditAction.save && res.data != null) {
                final d = res.data!;

                // tanggal dasar = dari sheet, kalau null pakai tanggal yang sedang dipilih
                DateTime baseDate = d.dueDate ?? _selectedDate;

                // kalau ada time, gabungkan ke dalam DateTime
                if (d.dueTime != null) {
                  baseDate = DateTime(
                    baseDate.year,
                    baseDate.month,
                    baseDate.day,
                    d.dueTime!.hour,
                    d.dueTime!.minute,
                  );
                }

                var newItem = _Item(
                  title: d.title,
                  chip: d.tag,
                  dueDate: baseDate,
                  done: d.done,
                  chipColor: d.chipColor,
                  isHabit: _tabIndex == 1,
                );

                // 1) langsung masukin ke list biar kelihatan real-time
                setState(() {
                  if (newItem.isHabit) {
                    habits.add(newItem);
                  } else {
                    tasks.add(newItem);
                  }
                });

                // 2) baru coba simpan ke database + schedule reminder
                try {
                  final id = await TodoDatabase.instance.insertItem(newItem);
                  try {
                    newItem.id = id;
                  } catch (_) {
                    // kalau id final / read-only, abaikan saja
                  }

                  // Jadwalkan notifikasi setelah item punya ID
                  await _scheduleReminder(newItem);
                } catch (e) {
                  debugPrint('Error insert item: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to save to database'),
                      ),
                    );
                  }
                }
              }
            },
            child: Icon(
              Icons.add,
              color: isLight ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),

      // Bottom nav
      bottomNavigationBar: BottomAppBar(
        color: cs.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _BottomItem(
                icon: Image.asset('assets/Homepage.png', width: 24, height: 24),
                label: 'Home',
                selected: _bottomIndex == 0,
                onTap: () {}, // sudah di halaman ini
              ),
              _BottomItem(
                icon: Image.asset('assets/calendar.png', width: 24, height: 24),
                label: 'Calendar',
                selected: _bottomIndex == 1,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  CalendarPage.routeName,
                ),
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

      // BODY
      body: Stack(
        children: [
          // Header gradient
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isLight
                    ? [kGreen200, kPrimary500, kGreen200]
                    : [
                        Color.lerp(kGreen200, Colors.black, kDarkMixPercent)!,
                        Color.lerp(kPrimary500, Colors.black, kDarkMixPercent)!,
                        Color.lerp(kGreen200, Colors.black, kDarkMixPercent)!,
                      ],
                stops: const [0, .5, 1],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
              ),
            ),
          ),

          // Header content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, Qoqo 👋🏻',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ready to be productive today?',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.notifications_none_rounded, color: Colors.white),
                ],
              ),
            ),
          ),

          // Panel isi
          Positioned.fill(
            top: 150,
            child: Container(
              decoration: BoxDecoration(
                color: panelColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  if (isLight)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, -4),
                    ),
                ],
              ),
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
                        _todayFormatted(_selectedDate),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _DateStrip(
                      today: _today,
                      selectedOffset: _selectedOffset,
                      onSelect: (i) => setState(() => _selectedOffset = i),
                      accentColor: _tabIndex == 0 ? kTaskGreen : kPrimary500,
                      selectedBg: _tabIndex == 0
                          ? const Color(0xFFE7F7F1)
                          : const Color(0xFFEAF2FF),
                      chipInactive: const Color(0xFFEFF3F6),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                    child: Column(
                      children: _currentList.asMap().entries.map((entry) {
                        final item      = entry.value;
                        final source    = _tabIndex == 0 ? tasks : habits;
                        final realIndex = source.indexOf(item);

                        return _ItemTile(
                          item: item,
                          timeText: _formatDue(item.dueDate),
                          isHabit: _tabIndex == 1,
                          onToggle: () => _toggleDone(source, realIndex),
                          onTap: () async {
                            final res = await AddEditItemSheet.show(
                              context,
                              isHabit: _tabIndex == 1,
                              initial: ItemData(
                                title: item.title,
                                description: '',
                                tag: item.chip,
                                isHabit: _tabIndex == 1,
                                done: item.done,
                                chipColor: item.chipColor,
                                dueDate: item.dueDate,
                              ),
                            );
                            if (res == null) return;

                            if (res.action == AddEditAction.delete) {
                              try {
                                if (item.id != null) {
                                  await TodoDatabase.instance.deleteItem(item.id!);
                                }
                              } catch (e) {
                                debugPrint('Error delete item: $e');
                              }
                              setState(() => source.removeAt(realIndex));
                            } else if (res.action == AddEditAction.save &&
                                res.data != null) {
                              final d = res.data!;
                              DateTime baseDate = d.dueDate ?? item.dueDate;
                              if (d.dueTime != null) {
                                baseDate = DateTime(
                                  baseDate.year,
                                  baseDate.month,
                                  baseDate.day,
                                  d.dueTime!.hour,
                                  d.dueTime!.minute,
                                );
                              }

                              final updated = _Item(
                                title: d.title,
                                chip: d.tag,
                                dueDate: baseDate,
                                done: d.done,
                                chipColor: d.chipColor,
                                isHabit: item.isHabit,
                              )..id = item.id;

                              try {
                                if (updated.id != null) {
                                  await TodoDatabase.instance.updateItem(updated);
                                  // reschedule reminder setelah di-edit
                                  await _scheduleReminder(updated);
                                }
                              } catch (e) {
                                debugPrint('Error update item: $e');
                              }

                              setState(() {
                                source[realIndex] = updated;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ====================== UI PARTS ====================== */

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

class _DateStrip extends StatelessWidget {
  final DateTime today;
  final int selectedOffset;
  final ValueChanged<int> onSelect;
  final Color accentColor;
  final Color selectedBg;
  final Color chipInactive;

  const _DateStrip({
    required this.today,
    required this.selectedOffset,
    required this.onSelect,
    required this.accentColor,
    required this.selectedBg,
    required this.chipInactive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor.withOpacity(0.25);

    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final date      = today.add(Duration(days: i));
          final isSelected= i == selectedOffset;
          final weekday   = ['SUN','MON','TUE','WED','THU','FRI','SAT'][date.weekday % 7];
          final dd        = date.day.toString().padLeft(2, '0');

          final bgColor = isSelected ? accentColor : theme.cardColor;
          final txtColor1 = isSelected
              ? Colors.white
              : (theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87);
          final txtColor2 = isSelected
              ? Colors.white.withOpacity(.9)
              : (theme.brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54);

          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              width: 68,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: isSelected ? null : Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dd,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: txtColor1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    weekday,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: txtColor2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
    final sub   = isHabit
        ? "Great progress! Almost there 💪"
        : "Focus on What Matters! 🔥";
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
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
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
    final theme   = Theme.of(context);
    final cs      = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final accent       = isHabit ? kPrimary500 : kTaskGreen;
    final Color bgSoft = isLight
        ? accent.withOpacity(.10)
        : cs.surfaceVariant.withOpacity(0.30);
    final Color border = cs.outlineVariant.withOpacity(isLight ? 0.35 : 0.60);
    final Color subtle = cs.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bgSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1),
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
                      Icon(Icons.access_time_rounded, size: 14, color: subtle),
                      const SizedBox(width: 4),
                      Text(
                        timeText,
                        style: GoogleFonts.inter(
                          color: subtle,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.more_horiz_rounded, color: subtle),
          ],
        ),
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    final chipBg  = isLight ? color.withOpacity(.18) : color.withOpacity(0.30);
    final chipFg  = isLight
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
        border: checked ? null : Border.all(color: effectiveBorderColor, width: 2),
      ),
      child: checked
          ? const Icon(Icons.check, color: Colors.white, size: 20)
          : null,
    );
  }
}
