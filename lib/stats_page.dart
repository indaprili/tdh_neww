// stats_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'calender_page.dart';
import 'home_page.dart';
import 'add_edit_item_sheet.dart';
import 'profile_page.dart';

const kPrimary500 = Color(0xFF1778FB); // blue (Habit)
const kGreen200 = Color(0xFF8EE7C4); // header gradient light
const kTaskGreen = Color(0xFF27AE60); // green (Task)

// --- Warna Gradasi Dark Mode Redup ---
const double kDarkMixPercent = 0.3; // 30% campuran hitam

class StatsPage extends StatefulWidget {
  static const routeName = '/stats';
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _tabIndex = 0; // 0 = Task, 1 = Habit
  int _bottomIndex = 2; // Stats

  // --- Data Dummy (Tetap sama) ---
  final List<_Item> _tasks = [
    _Item(
      'Finish project report',
      'Work',
      'Today, 08:00',
      false,
      chipColor: const Color(0xFF8E44AD),
    ),
    _Item(
      'Buy groceries',
      'Personal',
      'Today',
      false,
      chipColor: const Color(0xFFF39C12),
    ),
    _Item(
      'Call the dentist',
      'Health',
      'Today, 14:00',
      false,
      chipColor: const Color(0xFF16A085),
    ),
    _Item(
      'Team meeting',
      'Work',
      'Today, 10:00',
      false,
      chipColor: const Color(0xFF8E44AD),
    ),
  ];
  final List<_Item> _habits = [
    _Item(
      'Drink 8 glasses of water',
      'Daily',
      'Today',
      false,
      chipColor: const Color(0xFF2980B9),
    ),
    _Item(
      'Read for 20 minutes',
      'Daily',
      'Today',
      true,
      chipColor: const Color(0xFF3F51B5),
    ),
    _Item('Exercise', '30 min', '—', false, chipColor: const Color(0xFF27AE60)),
    _Item('Meditate', 'Daily', '—', true, chipColor: const Color(0xFF673AB7)),
    _Item(
      'Sleep before 11 PM',
      'Weekly',
      '—',
      false,
      chipColor: const Color(0xFFE91E63),
    ),
  ];
  // --- Akhir Data Dummy ---

  List<_Item> get _currentList => _tabIndex == 0 ? _tasks : _habits;
  void _toggle(_Item item) => setState(() => item.done = !item.done);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Ambil theme
    final cs = theme.colorScheme;    // Ambil color scheme
    final isLight = theme.brightness == Brightness.light; // Cek light/dark

