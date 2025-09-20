import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<String> _categories = const [
    'Questions',
    'Advice',
    'Success Story',
    'Support',
    'All',
  ];

  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final bool isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCategory = category),
                      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, i) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [CircleAvatar(child: Icon(Icons.person)), SizedBox(width: 8), Text('User Name'), Spacer(), Text('2 hours')]),
                  const SizedBox(height: 8),
                  const Text("It's all about the looks. LUPIN part 3, October 5 on Netflix"),
                  const SizedBox(height: 8),
                  Container(height: 160, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12))),
                  const SizedBox(height: 8),
                  Row(children: const [Icon(Icons.favorite_border), SizedBox(width: 16), Icon(Icons.mode_comment_outlined), SizedBox(width: 16), Icon(Icons.share_outlined)]),
                ],
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemCount: 6,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    );
  }
}


