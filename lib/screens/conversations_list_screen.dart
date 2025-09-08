import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/conversations_provider.dart';
import '../models/conversation_model.dart';
import 'chat_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../config/admin_settings.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // تهيئة المزود وتحميل المحادثات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ConversationsProvider>(context, listen: false);
      provider.initialize();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<ConversationsProvider>(context, listen: false);
      provider.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'المحادثات',
          style: AppTextStyles.heading2,
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // أيقونة الدعم الفني
          IconButton(
            icon: const Icon(Icons.support_agent, size: 28),
            onPressed: () => _openSupportChat(context),
            tooltip: 'الدعم الفني',
          ),
          // أيقونة البحث
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Consumer<ConversationsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.conversations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            );
          }

          if (provider.error != null && provider.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: AppTextStyles.body1.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final conversations = _getFilteredConversations(provider);

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty 
                        ? 'لا توجد محادثات تطابق البحث'
                        : 'لا توجد محادثات بعد',
                    style: AppTextStyles.body1.copyWith(color: Colors.grey[600]),
                  ),
                  if (_searchQuery.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'ابدأ محادثة جديدة مع الدعم الفني',
                      style: AppTextStyles.caption.copyWith(color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _openSupportChat(context),
                      icon: const Icon(Icons.support_agent),
                      label: const Text('تواصل مع الدعم'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return Column(
            children: [
              // شريط الفلاتر
              if (_selectedFilter != null || _searchQuery.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_searchQuery.isNotEmpty) ...[
                        Chip(
                          label: Text('البحث: $_searchQuery'),
                          onDeleted: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (_selectedFilter != null) ...[
                        Chip(
                          label: Text(_getFilterLabel(_selectedFilter!)),
                          onDeleted: () {
                            setState(() {
                              _selectedFilter = null;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              
              // قائمة المحادثات
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.refresh,
                  color: AppColors.primaryColor,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: conversations.length + (provider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= conversations.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                            ),
                          ),
                        );
                      }

                      final conversation = conversations[index];
                      return _buildConversationItem(context, conversation, provider);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewConversationDialog(context),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add_comment, color: Colors.white),
        tooltip: 'محادثة جديدة',
      ),
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    ConversationListItem conversation,
    ConversationsProvider provider,
  ) {
    final hasUnread = conversation.unreadCount > 0;
    final timeText = conversation.lastMessageAt != null
        ? timeago.format(conversation.lastMessageAt!, locale: 'ar')
        : timeago.format(conversation.createdAt, locale: 'ar');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: hasUnread ? 2 : 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getConversationColor(conversation.type),
          child: Icon(
            _getConversationIcon(conversation.type),
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.title,
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasUnread)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (conversation.otherParticipant != null)
              Text(
                conversation.otherParticipant!.name,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            if (conversation.lastMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                conversation.lastMessage!.content,
                style: AppTextStyles.body2.copyWith(
                  color: hasUnread ? Colors.black87 : Colors.grey[600],
                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeText,
              style: AppTextStyles.caption.copyWith(
                color: hasUnread ? AppColors.primaryColor : Colors.grey[500],
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(conversation.status),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        onTap: () => _openConversation(context, conversation, provider),
      ),
    );
  }

  List<ConversationListItem> _getFilteredConversations(ConversationsProvider provider) {
    var conversations = provider.conversations;

    // تطبيق البحث
    if (_searchQuery.isNotEmpty) {
      conversations = provider.searchConversations(_searchQuery);
    }

    // تطبيق الفلتر
    if (_selectedFilter != null) {
      switch (_selectedFilter) {
        case 'unread':
          conversations = conversations.where((c) => c.unreadCount > 0).toList();
          break;
        case 'support':
          conversations = conversations.where((c) => c.type == AdminSettings.conversationTypeSupport).toList();
          break;
        case 'private':
          conversations = conversations.where((c) => c.type == AdminSettings.conversationTypeUser).toList();
          break;
      }
    }

    return conversations;
  }

  void _openConversation(
    BuildContext context,
    ConversationListItem conversation,
    ConversationsProvider provider,
  ) {
    // تحديد المحادثة كمقروءة
    if (conversation.unreadCount > 0) {
      provider.markConversationAsRead(conversation.id);
    }

    // فتح شاشة المحادثة
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: conversation.id.toString(),
          conversationTitle: conversation.title,
        ),
      ),
    );
  }

  void _openSupportChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(
          isSupportChat: true,
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث في المحادثات'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'ابحث عن محادثة...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value.trim();
            });
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _showNewConversationDialog(BuildContext context) {
    // يمكن تطوير هذا لاحقاً لإضافة محادثات جديدة مع مستخدمين آخرين
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة إنشاء محادثة جديدة قيد التطوير'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  IconData _getConversationIcon(String type) {
    switch (type) {
      case AdminSettings.conversationTypeSupport: // 'admin_user'
        return Icons.support_agent;
      case AdminSettings.conversationTypeProvider: // 'user_service_provider'
        return Icons.business;
      case AdminSettings.conversationTypeUser: // 'user_user'
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  Color _getConversationColor(String type) {
    switch (type) {
      case AdminSettings.conversationTypeSupport:
        return Colors.blue;
      case AdminSettings.conversationTypeProvider:
        return Colors.green;
      case AdminSettings.conversationTypeUser:
        return AppColors.primaryColor;
      default:
        return AppColors.primaryColor;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'unread':
        return 'غير مقروءة';
      case 'support':
        return 'الدعم الفني';
      case 'private':
        return 'محادثات خاصة';
      default:
        return filter;
    }
  }
}