    return Scaffold(
      extendBody: true,

      // === FAB (Tetap sama) ===
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 63,
            height: 63,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surface, // Warna dari tema
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000), // Shadow bisa disesuaikan lagi untuk dark
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
          ),
          FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: kPrimary500, // Warna FAB
            onPressed: () async {
              final res = await AddEditItemSheet.show(
                context,
                isHabit: _tabIndex == 1,
              );
              if (res == null) return;
              if (res.action == AddEditAction.save && res.data != null) {
                final d = res.data!;
                // Format waktu perlu penyesuaian jika pakai DateTime asli, bukan string 'Today, hh:mm'
                final timeStr = (d.dueDate != null && d.dueTime != null)
                    ? formatDateTime(d.dueDate!, d.dueTime!) // Buat fungsi helper formatDateTime
                    : (d.dueDate != null ? DateFormat('dd/MM').format(d.dueDate!) : (_tabIndex == 0 ? 'Today' : '—'));

                final newItem = _Item(
                  d.title,
                  d.tag,
                  timeStr, // Gunakan string waktu yang diformat
                  d.done,
                  chipColor: d.chipColor,
                );
                setState(() {
                  if (_tabIndex == 0)
                    _tasks.add(newItem);
                  else
                    _habits.add(newItem);
                });
              }
            },
            child: Icon(
              Icons.add,
               color: isLight ? Colors.white : Colors.black,
               ),
          ),
        ],
      ),


      // === Bottom bar (Navbar tetap sama) ===
      bottomNavigationBar: BottomAppBar(
         color: cs.surface, // Warna dari tema
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _BottomItem(
                icon: Image.asset(
                  'assets/home.png',
                  width: 24, height: 24,
                  color: _bottomIndex == 0 ? kPrimary500 : Colors.grey,
                ),
                label: 'Home',
                selected: _bottomIndex == 0,
                onTap: () => Navigator.pushReplacementNamed(context, HomePage.routeName),
              ),
              _BottomItem(
                icon: Image.asset(
                  'assets/calendar.png',
                  width: 24, height: 24,
                  color: _bottomIndex == 1 ? kPrimary500 : Colors.grey,
                ),
                label: 'Calendar',
                selected: _bottomIndex == 1,
                onTap: () => Navigator.pushReplacementNamed(context, CalendarPage.routeName),
              ),
              const Spacer(),
              _BottomItem(
                icon: Image.asset(
                  'assets/statspage.png', // <-- Pastikan path benar
                  width: 24, height: 24,
                  color: _bottomIndex == 2 ? kPrimary500 : Colors.grey,
                ),
                label: 'Stats',
                selected: _bottomIndex == 2,
                onTap: () {}, // Sudah di sini
              ),
              _BottomItem(
                icon: Image.asset(
                  'assets/profile.png',
                  width: 24, height: 24,
                  color: _bottomIndex == 3 ? kPrimary500 : Colors.grey,
                ),
                label: 'Profile',
                selected: _bottomIndex == 3,
                onTap: () => Navigator.pushReplacementNamed(context, ProfilePage.routeName),
              ),
            ],
          ),
        ),
      ),

      // ==== BODY ====
      body: Stack(
        children: [
          // Header gradient (Dinamis)
          Container(
            height: 220,
            decoration: BoxDecoration( // <-- Hapus const
              gradient: LinearGradient(
                // --- WARNA GRADASI DINAMIS REDUP ---
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

          // Header content (Tetap sama, warna teks putih aman)
          SafeArea(
             bottom: false, // <-- Hindari padding bawah SafeArea
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
                   const Icon(
                     Icons.notifications_none_rounded,
                     color: Colors.white,
                   ),
                 ],
              ),
            ),
          ),

          // Panel isi (Background dari tema)
          Positioned.fill(
            top: 150,
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface, // <-- Warna background panel dari tema
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [ // Shadow hanya di light mode
                  if (isLight)
                    const BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 18,
                      offset: Offset(0, -4),
                    ),
                ],
              ),
              child: ListView( // Ganti jadi ListView agar bisa scroll jika konten panjang
                padding: EdgeInsets.fromLTRB(
                  0, 0, 0,
                  // Padding bawah agar tidak tertutup navbar + FAB
                  110 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  // Tabs paling atas
                  _SegmentedTabs(
                    index: _tabIndex,
                    onChanged: (v) => setState(() => _tabIndex = v),
                  ),
                  const SizedBox(height: 12),

                  // Progress chart (Sudah di-refactor jadi Dark Mode Ready)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _LineChartCard(isHabit: _tabIndex == 1),
                  ),
                  const SizedBox(height: 16),

                  // Summary card (Sudah di-refactor jadi Dark Mode Ready)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: _SummaryCard(
                          bgColor: cs.surfaceVariant.withOpacity(isLight ? 1.0 : 0.3), // Background disesuaikan
                          fgColor: cs.onSurface, // Warna teks dari tema
                          iconBg: (_tabIndex == 0 ? kTaskGreen : kPrimary500).withOpacity(0.12),
                          shadow: isLight ? const BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ) : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List items (Sudah di-refactor jadi Dark Mode Ready)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: _currentList.map((e) {
                        final isHabit = _tabIndex == 1;
                        return _ItemTile(
                          item: e,
                          isHabit: isHabit,
                          onToggle: () => _toggle(e),
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

  // --- Helper function untuk format DateTime & TimeOfDay ---
  String formatDateTime(DateTime date, TimeOfDay time) {
     final now = DateTime.now();
     final today = DateTime(now.year, now.month, now.day);
     final itemDate = DateTime(date.year, date.month, date.day);

     final String timeStr = time.format(context); // Format waktu

     if (itemDate == today) {
       return 'Today, $timeStr';
     } else {
       // Format tanggal saja jika bukan hari ini
       return '${DateFormat('dd/MM').format(date)}, $timeStr';
     }
   }

} // <-- Akhir _StatsPageState


/* ====================== UI PARTS (DIMODIFIKASI) ====================== */

// --- _BottomItem (Tetap sama) ---
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
     final cs = Theme.of(context).colorScheme; // Ambil color scheme
     final Color color = selected ? kPrimary500 : cs.onSurface.withOpacity(0.60); // Warna ikon/teks navbar

     return Expanded(
       child: InkWell(
         onTap: onTap,
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             SizedBox(width: 24, height: 24, child: icon), // Icon dari parameter
             const SizedBox(height: 4),
             Text(label, style: GoogleFonts.inter(
                 color: color, fontSize: 12, fontWeight: FontWeight.w500)),
           ],
         ),
       ),
     );
   }
}


