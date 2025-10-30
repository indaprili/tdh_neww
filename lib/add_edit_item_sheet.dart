// add_edit_item_sheet.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Import TableCalendar
import 'package:intl/intl.dart'; // Import intl untuk format tanggal

const kPrimary500 = Color(0xFF1778FB);
const kGreen500 = Color(0xFF27AE60); // Warna hijau dari Figma

// Enum dan Class AddEditResult tetap sama...
enum AddEditAction { save, delete, cancel }

class AddEditResult {
  final AddEditAction action;
  final ItemData? data;
  const AddEditResult._(this.action, this.data);
  factory AddEditResult.save(ItemData data) =>
      AddEditResult._(AddEditAction.save, data);
  factory AddEditResult.delete() =>
      const AddEditResult._(AddEditAction.delete, null);
  factory AddEditResult.cancel() =>
      const AddEditResult._(AddEditAction.cancel, null);
}

// Class ItemData tetap sama...
class ItemData {
  String title;
  String description;
  String tag;
  DateTime? dueDate;
  bool done;
  bool isHabit;
  Color chipColor;
  TimeOfDay? dueTime;
  String? recurrence;

  ItemData({
    required this.title,
    required this.description,
    required this.tag,
    required this.isHabit,
    this.dueDate,
    this.done = false,
    Color? chipColor,
    this.dueTime,
    this.recurrence,
  }) : chipColor = chipColor ?? _colorFromTag(tag);

  static Color _colorFromTag(String tag) {
    // Fungsi ini bisa tetap sama, karena warna tag spesifik
    switch (tag.toLowerCase()) {
      case 'work': return const Color(0xFF8E44AD);
      case 'personal': return const Color(0xFFF39C12);
      case 'health': return const Color(0xFF16A085);
      case 'daily': return const Color(0xFF2980B9);
      case 'weekly': return const Color(0xFFE91E63);
      case '30 min': return const Color(0xFF27AE60);
      default: return kPrimary500;
    }
  }
}


class AddEditItemSheet extends StatefulWidget {
  final bool isHabit;
  final ItemData? initial;

  const AddEditItemSheet({super.key, required this.isHabit, this.initial});

  static Future<AddEditResult?> show(
    BuildContext context, {
    required bool isHabit,
    ItemData? initial,
  }) {
    // Ambil warna background dari theme
    final Color modalBgColor = Theme.of(context).colorScheme.surface;

    return showModalBottomSheet<AddEditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: modalBgColor, // Gunakan warna tema
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddEditItemSheet(isHabit: isHabit, initial: initial),
    );
  }

  @override
  State<AddEditItemSheet> createState() => _AddEditItemSheetState();
}

