import 'package:flutter/material.dart';
import '../../data/models.dart';
import '../../services/community_service.dart';
import 'package:share_plus/share_plus.dart';

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
  void initState() {
    super.initState();
  }

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
            child: StreamBuilder<List<CommunityPost>>(
              stream: CommunityService.instance.streamPosts(category: _selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          'Unable to load feed. ${'\n'}Check Firestore index and rules.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                final posts = snapshot.data ?? const <CommunityPost>[];
                if (posts.isEmpty) {
                  return const Center(child: Text('No posts yet'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, i) {
                    final p = posts[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const CircleAvatar(child: Icon(Icons.person)),
                          const SizedBox(width: 8),
                          Text(p.userName),
                          const Spacer(),
                          Text(_timeAgo(p.createdAt)),
                        ]),
                        const SizedBox(height: 8),
                        Text(p.content),
                        if (p.imageUrl != null && p.imageUrl!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(p.imageUrl!, height: 160, width: double.infinity, fit: BoxFit.cover),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(p.isLikedByMe ? Icons.favorite : Icons.favorite_border, color: p.isLikedByMe ? Colors.red : null),
                              onPressed: () => CommunityService.instance.toggleLike(p.id),
                            ),
                            Text('${p.likesCount}'),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.mode_comment_outlined),
                              onPressed: () => _openComments(p),
                            ),
                            Text('${p.commentsCount}'),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.share_outlined),
                              onPressed: () => _sharePost(p),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: posts.length,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _openComposer, child: const Icon(Icons.add)),
    );
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  Future<void> _openComposer() async {
    final controller = TextEditingController();
    String category = _selectedCategory == 'All' ? 'Questions' : _selectedCategory;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('New Post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  DropdownButton<String>(
                    value: category,
                    items: _categories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => category = v);
                    },
                  )
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    Navigator.of(ctx).pop();
                    await CommunityService.instance.createPost(content: text, category: category);
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Post'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openComments(CommunityPost post) async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 8,
          ),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: Column(
              children: [
                Container(height: 4, width: 40, margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const Text('Comments', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<List<PostComment>>(
                    stream: CommunityService.instance.streamComments(post.id),
                    builder: (context, snapshot) {
                      final comments = snapshot.data ?? const <PostComment>[];
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (comments.isEmpty) {
                        return const Center(child: Text('No comments yet'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, i) {
                          final c = comments[i];
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person, size: 16)),
                            title: Text(c.userName),
                            subtitle: Text(c.text),
                            trailing: Text(_timeAgo(c.createdAt)),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemCount: comments.length,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(hintText: 'Write a comment...', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          final text = controller.text.trim();
                          if (text.isEmpty) return;
                          controller.clear();
                          await CommunityService.instance.addComment(postId: post.id, text: text);
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sharePost(CommunityPost post) async {
    await Share.share('${post.userName}: ${post.content}');
  }
}