// --- _SegmentedTabs (Warna teks & divider disesuaikan) ---
class _SegmentedTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _SegmentedTabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final Color dividerColor = Theme.of(context).dividerColor.withOpacity(.35);

    return Row(
      children: [
        Expanded(
          child: _tabButton(
            context,
            'Task',
            selected: index == 0,
            color: kTaskGreen,
            divider: dividerColor,
            onTap: () => onChanged(0),
          ),
        ),
        Expanded(
          child: _tabButton(
            context,
            'Habit',
            selected: index == 1,
            color: kPrimary500,
            divider: dividerColor,
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
    final Color defaultTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black54;

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
            color: selected ? color : defaultTextColor,
          ),
        ),
      ),
    );
  }
}

// --- _LineChartCard (Disesuaikan untuk Dark Mode) ---
class _LineChartCard extends StatelessWidget {
  final bool isHabit;
  const _LineChartCard({required this.isHabit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final accent = isHabit ? kPrimary500 : kTaskGreen;
    final area2 = isHabit ? const Color(0xFF4FC3F7) : const Color(0xFF00C48C);

    final Color gridColor = cs.outlineVariant.withOpacity(0.3); // Warna grid dinamis
    final Color titleColor = cs.onSurface; // Warna judul "Progress"
    final Color subtitleColor = cs.onSurfaceVariant; // Warna subjudul
    final Color axisLabelColor = cs.onSurfaceVariant; // Warna label sumbu
    final Color tooltipBgColor = isLight ? Colors.black87 : Colors.grey.shade800; // Background tooltip

    final values = isHabit
        ? [0.25, .35, .30, .45, .40, .55, .50, .58, .52, .70, .85]
        : [0.35, .45, .38, .60, .50, .70, .55, .62, .58, .75, .90];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(isLight ? 0.5 : 0.3), // Background card chart
        borderRadius: BorderRadius.circular(18),
        boxShadow: [ // Shadow hanya di light mode
           if (isLight)
             const BoxShadow(
               color: Color(0x11000000),
               blurRadius: 8,
               offset: Offset(0, 2),
             ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: accent.withOpacity(.15),
                child: Icon(Icons.show_chart_rounded, size: 16, color: accent),
              ),
              const SizedBox(width: 8),
              Text(
                'Progress',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: titleColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Comparison by week',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: 0, maxY: 1, minX: 1, maxX: values.length.toDouble(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.25,
                  getDrawingHorizontalLine: (y) {
                    final pct = (y * 100).round();
                    if (pct % 25 != 0) return const FlLine(color: Colors.transparent);
                    return FlLine(
                      color: gridColor, // <-- Warna tema
                      strokeWidth: 1,
                      dashArray: [4, 6],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final pct = (value * 100).round();
                        const keep = {0, 25, 50, 75, 100};
                        if (!keep.contains(pct)) return const SizedBox.shrink();
                        return Text(
                          '$pct%',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: axisLabelColor, // <-- Warna tema
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          (value.toInt() + 3).toString(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: axisLabelColor, // <-- Warna tema
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < values.length; i++)
                        FlSpot((i + 1).toDouble(), values[i]),
                    ],
                    isCurved: true,
                    color: accent,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          accent.withOpacity(.35),
                          area2.withOpacity(.15),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => tooltipBgColor, // <-- Warna tema
                    getTooltipItems: (spots) => spots.map((s) {
                      final pct = (s.y * 100).round();
                      return LineTooltipItem(
                        '$pct%',
                        GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- _SummaryCard (Disesuaikan untuk Dark Mode) ---
class _SummaryCard extends StatelessWidget {
  final Color bgColor;
  final Color fgColor; // Warna teks utama
  final Color iconBg;
  final BoxShadow? shadow;

  const _SummaryCard({
    required this.bgColor,
    required this.fgColor,
    required this.iconBg,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final Color successColor = Colors.green.shade600;
    final Color failColor = Colors.red.shade600;
    final Color subtitleColor = fgColor.withOpacity(0.7); // Warna subjudul dinamis

    Widget stat(String title, String value, double width, {Color? valueColor}) {
      return SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: valueColor ?? fgColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: subtitleColor, // <-- Warna subjudul dinamis
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: shadow != null ? [shadow!] : [],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          const colGap = 14.0;
          final itemW = (c.maxWidth - colGap) / 2;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: iconBg,
                    child: Icon(Icons.insights_rounded, size: 16, color: fgColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Summary",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: fgColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "You’re 75% toward your daily goals",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: subtitleColor, // <-- Warna subjudul dinamis
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: colGap, runSpacing: 10,
                alignment: WrapAlignment.center, runAlignment: WrapAlignment.center,
                children: [
                  stat('Success Rate', '75%', itemW, valueColor: successColor),
                  stat('Completed', '28', itemW),
                  stat('Skipped', '03', itemW),
                  stat('Failed', '3', itemW, valueColor: failColor),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// Model _Item tetap sama
class _Item {
   final String title;
   final String chip;
   final String time;
   bool done;
   final Color chipColor;
   _Item(this.title, this.chip, this.time, this.done, {required this.chipColor});
}


// --- _ItemTile (Disesuaikan untuk Dark Mode) ---
class _ItemTile extends StatelessWidget {
  final _Item item;
  final bool isHabit;
  final VoidCallback onToggle;
  const _ItemTile({
    required this.item,
    required this.isHabit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final accent = isHabit ? kPrimary500 : kTaskGreen;
    final Color bgSoft = isLight
          ? accent.withOpacity(.10)
          : cs.surfaceVariant.withOpacity(0.3);
    final Color border = cs.outlineVariant.withOpacity(isLight ? 0.35 : 0.6);
    final Color subtleColor = cs.onSurfaceVariant; // Warna abu-abu dari tema

    return Container(
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
                borderColor: isLight ? accent : cs.outlineVariant // Border abu di dark mode
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
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    // Warna teks utama otomatis dari tema
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Chip(text: item.chip, color: item.chipColor), // Chip pakai warna item
                    const SizedBox(width: 8),
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: subtleColor, // <-- Warna tema
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.time,
                      style: GoogleFonts.inter(
                        color: subtleColor, // <-- Warna tema
                        fontSize: 12, // Ukuran font bisa disesuaikan
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tambahkan ikon titik tiga jika perlu
           Icon(Icons.more_horiz_rounded, color: subtleColor),
        ],
      ),
    );
  }
}

// --- _CheckCircle (Border disesuaikan) ---
class _CheckCircle extends StatelessWidget {
  final bool checked;
  final Color color;
  final Color? borderColor;

  const _CheckCircle({required this.checked, required this.color, this.borderColor});

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


// --- _Chip (Background & Foreground disesuaikan) ---
class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
     final bool isLight = Theme.of(context).brightness == Brightness.light;
     final Color chipBg = isLight ? color.withOpacity(.18) : color.withOpacity(0.3);
     final Color chipFg = isLight ? color : HSLColor.fromColor(color).withLightness(0.7).toColor();


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11, // Ukuran font bisa disesuaikan
          color: chipFg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}