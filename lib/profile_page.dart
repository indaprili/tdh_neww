// profile_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- Import Google Fonts
import 'calender_page.dart';
import 'home_page.dart';
import 'stats_page.dart';
import 'app_theme.dart'; // Pastikan file ini ada dan benar
import 'add_edit_item_sheet.dart'; // <-- Pastikan import ini ada

const kPrimary500 = Color(0xFF1778FB);
const kGreen200 = Color(0xFF8EE7C4);

// Warna Gradasi Dark Mode (Campuran dengan Hitam)
const double kDarkMixPercent = 0.3; // 30% campuran hitam

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _bottomIndex = 3; // aktif di Profile
  String _language = 'English';
  bool _calendarSync = true;

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 260;
    final themeCtrl = AppTheme.of(context);
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      extendBody: true,

      // ==== FAB (konsisten dgn halaman lain, onPressed diperbaiki) ====
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
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
          ),
          FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: kPrimary500,
            // --- onPressed DIPERBAIKI ---
            onPressed: () async { // <-- Tambah async
              final res = await AddEditItemSheet.show(
                context,
                isHabit: false, // Default Task di Profile Page
                initial: ItemData( // Default data untuk item baru
                  title: '',
                  description: '',
                  tag: 'Work',
                  isHabit: false,
                  dueDate: DateTime.now(),
                  dueTime: TimeOfDay.now(),
                  recurrence: 'No Repeat',
                ),
              );

              // Logika setelah sheet ditutup (opsional)
              if (res == null) return;
              if (res.action == AddEditAction.save && res.data != null) {
                if(mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${res.data!.isHabit ? "Habit" : "Task"} "${res.data!.title}" saved!')),
                  );
                }
              }
            },
            // --- Akhir onPressed ---
            child: Icon(
              Icons.add,
               color: isLight ? Colors.white : Colors.black,
               ),
          ),
        ],
      ),

      // ---- Bottom Navigation Bar ----
      bottomNavigationBar: BottomAppBar(
        color: cs.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _BottomItem(
                icon: Image.asset(
                  'assets/home.png', // Pastikan path benar
                  width: 24,
                  height: 24,
                  color: _bottomIndex == 0 ? kPrimary500 : Colors.grey,
                ),
                label: 'Home',
                selected: _bottomIndex == 0,
                onTap: () => Navigator.pushReplacementNamed(context, HomePage.routeName),
              ),
              _BottomItem(
                icon: Image.asset(
                  'assets/calendar.png', // Pastikan path benar
                  width: 24,
                  height: 24,
                   color: _bottomIndex == 1 ? kPrimary500 : Colors.grey,
                ),
                label: 'Calendar',
                selected: _bottomIndex == 1,
                onTap: () => Navigator.pushReplacementNamed(context, CalendarPage.routeName),
              ),
              const Spacer(),
              _BottomItem(
                icon: Image.asset(
                  'assets/stats.png', // Pastikan path benar
                  width: 24,
                  height: 24,
                   color: _bottomIndex == 2 ? kPrimary500 : Colors.grey,
                ),
                label: 'Stats',
                selected: _bottomIndex == 2,
                onTap: () => Navigator.pushReplacementNamed(context, StatsPage.routeName),
              ),
              _BottomItem(
                icon: Image.asset(
                  'assets/profilepage.png', // Pastikan path benar
                  width: 24,
                  height: 24,
                   color: _bottomIndex == 3 ? kPrimary500 : Colors.grey,
                ),
                label: 'Profile',
                selected: _bottomIndex == 3,
                onTap: () {}, // Sudah di sini
              ),
            ],
          ),
        ),
      ),

      // ==== BODY: header gradient + panel overlap ====
      body: Column(
        children: [
          // Header gradient (Dinamis dengan warna lebih gelap)
          Container(
            height: headerHeight,
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
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Settings',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: !isLight
                        ? Colors.white.withOpacity(0.18)
                        : Colors.black.withOpacity(0.18),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Qoqo',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: _onEditProfile,
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/editprofile.png', // Pastikan path benar
                          width: 18,
                          height: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'qoulansadiyda22@gmail.com',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Panel isi (Expanded) + overlap -36
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -36),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    if (isLight)
                      const BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      ),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 110),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _SettingsCard(
                      children: [
                        // Dark Mode (Toggle Kustom)
                        _CustomToggleRow(
                          imagePath: isLight ? 'assets/lightmode.png' : 'assets/darkmode.png',
                          iconBg: const Color(0xFFFFF3C9),
                          title: 'Light Mode',
                           titleStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
                          value: !isLight,
                           activeImage: 'assets/toggledark.png',
                           inactiveImage: 'assets/togglelight.png',
                          onChanged: (v) => themeCtrl.setDark(v),
                        ),

                        // Notifications
                        _ArrowRow(
                           imagePath: 'assets/notification.png',
                          iconBg: const Color(0xFFFFE5E5),
                          title: 'Notifications',
                           titleStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
                          onTap: () => _toast('Open notifications settings'),
                        ),

                        // Language
                        _ArrowRow(
                           imagePath: 'assets/language.png',
                          iconBg: const Color(0xFFE7F0FF),
                          title: 'Language',
                           titleStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
                          trailingText: _language,
                          onTap: () async {
                            final lang = await _pickLanguage(context, _language);
                            if (!mounted) return;
                            if (lang != null) setState(() => _language = lang);
                          },
                        ),

                        // Calendar Sync (Switch Bawaan, ikon aset)
                        _SwitchRow(
                           imagePath: 'assets/Synchronize.png',
                          iconBg: const Color(0xFFEAF7EF),
                          title: 'Calendar Sync',
                           titleStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
                          value: _calendarSync,
                          onChanged: (v) => setState(() => _calendarSync = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI HELPER DI DALAM CLASS ---

  void _onEditProfile() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Edit Profile'),
        content: Text('Implement your edit flow here.'),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<String?> _pickLanguage(BuildContext context, String current) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: 'English',
              groupValue: current,
              onChanged: (v) => Navigator.pop(context, v),
              title: const Text('English'),
              activeColor: kPrimary500,
            ),
            RadioListTile<String>(
              value: 'Bahasa Indonesia',
              groupValue: current,
              onChanged: (v) => Navigator.pop(context, v),
              title: const Text('Bahasa Indonesia'),
              activeColor: kPrimary500,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
} // <-- AKHIR DARI CLASS _ProfilePageState


/* ================== Widgets kecil (Dimodifikasi) ================== */

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
    final cs = Theme.of(context).colorScheme;
    final Color color = selected ? kPrimary500 : cs.onSurface.withOpacity(0.60);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 24, height: 24, child: icon),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(
                color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final dividerColor = isLight ? cs.outlineVariant.withOpacity(0.4) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (isLight)
            const BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
        ],
        // border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(children.length, (index) {
          final child = children[index];
          final bool isLast = index == children.length - 1;

          return Container(
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: dividerColor,
                        width: 1.0,
                      ),
                    ),
            ),
            child: child,
          );
        }),
      ),
    );
  }
}

