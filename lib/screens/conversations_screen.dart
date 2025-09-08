import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/conversations_provider.dart';
import '../providers/auth_provider.dart';
import '../services/conversations_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../config/admin_settings.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';
  bool _isLoadingSupport = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConversations();
    });
    
    // إضافة listener للتمرير للتحميل التلقائي
    _scrollController.addListener(_onScroll);
  }

  void _initializeConversations() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoggedIn) {
      final conversationsProvider = context.read<ConversationsProvider>();
      conversationsProvider.initialize();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<ConversationsProvider>();
      if (!provider.isLoading && provider.hasMorePages) {
        provider.loadMore();
      }
    }
  }

  void _onSearchChanged(String query) {
    // البحث يتم محلياً في الـ provider
    setState(() {
      // سيتم تطبيق البحث في build method
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    // الفلترة تتم محلياً في build method
  }

  Future<void> _openSupportChat() async {
    setState(() {
      _isLoadingSupport = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final supportConversation = await ConversationsService.getSupportConversation(
        token: authProvider.token ?? '',
      );

      if (supportConversation != null && supportConversation.conversation != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: supportConversation.conversation!.id.toString(),
              conversationTitle: AdminSettings.supportChatTitle,
              isSupportChat: true,
            ),
          ),
        );
      } else {
        _showErrorSnackBar('فشل في فتح محادثة الدعم الفني');
      }
    } catch (e) {
      debugPrint('❌ Error opening support chat: $e');
      _showErrorSnackBar('حدث خطأ أثناء فتح محادثة الدعم الفني');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSupport = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
      ),
    );
  }

  void _openConversation(int conversationId, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: conversationId.toString(),
          conversationTitle: title,
          isSupportChat: false,
        ),
      ),
    );
  }

  void _showNewConversationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('محادثة جديدة'),
        content: const Text('هذه الميزة ستكون متاحة قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'المحادثات',
          style: AppTextStyles.heading5,
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // أيقونة الدعم الفني
          IconButton(
            onPressed: _isLoadingSupport ? null : _openSupportChat,
            icon: _isLoadingSupport
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.support_agent),
            tooltip: 'الدعم الفني',
          ),
          // أيقونة البحث
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
            tooltip: 'البحث',
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط الفلاتر
          _buildFilterChips(),
          // قائمة المحادثات
          Expanded(
            child: Consumer<ConversationsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.conversations.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
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
                          color: AppColors.errorColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          style: AppTextStyles.errorText,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: provider.refresh,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                          ),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.iconSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'لا توجد محادثات تطابق البحث'
                              : 'لا توجد محادثات بعد',
                          style: AppTextStyles.subtitle1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'جرب البحث بكلمات مختلفة'
                              : 'ابدأ محادثة جديدة أو تواصل مع الدعم الفني',
                          style: AppTextStyles.body3,
                          textAlign: TextAlign.center,
                        ),
                        if (_searchController.text.isEmpty) ...[
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _openSupportChat,
                            icon: const Icon(Icons.support_agent),
                            label: const Text('تواصل مع الدعم الفني'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                final filteredConversations = _getFilteredConversations(provider);
                
                return RefreshIndicator(
                  onRefresh: provider.refresh,
                  color: AppColors.primaryColor,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredConversations.length + (provider.hasMorePages ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= filteredConversations.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      }

                      final conversation = filteredConversations[index];
                      return _buildConversationItem(conversation);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewConversationDialog,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('all', 'الكل'),
          const SizedBox(width: 8),
          _buildFilterChip('unread', 'غير مقروءة'),
          const SizedBox(width: 8),
          _buildFilterChip('support', 'الدعم الفني'),
          const SizedBox(width: 8),
          _buildFilterChip('users', 'المستخدمين'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _onFilterChanged(value),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildConversationItem(dynamic conversation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getConversationColor(conversation),
          child: Icon(
            _getConversationIcon(conversation),
            color: Colors.white,
          ),
        ),
        title: Text(
          conversation.title ?? 'محادثة',
          style: AppTextStyles.subtitle1.copyWith(
            fontWeight: conversation.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (conversation.lastMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                conversation.lastMessage!,
                style: AppTextStyles.body3,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatTime(conversation.updatedAt),
              style: AppTextStyles.caption,
            ),
          ],
        ),
        trailing: conversation.unreadCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              )
            : null,
        onTap: () => _openConversation(conversation.id, conversation.title ?? 'محادثة'),
      ),
    );
  }

  Color _getConversationColor(dynamic conversation) {
    if (conversation.type == AdminSettings.conversationTypeSupport) {
      return AppColors.secondaryColor;
    }
    return AppColors.primaryColor;
  }

  IconData _getConversationIcon(dynamic conversation) {
    if (conversation.type == AdminSettings.conversationTypeSupport) {
      return Icons.support_agent;
    }
    return Icons.person;
  }

  List<dynamic> _getFilteredConversations(ConversationsProvider provider) {
    var conversations = provider.conversations;
    
    // تطبيق البحث
    if (_searchController.text.isNotEmpty) {
      conversations = provider.searchConversations(_searchController.text);
    }
    
    // تطبيق الفلتر
    if (_selectedFilter != 'all') {
      switch (_selectedFilter) {
        case 'unread':
          conversations = conversations.where((c) => c.unreadCount > 0).toList();
          break;
        case 'support':
          conversations = conversations.where((c) => c.type == AdminSettings.conversationTypeSupport).toList();
          break;
        case 'users':
          conversations = conversations.where((c) => c.type == AdminSettings.conversationTypeUser).toList();
          break;
      }
    }
    
    return conversations;
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} أيام';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث في المحادثات'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'ابحث عن محادثة...',
            border: OutlineInputBorder(),
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
              Navigator.pop(context);
            },
            child: const Text('مسح'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}