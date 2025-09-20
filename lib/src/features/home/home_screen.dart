import 'package:flutter/material.dart';
import '../../features/logging/logging_sheets.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
  final List<Reminder> _reminders = [
    Reminder(
      id: '1',
      title: 'Medicine',
      time: '8:00 AM',
      isCompleted: false,
    ),
  ];

  void _showAddReminderDialog(BuildContext context) {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
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
                  timeController.text = time.format(context);
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
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _reminders.add(Reminder(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    time: selectedTime.format(context),
                    isCompleted: false,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showNotificationPopup(BuildContext context) {
    final hasNotifications = _reminders.any((r) => !r.isCompleted);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: hasNotifications 
          ? _NotificationContent(reminders: _reminders.where((r) => !r.isCompleted).toList())
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
        title: Column(children: [
          Text('Hello, Ahmed', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          Text('Today ${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}', style: Theme.of(context).textTheme.bodySmall),
        ]),
        actions: [
          IconButton(
            onPressed: () => _showNotificationPopup(context),
            icon: const Icon(Icons.notifications_outlined),
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
              _riskCard(context, percent: 0.63, isTablet: isTablet),
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
              
              // Reminders Section
              Text('Reminders', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ..._reminders.map((reminder) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReminderCard(
                  icon: Icons.notifications_outlined,
                  time: reminder.time,
                  title: reminder.title,
                  isCompleted: reminder.isCompleted,
                  onTap: () {
                    setState(() {
                      final index = _reminders.indexWhere((r) => r.id == reminder.id);
                      if (index != -1) {
                        final oldReminder = _reminders[index];
                        _reminders[index] = Reminder(
                          id: oldReminder.id,
                          title: oldReminder.title,
                          time: oldReminder.time,
                          isCompleted: !oldReminder.isCompleted,
                        );
                      }
                    });
                  },
                  onDelete: () {
                    setState(() {
                      _reminders.removeWhere((r) => r.id == reminder.id);
                    });
                  },
                ),
              )).toList(),
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
    if (isDesktop) {
      // Desktop: 3 columns
      return Row(
        children: const [
          Expanded(child: _GaugeCard(title: 'Calories', value: 3480, unit: 'Kcal', icon: Icons.local_fire_department_outlined)),
          SizedBox(width: 16),
          Expanded(child: _GaugeCard(title: 'carb', value: 3480, unit: 'Kcal', icon: Icons.restaurant_outlined)),
          SizedBox(width: 16),
          Expanded(child: _GaugeCard(title: 'Protein', value: 120, unit: 'g', icon: Icons.fitness_center_outlined)),
        ],
      );
    } else if (isTablet) {
      // Tablet: 2 columns
      return Row(
        children: const [
          Expanded(child: _GaugeCard(title: 'Calories', value: 3480, unit: 'Kcal', icon: Icons.local_fire_department_outlined)),
          SizedBox(width: 16),
          Expanded(child: _GaugeCard(title: 'carb', value: 3480, unit: 'Kcal', icon: Icons.restaurant_outlined)),
        ],
      );
    } else {
      // Mobile: 2 columns
      return Row(
        children: const [
          Expanded(child: _GaugeCard(title: 'Calories', value: 3480, unit: 'Kcal', icon: Icons.local_fire_department_outlined)),
          SizedBox(width: 12),
          Expanded(child: _GaugeCard(title: 'carb', value: 3480, unit: 'Kcal', icon: Icons.restaurant_outlined)),
        ],
      );
    }
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
            percent: percent,
            backgroundColor: Colors.white.withOpacity(0.15),
            progressColor: const Color(0xFF7ED957),
            circularStrokeCap: CircularStrokeCap.round,
            center: Container(
              width: isTablet ? 90 : 66,
              height: isTablet ? 90 : 66,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                '63%',
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
  final int value;
  final String unit;
  final IconData icon;
  const _GaugeCard({required this.title, required this.value, required this.unit, required this.icon});

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
    
    return Container(
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
              percent: 0.75, // 75% progress as shown in image
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
                    '$value',
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
    );
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




