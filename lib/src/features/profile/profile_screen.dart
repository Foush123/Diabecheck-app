import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/user_data_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, String>> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {'name': 'User', 'email': ''};
    try {
      final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snap.data();
      final name = (data != null ? data['displayName'] as String? : null) ?? user.displayName ?? 'User';
      final email = user.email ?? '';
      return {'name': name, 'email': email};
    } catch (_) {
      return {'name': user.displayName ?? 'User', 'email': user.email ?? ''};
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _logStream(String uid, String type) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('logs')
        .doc(type)
        .collection('entries')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<Map<String, String>>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          final name = snapshot.data?['name'] ?? 'User';
          final email = snapshot.data?['email'] ?? '';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(leading: const Icon(Icons.person), title: Text(name), subtitle: Text(email)),
              const SizedBox(height: 8),
              if (uid != null) ...[
                _LogsSection(title: 'Recent Sugar Logs', icon: Icons.monitor_heart_outlined, stream: _logStream(uid, 'sugar'), valueKey: 'valueMgdl', unit: 'mg/dL'),
                const SizedBox(height: 12),
                _LogsSection(title: 'Recent Water Intake', icon: Icons.local_drink_outlined, stream: _logStream(uid, 'water'), valueKey: 'cups', unit: 'cups'),
                const SizedBox(height: 12),
                _LogsSection(title: 'Recent Calories', icon: Icons.local_fire_department_outlined, stream: _logStream(uid, 'calories'), valueKey: 'kcal', unit: 'kcal'),
                const SizedBox(height: 24),
                Text('Reports', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _ReportsSection(),
                const Divider(height: 32),
              ],
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LogsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final String valueKey;
  final String unit;

  const _LogsSection({
    required this.title,
    required this.icon,
    required this.stream,
    required this.valueKey,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading logs', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No logs yet'),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final value = data[valueKey];
                  final ts = data['createdAt'];
                  DateTime? when;
                  if (ts is Timestamp) when = ts.toDate();
                  return ListTile(
                    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
                    title: Text(value == null ? '-' : '$value $unit'),
                    subtitle: Text(when == null ? '' : when.toLocal().toString()),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


class _ReportsSection extends StatefulWidget {
  @override
  State<_ReportsSection> createState() => _ReportsSectionState();
}

class _ReportsSectionState extends State<_ReportsSection> {
  String _period = 'daily'; // daily | weekly | monthly

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ChoiceChip(label: const Text('Daily'), selected: _period == 'daily', onSelected: (_) => setState(() => _period = 'daily')),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('Weekly'), selected: _period == 'weekly', onSelected: (_) => setState(() => _period = 'weekly')),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('Monthly'), selected: _period == 'monthly', onSelected: (_) => setState(() => _period = 'monthly')),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          height: 220,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: UserDataService.instance.streamReports(period: _period),
            builder: (context, snapshot) {
              final data = snapshot.data ?? const [];
              if (data.isEmpty) {
                return const Center(child: Text('No data'));
              }
              final spotsCalories = <FlSpot>[];
              final spotsCarbs = <FlSpot>[];
              for (int i = 0; i < data.length; i++) {
                final e = data[i];
                final cal = (e['calories'] as num?)?.toDouble() ?? 0.0;
                final carbs = (e['carbs'] as num?)?.toDouble() ?? 0.0;
                spotsCalories.add(FlSpot(i.toDouble(), cal));
                spotsCarbs.add(FlSpot(i.toDouble(), carbs));
              }
              return LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(spots: spotsCalories, color: Colors.redAccent, isCurved: true, barWidth: 3),
                    LineChartBarData(spots: spotsCarbs, color: Colors.blueAccent, isCurved: true, barWidth: 3),
                  ],
                  titlesData: const FlTitlesData(show: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