class _AddEditItemSheetState extends State<AddEditItemSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _titleNode = FocusNode();

  late bool _isHabit;
  DateTime? _date;
  TimeOfDay? _time;
  String? _recurrence;
  String _tag = '';
  bool _done = false;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _isHabit = widget.isHabit;
    if (widget.initial != null) {
      final i = widget.initial!;
      _titleCtrl.text = i.title;
      _descCtrl.text = i.description;
      _date = i.dueDate;
      _time = i.dueTime;
      _recurrence = i.recurrence;
      _tag = i.tag;
      _done = i.done;
      _isHabit = i.isHabit;
      _selectedDay = i.dueDate;
      _focusedDay = i.dueDate ?? DateTime.now();
    } else {
      _tag = _isHabit ? 'Daily' : 'Work';
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
      _time = TimeOfDay.now();
      _recurrence = 'No Repeat';
    }
    Future.delayed(
      const Duration(milliseconds: 120),
      () => _titleNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _titleNode.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title can\'t be empty')));
      return;
    }
    final data = ItemData(
      title: title,
      description: _descCtrl.text.trim(),
      tag: _tag,
      isHabit: _isHabit,
      dueDate: _date,
      done: _done,
      dueTime: _time,
      recurrence: _recurrence,
    );
    Navigator.pop(context, AddEditResult.save(data));
  }

  void _delete() {
    Navigator.pop(context, AddEditResult.delete());
  }

  void _pickTag() async {
    final List<String> tags = ['Work', 'Personal', 'Health', 'Daily', 'Weekly', '30 min'];
    final Color modalBgColor = Theme.of(context).colorScheme.surface;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

    final String? picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: modalBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 8),
            const Center(child: _Grabber()),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Tag',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor), // Warna tema
                textAlign: TextAlign.center,
              ),
            ),
            ...tags.map((tag) => ListTile(
              title: Text(tag, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)), // Warna tema
              trailing: _tag == tag ? Icon(Icons.check, color: primaryColor) : null, // Warna tema
              onTap: () => Navigator.pop(ctx, tag),
            )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        _tag = picked;
      });
    }
  }

  Future<void> _pickDate() async {
    final initialDate = _date ?? DateTime.now();
    final initialTime = _time ?? TimeOfDay.now();
    final initialRecurrence = _recurrence ?? 'No Repeat';

    // State sementara untuk kalender sheet
    DateTime tempSelectedDay = _selectedDay ?? initialDate;
    TimeOfDay tempSelectedTime = initialTime;
    String tempRecurrence = initialRecurrence;

    // Ambil warna tema di sini agar tidak perlu diulang di builder
    final Color modalBgColor = Theme.of(context).colorScheme.surface;
    final Color calendarBgColor = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFF9FAFC)
        : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3);
    final Color headerTextColor = Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87;
    final Color defaultTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
    final Color todayBgColor = kGreen500.withOpacity(0.3);
    final Color weekendTextColor = Colors.grey;
    final Color selectedTextColor = Colors.white;

    // Tidak perlu return AddEditResult?, cukup void karena hasil disimpan via setState
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: modalBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder( // StatefulBuilder penting untuk update UI modal
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Custom Header (Cancel | Month Year | Save)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(sheetContext), // Cukup pop
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w600, color: kGreen500),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            // Format header berdasarkan _focusedDay agar update saat ganti bulan
                            DateFormat('MMMM yyyy').format(_focusedDay),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: headerTextColor,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              // Simpan state utama (_date, _time, _recurrence)
                              setState(() {
                                _date = tempSelectedDay;
                                _time = tempSelectedTime;
                                _recurrence = tempRecurrence;
                                _selectedDay = tempSelectedDay; // Update _selectedDay juga
                              });
                              Navigator.pop(sheetContext); // Tutup modal
                            },
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: kGreen500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // TableCalendar dengan warna tema
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: calendarBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2000, 1, 1),
                        lastDay: DateTime.utc(2050, 12, 31),
                        focusedDay: _focusedDay,
                        // Gunakan tempSelectedDay untuk seleksi di modal ini
                        selectedDayPredicate: (day) => isSameDay(tempSelectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                           // Gunakan setModalState untuk update UI modal
                          setModalState(() {
                            tempSelectedDay = selectedDay;
                            _focusedDay = focusedDay; // Update focused agar kalender pindah
                          });
                        },
                        onPageChanged: (focusedDay) {
                           // Gunakan setModalState untuk update header modal saat ganti bulan
                           setModalState(() {
                              _focusedDay = focusedDay;
                           });
                        },
                        headerVisible: false, // Header custom di atas
                        daysOfWeekHeight: 20,

                        // --- STYLE DENGAN WARNA TEMA ---
                        calendarStyle: CalendarStyle(
                          weekendTextStyle: TextStyle(color: weekendTextColor),
                          outsideDaysVisible: false,
                          cellMargin: const EdgeInsets.all(6.0),
                          defaultTextStyle: TextStyle(color: defaultTextColor),
                          todayDecoration: BoxDecoration(
                            color: todayBgColor,
                            shape: BoxShape.circle,
                          ),
                          // Warna teks 'today' mengikuti default text color
                          todayTextStyle: TextStyle(color: defaultTextColor),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(color: weekendTextColor),
                          weekendStyle: TextStyle(color: weekendTextColor),
                          dowTextFormatter: (date, locale) => DateFormat('EE', locale).format(date).substring(0,2),
                        ),
                        calendarBuilders: CalendarBuilders(
                          selectedBuilder: (context, date, focusedDay) {
                            // Builder untuk tanggal yang dipilih (lingkaran hijau)
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: kGreen500, // Warna seleksi tetap hijau
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${date.day}',
                                style: TextStyle(color: selectedTextColor, fontWeight: FontWeight.w600),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Today, Time & Recurrence Section
                    _buildDateTimeRecurrenceRow(
                      context,
                      setModalState, // <-- Kirim setModalState ke child
                      tempSelectedDay, // <-- Kirim state sementara
                      tempSelectedTime, // <-- Kirim state sementara
                      tempRecurrence, // <-- Kirim state sementara
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Widget untuk baris Time, Reminder, Recurrence ---
  // (Fungsi ini sekarang menerima setModalState)
  Widget _buildDateTimeRecurrenceRow(
    BuildContext context,
    StateSetter setModalState, // <-- Parameter setModalState
    DateTime selectedDate,
    TimeOfDay selectedTime,
    String selectedRecurrence,
  ) {
    String formattedDate = DateFormat('dd MMMM yyyy').format(selectedDate);
    String formattedTime = selectedTime.format(context);

    // Ambil warna tema
    final Color iconColor = kGreen500;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final Color dropdownColor = Colors.grey;
    final Color dividerColor = Theme.of(context).dividerColor;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color modalBgColor = Theme.of(context).colorScheme.surface;

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
                // --- UPDATE STATE SEMENTARA DENGAN setModalState ---
                setModalState(() {
                  selectedTime = newTime; // <-- Tidak error lagi
                });
                // Kita simpan hasil akhir ke _time saat tombol Save ditekan
              }
            },
            child: Row(
              children: [
                Icon(Icons.schedule, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Today, $formattedDate - $formattedTime',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: dropdownColor),
              ],
            ),
          ),
          Divider(height: 30, color: dividerColor),

          // Reminder
          GestureDetector(
             onTap: () { /* ... */ },
            child: Row(
              children: [
                Icon(Icons.notifications_none, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '1 hours before',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: dropdownColor),
              ],
            ),
          ),
          Divider(height: 30, color: dividerColor),

          // Recurrence
          GestureDetector(
            onTap: () async {
              final String? pickedRecurrence = await showModalBottomSheet<String>(
                context: context,
                backgroundColor: modalBgColor,
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
                        title: Text('No Repeat', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                        trailing: selectedRecurrence == 'No Repeat' ? Icon(Icons.check, color: primaryColor) : null,
                        onTap: () => Navigator.pop(ctx, 'No Repeat'),
                      ),
                       ListTile(
                        title: Text('Daily', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                        trailing: selectedRecurrence == 'Daily' ? Icon(Icons.check, color: primaryColor) : null,
                        onTap: () => Navigator.pop(ctx, 'Daily'),
                      ),
                      ListTile(
                        title: Text('Weekly', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                        trailing: selectedRecurrence == 'Weekly' ? Icon(Icons.check, color: primaryColor) : null,
                        onTap: () => Navigator.pop(ctx, 'Weekly'),
                      ),
                      ListTile(
                        title: Text('Every Weekend', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                        trailing: selectedRecurrence == 'Every Weekend' ? Icon(Icons.check, color: primaryColor) : null,
                        onTap: () => Navigator.pop(ctx, 'Every Weekend'),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
              if (pickedRecurrence != null) {
                // --- UPDATE STATE SEMENTARA DENGAN setModalState ---
                setModalState(() {
                  selectedRecurrence = pickedRecurrence; // <-- Tidak error lagi
                });
                // Kita simpan hasil akhir ke _recurrence saat tombol Save ditekan
              }
            },
            child: Row(
              children: [
                Icon(Icons.loop_rounded, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedRecurrence,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: dropdownColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // build method utama (sudah dark mode ready)
  @override
  Widget build(BuildContext context) {
    final titleText = widget.initial == null
        ? (_isHabit ? 'New Habit' : 'New Task')
        : (_isHabit ? 'Edit Habit' : 'Edit Task');

    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color headerTextColor = Theme.of(context).textTheme.titleLarge?.color ?? cs.onSurface;
    final Color buttonTextColor = Theme.of(context).textTheme.labelLarge?.color ?? cs.onSurface;
    final Color toolbarBgColor = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFF4F6FA)
        : cs.surfaceVariant.withOpacity(0.5);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, AddEditResult.cancel()),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600, color: buttonTextColor),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    titleText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: headerTextColor,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _save,
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: buttonTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Fields
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Title'),
                  TextField(
                    focusNode: _titleNode,
                    controller: _titleCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: _underline(context,
                      'New ${_isHabit ? "Habit" : "Task"}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Description'),
                  TextField(
                    controller: _descCtrl,
                    minLines: 1,
                    maxLines: 3,
                    decoration: _underline(context, 'Add details'),
                  ),
                ],
              ),
            ),

            // Toolbar bawah (ikon)
            Container(
              margin: const EdgeInsets.only(top: 12, left: 16, right: 16), // Margin ditambah
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 52,
              decoration: BoxDecoration(
                color: toolbarBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month_rounded),
                    color: cs.primary,
                    tooltip: 'Due date',
                  ),
                  IconButton(
                    onPressed: _pickTag,
                    icon: const Icon(Icons.flag_rounded),
                    color: cs.primary,
                    tooltip: 'Tag / Category',
                  ),
                  IconButton(
                    onPressed: () => setState(() => _done = !_done),
                    icon: Icon(
                      _done
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                    ),
                    color: cs.primary,
                    tooltip: _done ? 'Mark as not done' : 'Mark as done',
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _isHabit = !_isHabit),
                    icon: Icon(
                      _isHabit
                          ? Icons.loop_rounded
                          : Icons.task_alt_rounded,
                      size: 18,
                    ),
                    label: Text(_isHabit ? 'Habit' : 'Task'),
                    style: TextButton.styleFrom(foregroundColor: cs.primary),
                  ),
                ],
              ),
            ),

            // Info kecil (tanggal & tag)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: Row(
                children: [
                  if (_date != null)
                    _MiniChip(
                      icon: Icons.event,
                      text: DateFormat('dd/MM/yyyy').format(_date!),
                    ),
                  if (_date != null) const SizedBox(width: 8),
                  _MiniChip(icon: Icons.label_rounded, text: _tag),
                ],
              ),
            ),

            // Delete button
            if (widget.initial != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _delete,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Fungsi _underline (sudah dark mode ready)
  InputDecoration _underline(BuildContext context, String hint) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color hintColor = Theme.of(context).hintColor;
    final Color borderColor = cs.outlineVariant.withOpacity(0.5);

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintColor),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: cs.primary),
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
    );
  }
}

// Widget _FieldLabel (sudah dark mode ready)
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final Color labelColor = Theme.of(context).textTheme.labelSmall?.color ?? Colors.black54;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: labelColor),
      ),
    );
  }
}

// Widget _MiniChip (sudah dark mode ready)
class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MiniChip({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color chipBgColor = cs.primaryContainer.withOpacity(0.4);
    final Color chipIconColor = cs.primary;
    final Color chipTextColor = cs.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipBgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipIconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: chipTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget _Grabber (sudah dark mode ready)
class _Grabber extends StatelessWidget {
  const _Grabber();
  @override
  Widget build(BuildContext context) {
    final Color grabberColor = Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4);
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: grabberColor,
        borderRadius: BorderRadius.circular(999),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}

// Helper isSameDay
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}