class _ImageAssetBadge extends StatelessWidget {
  final String imagePath;
  final Color bg;

  const _ImageAssetBadge({required this.imagePath, required this.bg});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgAdj = isDark ? bg.withOpacity(0.18) : bg;
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgAdj,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        imagePath,
        width: 18,
        height: 18,
      ),
    );
  }
}

class _ArrowRow extends StatelessWidget {
  final String imagePath;
  final Color iconBg;
  final String title;
  final TextStyle? titleStyle;
  final String? trailingText;
  final VoidCallback? onTap;
  const _ArrowRow({
    required this.imagePath,
    required this.iconBg,
    required this.title,
    this.titleStyle,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final trailingColor = cs.onSurfaceVariant;

    return ListTile(
      leading: _ImageAssetBadge(imagePath: imagePath, bg: iconBg),
      title: Text(
          title,
          style: titleStyle ?? const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText!, style: GoogleFonts.inter(
                color: trailingColor, fontSize: 14, fontWeight: FontWeight.w400)),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, color: trailingColor),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minLeadingWidth: 0,
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String imagePath;
  final Color iconBg;
  final String title;
  final TextStyle? titleStyle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({
    required this.imagePath,
    required this.iconBg,
    required this.title,
    this.titleStyle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: _ImageAssetBadge(imagePath: imagePath, bg: iconBg),
      title: Text(
          title,
          style: titleStyle ?? const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: cs.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minLeadingWidth: 0,
    );
  }
}

class _CustomToggleRow extends StatelessWidget {
  final String imagePath;
  final Color iconBg;
  final String title;
  final TextStyle? titleStyle;
  final bool value; // true jika toggle aktif (dark mode on)
  final String activeImage; // Path gambar saat aktif
  final String inactiveImage; // Path gambar saat non-aktif
  final ValueChanged<bool> onChanged;

  const _CustomToggleRow({
    required this.imagePath,
    required this.iconBg,
    required this.title,
    this.titleStyle,
    required this.value,
    required this.activeImage,
    required this.inactiveImage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _ImageAssetBadge(imagePath: imagePath, bg: iconBg),
      title: Text(
          title,
          style: titleStyle ?? const TextStyle(fontWeight: FontWeight.w600)),
      trailing: GestureDetector(
        onTap: () => onChanged(!value),
        child: Image.asset(
          value ? activeImage : inactiveImage,
          width: 50,
          gaplessPlayback: true,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minLeadingWidth: 0,
    );
  }
}