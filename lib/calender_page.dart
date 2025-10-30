import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'home_page.dart';
import 'stats_page.dart';
import 'profile_page.dart';
import 'add_edit_item_sheet.dart' as AddEditSheet; // Untuk ambil class _Grabber

// Konstanta dari project
const kPrimary500 = Color(0xFF1778FB); // blue
const kGreen500 = Color(0xFF27AE60); // Warna hijau dari Figma
const kTaskGreen = Color(0xFF27AE60);

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
  
  // State baru untuk UI Time/Reminder/Repeat
  TimeOfDay? _time;
  String? _recurrence;
  
  // --- Data Dummy (Kita tetap simpan untuk logika 'Tambah' dari FAB) ---
  List<_Item> tasks = [];
  List<_Item> habits = [];
  // --- Akhir Data Dummy ---

  @override
  void initState() {
    super.initState();
    _time = TimeOfDay.now();
    _recurrence = 'No Repeat';
  }

  // <-- FIX 1/2: Fungsi yang error tadi ditambahkan di sini
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  DateTime get _selectedDate => _selectedDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shadowColor = Colors.black.withOpacity(
      theme.brightness == Brightness.dark ? 0.35 : 0.08,
    );
    
    // Warna dinamis berdasarkan tab
    final Color accentColor = _tabIndex == 0 ? kGreen500 : kPrimary500;

    return Scaffold(
      extendBody: true,

      // --- NAVBAR (Tetap Ada) ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 63,
            height: 63,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface,
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
              // Fungsi 'Tambah' tetap memanggil AddEditItemSheet
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
              if (res.action == AddEditSheet.AddEditAction.save && res.data != null) {
                final d = res.data!;
                final due = d.dueDate ?? _selectedDate;
                final newItem = _Item(
                  d.title,
                  d.tag,
                  due,
                  d.done,
                  chipColor: d.chipColor,
                );
                setState(() {
                  if (_tabIndex == 0)
                    tasks.add(newItem);
                  else
                    habits.add(newItem);
                });
              }
            },
            child: Icon(
              Icons.add,
               color: theme.brightness == Brightness.light ? Colors.white : Colors.black,
               ),
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        color: theme.colorScheme.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _BottomItem(
                icon: Image.asset(
                  'assets/home.png',
                  width: 24,
                  height: 24,
                  color: _bottomIndex == 0 ? kPrimary500 : Colors.grey,
                ),
                label: 'Home',
                selected: _bottomIndex == 0,
                onTap: () => Navigator.pushReplacementNamed(
                    context, HomePage.routeName),
              ),
              _BottomItem(
                icon: Image.asset(
                  'assets/calendar.png',
                  width: 24,
                  height: 24,
                  color: _bottomIndex == 1 ? kPrimary500 : Colors.grey,
                ),
                label: 'Calendar',
                selected: _bottomIndex == 1,
                onTap: () {},
              ),
              const Spacer(),
              _BottomItem(
                icon: Image.asset(
                  'assets/stats.png',
                  width: 24,
                  height: 24,
                  color: _bottomIndex == 2 ? kPrimary500 : Colors.grey,
                ),
                label: 'Stats',
                selected: _bottomIndex == 2,
                onTap: () => Navigator.pushReplacementNamed(
                    context, StatsPage.routeName),
              ),
              _BottomItem(
                icon: Image.asset(
                  'assets/profile.png',
                  width: 24,
                  height: 24,
                  color: _bottomIndex == 3 ? kPrimary500 : Colors.grey,
                ),
                label: 'Profile',
                selected: _bottomIndex == 3,
                onTap: () => Navigator.pushReplacementNamed(
                    context, ProfilePage.routeName),
              ),
            ],
          ),
        ),
      ),
      // --- AKHIR NAVBAR ---

      // --- REVISI: Body Halaman ---
      body: SafeArea(
        bottom: false, // <-- FIX UNTUK NAVBAR 'LEBAR'
        child: Column( 
          children: [
            // ===== 1. Segmented Tabs (Paling atas) =====
            _SegmentedTabs(
              index: _tabIndex,
              onChanged: (v) => setState(() => _tabIndex = v),
            ),

            // ===== 2. TableCalendar =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TableCalendar(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2050, 12, 31),
                focusedDay: _focusedDay,
                
                // State
                // <-- FIX 2/2: Menggunakan fungsi private _isSameDay
                selectedDayPredicate: (day) => _isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },

                // ----- STYLING DINAMIS (Hijau/Biru) -----
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: accentColor),
                  rightChevronIcon: Icon(Icons.chevron_right, color: accentColor),
                ),
                
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: const TextStyle(color: Colors.grey),
                  weekendStyle: const TextStyle(color: Colors.grey),
                  dowTextFormatter: (date, locale) =>
                      DateFormat('EE', locale).format(date).substring(0, 2),
                ),

                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: accentColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(color: Colors.black),
                  
                  selectedDecoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== 3. UI Time/Reminder/Repeat (Dengan Aset Dinamis) =====
            _buildDateTimeRecurrenceRow(
              context,
              _selectedDay,
              _time!,
              _recurrence!,
              _tabIndex, // <-- Kirim tab index
            ),
            
            // Spacer untuk mendorong konten ke atas
            const Spacer(), 
          ],
        ),
      ),
    );
  }

  // --- Widget 'Time, Reminder, Repeat' ---
  // (Versi BARU dengan Image.asset dinamis)
  Widget _buildDateTimeRecurrenceRow(
    BuildContext context,
    DateTime selectedDate,
    TimeOfDay selectedTime,
    String selectedRecurrence,
    int tabIndex, // <-- Parameter baru
  ) {
    String formattedDate = DateFormat('dd MMMM yyyy').format(selectedDate);
    String formattedTime = selectedTime.format(context);

    // --- Tentukan path aset berdasarkan tabIndex ---
    final String timeIconPath = tabIndex == 0 ? 'assets/time_task.png' : 'assets/time_habit.png';
    final String reminderIconPath = tabIndex == 0 ? 'assets/reminder_task.png' : 'assets/reminder_habit.png';
    final String repeatIconPath = tabIndex == 0 ? 'assets/repeat_task.png' : 'assets/repeat_habit.png';
    final String dropdownIconPath = tabIndex == 0 ? 'assets/dropdown_task.png' : 'assets/dropdown_habit.png';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Today, Date, Time
          GestureDetector(
            onTap: () async {
              final newTime = await showTimePicker(
                context: context,
                initialTime: selectedTime,
              );
              if (newTime != null) {
                setState(() {
                  _time = newTime; // Update state halaman ini
                });
              }
            },
            child: Row(
              children: [
                // --- DIGANTI ---
                Image.asset(timeIconPath, width: 24, height: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Today, $formattedDate - $formattedTime',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                // --- DIGANTI ---
                Image.asset(dropdownIconPath, width: 14, height: 18),
              ],
            ),
          ),
          Divider(height: 30, color: Colors.grey[300]),

          // 1 hours before (Reminder)
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder selection not implemented yet')),
              );
            },
            child: Row(
              children: [
                // --- DIGANTI ---
                Image.asset(reminderIconPath, width: 24, height: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '1 hours before', // Placeholder
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                // --- DIGANTI ---
                Image.asset(dropdownIconPath, width: 14, height: 18),
              ],
            ),
          ),
          Divider(height: 30, color: Colors.grey[300]),

          // Recurrence (Every Weekend)
          GestureDetector(
            onTap: () async {
              final String? pickedRecurrence = await showModalBottomSheet<String>(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (ctx) => SafeArea(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const SizedBox(height: 8),
                      const Center(child: _Grabber()),
                      ListTile(
                        title: const Text('No Repeat', style: TextStyle(fontWeight: FontWeight.w600)),
                        trailing: selectedRecurrence == 'No Repeat' ? const Icon(Icons.check, color: kPrimary500) : null,
                        onTap: () => Navigator.pop(ctx, 'No Repeat'),
                      ),
                      ListTile(
                        title: const Text('Daily', style: TextStyle(fontWeight: FontWeight.w600)),
                        trailing: selectedRecurrence == 'Daily' ? const Icon(Icons.check, color: kPrimary500) : null,
                        onTap: () => Navigator.pop(ctx, 'Daily'),
                      ),
                      ListTile(
                        title: const Text('Weekly', style: TextStyle(fontWeight: FontWeight.w600)),
                        trailing: selectedRecurrence == 'Weekly' ? const Icon(Icons.check, color: kPrimary500) : null,
                        onTap: () => Navigator.pop(ctx, 'Weekly'),
                      ),
                      ListTile(
                        title: const Text('Every Weekend', style: TextStyle(fontWeight: FontWeight.w600)),
                        trailing: selectedRecurrence == 'Every Weekend' ? const Icon(Icons.check, color: kPrimary500) : null,
                        onTap: () => Navigator.pop(ctx, 'Every Weekend'),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
              if (pickedRecurrence != null) {
                setState(() {
                  _recurrence = pickedRecurrence; // Update state halaman ini
                });
              }
            },
            child: Row(
              children: [
                // --- DIGANTI ---
                Image.asset(repeatIconPath, width: 24, height: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedRecurrence,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                // --- DIGANTI ---
                Image.asset(dropdownIconPath, width: 14, height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================== UI PARTS (YANG DIBUTUHKAN) ================== */
// (Hanya widget yang dipakai: _SegmentedTabs, _BottomItem, dan _Grabber)

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

// Widget Grabber (diambil dari add_edit_item_sheet)
class _Grabber extends StatelessWidget {
  const _Grabber();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0x22000000),
        borderRadius: BorderRadius.circular(999),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}

// Model data (Tetap dibutuhkan untuk FAB 'Tambah')
class _Item {
  final String title;
  final String chip;
  DateTime dueDate;
  bool done;
  final Color chipColor;
  _Item(
    this.title,
    this.chip,
    this.dueDate,
    this.done, {
    required this.chipColor,
  });
}