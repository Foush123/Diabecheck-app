import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> showSugarLogSheet(BuildContext context) async {
  final controller = TextEditingController();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: MediaQuery.of(context).size.height * 0.3,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Log sugar level',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'mg/dL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                  ),
                  prefixIcon: Icon(Icons.monitor_heart_outlined, color: Colors.red.shade400),
                  filled: true,
                  fillColor: Colors.red.shade50,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in to save logs.')),
                      );
                      return;
                    }
                    final value = double.tryParse(controller.text.trim());
                    if (value == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid number.')),
                      );
                      return;
                    }
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('logs')
                        .doc('sugar')
                        .collection('entries')
                        .add({
                      'valueMgdl': value,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showCaloriesLogSheet(BuildContext context) async {
  final controller = TextEditingController();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: MediaQuery.of(context).size.height * 0.3,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Log calories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Kcal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
                  ),
                  prefixIcon: Icon(Icons.local_fire_department_outlined, color: Colors.orange.shade400),
                  filled: true,
                  fillColor: Colors.orange.shade50,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in to save logs.')),
                      );
                      return;
                    }
                    final value = double.tryParse(controller.text.trim());
                    if (value == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid number.')),
                      );
                      return;
                    }
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('logs')
                        .doc('calories')
                        .collection('entries')
                        .add({
                      'kcal': value,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showWaterLogSheet(BuildContext context) async {
  final controller = TextEditingController();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: MediaQuery.of(context).size.height * 0.3,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Log water intake',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Cups',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                  ),
                  prefixIcon: Icon(Icons.local_drink_outlined, color: Colors.blue.shade400),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in to save logs.')),
                      );
                      return;
                    }
                    final value = double.tryParse(controller.text.trim());
                    if (value == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid number.')),
                      );
                      return;
                    }
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('logs')
                        .doc('water')
                        .collection('entries')
                        .add({
                      'cups': value,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


