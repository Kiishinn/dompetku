import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_theme.dart';

class PilihJamSheet extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const PilihJamSheet({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onTimeSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PilihJamSheet(
        initialTime: initialTime,
        onTimeSelected: onTimeSelected,
      ),
    );
  }

  @override
  State<PilihJamSheet> createState() => _PilihJamSheetState();
}

class _PilihJamSheetState extends State<PilihJamSheet> {
  late int selectedHour;
  late int selectedMinute;
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hour;
    selectedMinute = widget.initialTime.minute;
    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  void _updateTime(int hr, int min) {
    setState(() {
      selectedHour = hr;
      selectedMinute = min;
    });
    if (hourController.hasClients) {
      hourController.animateToItem(
        hr,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
    if (minuteController.hasClients) {
      minuteController.animateToItem(
        min,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _useCurrentTime() {
    final now = TimeOfDay.now();
    _updateTime(now.hour, now.minute);
  }

  @override
  Widget build(BuildContext context) {
    final formattedHour = selectedHour.toString().padLeft(2, '0');
    final formattedMinute = selectedMinute.toString().padLeft(2, '0');
    final now = TimeOfDay.now();
    final nowFormattedHour = now.hour.toString().padLeft(2, '0');
    final nowFormattedMinute = now.minute.toString().padLeft(2, '0');

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header Title & Fast 'Jam Sekarang' Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pilih Jam Transaksi (24 Jam)',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              InkWell(
                onTap: _useCurrentTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Sekarang ($nowFormattedHour:$nowFormattedMinute)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Big 24-Hour Display Box
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$formattedHour : $formattedMinute',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'WIB',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Hour & Minute Shortcuts Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // Time presets (Hours): Pagi (08:00), Siang (12:00), Sore (17:00), Malam (20:00)
                ...[
                  {'label': '08:00', 'h': 8, 'm': 0},
                  {'label': '12:00', 'h': 12, 'm': 0},
                  {'label': '17:00', 'h': 17, 'm': 0},
                  {'label': '20:00', 'h': 20, 'm': 0},
                ].map((preset) {
                  final h = preset['h'] as int;
                  final m = preset['m'] as int;
                  final isSel = selectedHour == h && selectedMinute == m;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => _updateTime(h, m),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.primary : AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          preset['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                // Minute shortcuts (:00, :15, :30, :45)
                ...[0, 15, 30, 45].map((m) {
                  final mStr = m.toString().padLeft(2, '0');
                  final isSel = selectedMinute == m;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => _updateTime(selectedHour, m),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.primary : AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          ':$mStr',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 24-Hour Wheels Selector (Jam & Menit)
          SizedBox(
            height: 140,
            child: Row(
              children: [
                // Jam Wheel (00 - 23)
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Jam',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 38,
                          scrollController: hourController,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedHour = index;
                            });
                          },
                          children: List.generate(24, (index) {
                            final valStr = index.toString().padLeft(2, '0');
                            final isSel = selectedHour == index;
                            return Center(
                              child: Text(
                                valStr,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel ? AppTheme.primary : AppTheme.textSecondary,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  ':',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                // Menit Wheel (00 - 59)
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Menit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 38,
                          scrollController: minuteController,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedMinute = index;
                            });
                          },
                          children: List.generate(60, (index) {
                            final valStr = index.toString().padLeft(2, '0');
                            final isSel = selectedMinute == index;
                            return Center(
                              child: Text(
                                valStr,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel ? AppTheme.primary : AppTheme.textSecondary,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                widget.onTimeSelected(
                  TimeOfDay(hour: selectedHour, minute: selectedMinute),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Simpan Jam',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
