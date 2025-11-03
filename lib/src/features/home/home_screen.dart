import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/logging/logging_sheets.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../services/user_data_service.dart';
import '../../services/notification_service.dart';

class Reminder {
  final String id;
  final String title;
  final String time;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.title,
    required this.time,
    required this.isCompleted,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<String> _loadDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'User';
    final authName = user.displayName;
    try {
      final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snap.data();
      final name = (data != null ? data['displayName'] as String? : null);
      return name?.isNotEmpty == true ? name! : (authName?.isNotEmpty == true ? authName! : 'User');
    } catch (_) {
      return authName?.isNotEmpty == true ? authName! : 'User';
    }
  }

  void _showTodayMeals() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Today\'s Meals', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: UserDataService.instance.streamTodayMealLogs(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final items = snapshot.data ?? const [];
                        if (items.isEmpty) {
                          return const Center(child: Text('No meals logged today'));
                        }
                        return ListView.separated(
                          controller: scrollController,
                          itemBuilder: (context, i) {
                            final m = items[i];
                            return ListTile(
                              leading: const Icon(Icons.restaurant_outlined),
                              title: Text((m['name'] ?? '') as String),
                              subtitle: Text('Calories: ${(m['calories'] ?? 0)}  •  Carbs: ${(m['carbs'] ?? 0)}g'),
                            );
                          },
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemCount: items.length,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<double> _loadRiskPercent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0.0;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('profiles')
        .doc('health_questionnaire')
        .get();
    if (!doc.exists) return 0.0;
    final data = doc.data() ?? {};
    final explicit = data['riskPercent'];
    if (explicit is num) {
      final p = explicit.toDouble();
      return p.clamp(0.0, 1.0);
    }
    final score = data['diabetesRiskScore'];
    if (score is num) {
      return (score.toDouble() / 10).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  CollectionReference<Map<String, dynamic>>? _remindersCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('reminders');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? _remindersStream() {
    final col = _remindersCollection();
    if (col == null) return null;
    return col.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<int>? _pendingCountStream() {
    final col = _remindersCollection();
    if (col == null) return null;
    return col.where('isCompleted', isEqualTo: false).snapshots().map((s) => s.size);
  }

  DateTime _parseNextDateForTime(String timeStr) {
    // expects e.g., "8:00 AM" via TimeOfDay.format
    final now = DateTime.now();
    final regex = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false);
    final m = regex.firstMatch(timeStr.trim());
    if (m == null) return now.add(const Duration(minutes: 1));
    int hour = int.parse(m.group(1)!);
    final minute = int.parse(m.group(2)!);
    final ampm = m.group(3)!.toUpperCase();
    if (ampm == 'PM' && hour != 12) hour += 12;
    if (ampm == 'AM' && hour == 12) hour = 0;
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _scheduleReminderNotification(String docId, String title, String time) async {
    final when = _parseNextDateForTime(time);
    final id = docId.hashCode & 0x7fffffff; // ensure positive int
    await NotificationService.instance.scheduleReminder(
      id: id,
      title: 'Reminder',
      body: title,
      whenLocal: when,
    );
  }

  Future<void> _cancelReminderNotification(String docId) async {
    final id = docId.hashCode & 0x7fffffff;
    await NotificationService.instance.cancel(id);
  }

  Future<void> _addReminder(String title, String time) async {
    final col = _remindersCollection();
    if (col == null) return;
    final doc = await col.add({
      'title': title,
      'time': time,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _scheduleReminderNotification(doc.id, title, time);
  }

  Future<void> _toggleReminder(String id, bool current) async {
    final col = _remindersCollection();
    if (col == null) return;
    await col.doc(id).update({'isCompleted': !current});
    if (current) {
      // transitioning from completed -> active: schedule
      final snap = await col.doc(id).get();
      final data = snap.data();
      if (data != null) {
        await _scheduleReminderNotification(id, (data['title'] ?? '') as String, (data['time'] ?? '') as String);
      }
    } else {
      // transitioning to completed: cancel
      await _cancelReminderNotification(id);
    }
  }

  Future<void> _deleteReminder(String id) async {
    final col = _remindersCollection();
    if (col == null) return;
    await _cancelReminderNotification(id);
    await col.doc(id).delete();
  }

  Future<List<Reminder>> _fetchPendingReminders() async {
    final col = _remindersCollection();
    if (col == null) return [];
    final qs = await col.where('isCompleted', isEqualTo: false).limit(50).get();
    final items = qs.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'title': (data['title'] ?? '') as String,
        'time': (data['time'] ?? '') as String,
        'isCompleted': (data['isCompleted'] ?? false) as bool,
        'createdAt': data['createdAt'],
      };
    }).toList();
    items.sort((a, b) {
      final ta = a['createdAt'];
      final tb = b['createdAt'];
      final da = ta is Timestamp ? ta.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
      final db = tb is Timestamp ? tb.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });
    return items.map((m) => Reminder(
      id: m['id'] as String,
      title: m['title'] as String,
      time: m['time'] as String,
      isCompleted: m['isCompleted'] as bool,
    )).toList();
  }

  void _showAddReminderDialog(BuildContext context) {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Reminder Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (time != null) {
                  selectedTime = time;
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                ),
                child: Text(selectedTime.format(context)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await _addReminder(titleController.text, selectedTime.format(context));
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showNotificationPopup(BuildContext context) async {
    final pending = await _fetchPendingReminders();
    final hasNotifications = pending.isNotEmpty;
    
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: hasNotifications 
          ? _NotificationContent(reminders: pending)
          : _EmptyNotificationContent(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: FutureBuilder<String>(
          future: _loadDisplayName(),
          builder: (context, snapshot) {
            final name = snapshot.data ?? 'User';
            return Column(children: [
              Text('Hello, $name', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text('Today ${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}', style: Theme.of(context).textTheme.bodySmall),
            ]);
          },
        ),
        actions: [
          StreamBuilder<int>(
            stream: _pendingCountStream(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => _showNotificationPopup(context),
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 18),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isTablet ? 24 : 16,
          isTablet ? 24 : 16,
          isTablet ? 24 : 16,
          (isTablet ? 24 : 16) + 8.5,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1200 : double.infinity,
          ),
          child: Column(
        children: [
              FutureBuilder<double>(
                future: _loadRiskPercent(),
                builder: (context, snapshot) {
                  final percent = snapshot.data ?? 0.0;
                  return _riskCard(context, percent: percent, isTablet: isTablet);
                },
              ),
              SizedBox(height: isTablet ? 24 : 16),
              
              // Quick Actions Section
              Padding(
                padding: const EdgeInsets.only(bottom: 8.5),
                child: _buildQuickActions(context, isTablet, isDesktop),
              ),
              SizedBox(height: isTablet ? 24 : 16),
              
              // Daily Overview Section
              Text('Daily Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _buildDailyOverview(context, isTablet, isDesktop),
              SizedBox(height: isTablet ? 24 : 16),
              
              // Reminders Section (from Firestore)
              Text('Reminders', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _remindersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  final docs = snapshot.data?.docs ?? [];
                  return Column(
                    children: docs.map((d) {
                      final data = d.data();
                      final reminder = Reminder(
                        id: d.id,
                        title: (data['title'] ?? '') as String,
                        time: (data['time'] ?? '') as String,
                        isCompleted: (data['isCompleted'] ?? false) as bool,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReminderCard(
                          icon: Icons.notifications_outlined,
                          time: reminder.time,
                          title: reminder.title,
                          isCompleted: reminder.isCompleted,
                          onTap: () async => _toggleReminder(reminder.id, reminder.isCompleted),
                          onDelete: () async => _deleteReminder(reminder.id),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              _AddReminderButton(
                onTap: () => _showAddReminderDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyOverview(BuildContext context, bool isTablet, bool isDesktop) {
    const goalCalories = 2000; // TODO: fetch from user profile if available
    const goalCarbs = 250.0;   // grams; TODO: fetch from user profile if available
    return StreamBuilder<Map<String, dynamic>>(
      stream: UserDataService.instance.streamSummary(),
      builder: (context, snapshot) {
        final calories = (snapshot.data?['calories'] as num?)?.toInt() ?? 0;
        final carbs = (snapshot.data?['carbs'] as num?)?.toDouble() ?? 0.0;
        if (isDesktop) {
          return Row(
            children: [
              Expanded(child: _GaugeCard(title: 'Calories', value: calories, unit: 'Kcal', icon: Icons.local_fire_department_outlined, goal: goalCalories, onTap: _showTodayMeals)),
              const SizedBox(width: 16),
              Expanded(child: _GaugeCard(title: 'Carbs', value: carbs, unit: 'g', icon: Icons.restaurant_outlined, goal: goalCarbs, onTap: _showTodayMeals)),
              const SizedBox(width: 16),
              Expanded(child: _GaugeCard(title: 'Protein', value: 120, unit: 'g', icon: Icons.fitness_center_outlined, onTap: _showTodayMeals)),
            ],
          );
        } else if (isTablet) {
          return Row(
            children: [
              Expanded(child: _GaugeCard(title: 'Calories', value: calories, unit: 'Kcal', icon: Icons.local_fire_department_outlined, goal: goalCalories, onTap: _showTodayMeals)),
              const SizedBox(width: 16),
              Expanded(child: _GaugeCard(title: 'Carbs', value: carbs, unit: 'g', icon: Icons.restaurant_outlined, goal: goalCarbs, onTap: _showTodayMeals)),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: _GaugeCard(title: 'Calories', value: calories, unit: 'Kcal', icon: Icons.local_fire_department_outlined, goal: goalCalories, onTap: _showTodayMeals)),
              const SizedBox(width: 12),
              Expanded(child: _GaugeCard(title: 'Carbs', value: carbs, unit: 'g', icon: Icons.restaurant_outlined, goal: goalCarbs, onTap: _showTodayMeals)),
            ],
          );
        }
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isTablet, bool isDesktop) {
    final appointmentAction = _ActionItem(
      icon: Icons.calendar_today_outlined,
      title: 'Book Appointment',
      subtitle: 'Schedule visit',
      color: const Color(0xFF38A169),
      gradient: const LinearGradient(
        colors: [Color(0xFF38A169), Color(0xFF68D391)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onTap: () {},
    );

    final otherActions = [
      _ActionItem(
        icon: Icons.monitor_heart_outlined,
        title: 'Sugar Level',
        subtitle: 'Log reading',
        color: const Color(0xFFE53E3E),
        gradient: const LinearGradient(
          colors: [Color(0xFFE53E3E), Color(0xFFFC8181)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () async => await showSugarLogSheet(context),
      ),
      _ActionItem(
        icon: Icons.local_fire_department_outlined,
        title: 'Calories',
        subtitle: 'Track intake',
        color: const Color(0xFFED8936),
        gradient: const LinearGradient(
          colors: [Color(0xFFED8936), Color(0xFFF6AD55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () async => await showCaloriesLogSheet(context),
      ),
      _ActionItem(
        icon: Icons.local_drink_outlined,
        title: 'Water',
        subtitle: 'Hydration',
        color: const Color(0xFF3182CE),
        gradient: const LinearGradient(
          colors: [Color(0xFF3182CE), Color(0xFF63B3ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () async => await showWaterLogSheet(context),
      ),
    ];

    return Column(
      children: [
        // Wide appointment card at the top
        _WideActionCard(action: appointmentAction),
        const SizedBox(height: 16),
        // Scrollable row of other actions
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: otherActions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: _NewActionCard(action: otherActions[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _riskCard(BuildContext context, {required double percent, required bool isTablet}) {
    final pctText = (percent * 100).round();
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Your overall sugar\nToday ${_monthName(DateTime.now().month)} ${DateTime.now().day}.',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
          ),
          CircularPercentIndicator(
            radius: isTablet ? 60 : 43,
            lineWidth: isTablet ? 12 : 10,
            percent: percent.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.15),
            progressColor: const Color(0xFF7ED957),
            circularStrokeCap: CircularStrokeCap.round,
            center: Container(
              width: isTablet ? 90 : 66,
              height: isTablet ? 90 : 66,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                '$pctText%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E86DE),
                  fontSize: isTablet ? 20 : 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[m - 1];
  }
}

class _GaugeCard extends StatelessWidget {
  final String title;
  final num value;
  final String unit;
  final IconData icon;
  final num? goal;
  final VoidCallback? onTap;
  const _GaugeCard({required this.title, required this.value, required this.unit, required this.icon, this.goal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;
    
    final radius = isDesktop ? 60 : (isTablet ? 55 : 50);
    final iconSize = isDesktop ? 24 : (isTablet ? 22 : 20);
    final titleFontSize = isDesktop ? 14 : (isTablet ? 13 : 12);
    final valueFontSize = isDesktop ? 20 : (isTablet ? 19 : 18);
    final unitFontSize = isDesktop ? 12 : (isTablet ? 11 : 10);
    
    return InkWell(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2E86DE), size: iconSize.toDouble()),
          SizedBox(height: isTablet ? 16.0 : 12.0),
          Center(
            child: CircularPercentIndicator(
              radius: radius.toDouble(),
              lineWidth: isTablet ? 10 : 8,
              percent: (() {
                final g = goal ?? 0;
                if (g == 0) return 0.0;
                final p = (value.toDouble() / g.toDouble()).clamp(0.0, 1.0);
                return p;
              })(),
              backgroundColor: Colors.green.shade100,
              progressColor: const Color(0xFF7ED957),
              circularStrokeCap: CircularStrokeCap.round,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E86DE),
                      fontSize: titleFontSize.toDouble(),
                    ),
                  ),
                  Text(
                    value is int ? '${value as int}' : value.toStringAsFixed(0),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E86DE),
                      fontSize: valueFontSize.toDouble(),
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E86DE),
                      fontSize: unitFontSize.toDouble(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class _ReminderCard extends StatelessWidget {
  final IconData icon;
  final String time;
  final String title;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  
  const _ReminderCard({
    required this.icon,
    required this.time,
    required this.title,
    required this.isCompleted,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? Colors.green.shade200 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : const Color(0xFF2E86DE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? Colors.green.shade700 : const Color(0xFF2E86DE),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isCompleted ? Colors.green.shade600 : const Color(0xFF2E86DE),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddReminderButton extends StatelessWidget {
  final VoidCallback onTap;
  
  const _AddReminderButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Reminder',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  final List<Reminder> reminders;
  
  const _NotificationContent({required this.reminders});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.blue.shade600, size: 24),
            const SizedBox(width: 12),
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.blue.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...reminders.map((reminder) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.schedule, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due at ${reminder.time}',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}

class _EmptyNotificationContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.notifications_off_outlined,
          size: 64,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          'No Notifications',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You don\'t have any notifications at the moment.',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final LinearGradient gradient;
  final VoidCallback onTap;
  
  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradient,
    required this.onTap,
  });
}

class _WideActionCard extends StatefulWidget {
  final _ActionItem action;
  
  const _WideActionCard({required this.action});

  @override
  State<_WideActionCard> createState() => _WideActionCardState();
}

class _WideActionCardState extends State<_WideActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.action.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: widget.action.gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.action.color.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            widget.action.icon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.action.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.action.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                      ],
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

class _NewActionCard extends StatefulWidget {
  final _ActionItem action;
  
  const _NewActionCard({required this.action});

  @override
  State<_NewActionCard> createState() => _NewActionCardState();
}

class _NewActionCardState extends State<_NewActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.action.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
             height: 120,
              decoration: BoxDecoration(
                gradient: widget.action.gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.action.color.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            widget.action.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.action.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.action.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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




