import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<NewsItem> _news = [];
  bool _loading = true;
  String? _error;
  String _selectedTopic = 'All';

  final _topics = [
    'All', 'Cotton', 'Soybean', 'Weather', 'Mandi Price', 'Govt Scheme'
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() { _loading = true; _error = null; });
    try {
      final news = await ApiService.getAgriNews(
        crop: _selectedTopic == 'All' ? null : _selectedTopic,
        district: 'Akola',
        state: 'Maharashtra',
        country: 'India',
      );
      if (mounted) setState(() { _news = news; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Agri News',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: AppTheme.primary, size: 20),
            onPressed: _loadNews,
          ),
        ],
      ),
      body: Column(
        children: [
          // Topic chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _topics.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final sel = _topics[i] == _selectedTopic;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTopic = _topics[i]);
                      _loadNews();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppTheme.primary
                            : AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        _topics[i],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppTheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Content
          Expanded(
            child: _loading
                ? _buildSkeleton()
                : _error != null
                    ? _buildError()
                    : _news.isEmpty
                        ? _buildEmpty()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                            itemCount: _news.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) =>
                                _NewsCard(item: _news[i]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 48, color: AppTheme.outlineVariant),
          const SizedBox(height: 12),
          Text('Could not load news',
              style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          TextButton(onPressed: _loadNews, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        'No news found for this topic',
        style: GoogleFonts.inter(
            fontSize: 14, color: AppTheme.onSurfaceVariant),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem item;
  const _NewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryFixed,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  item.source.isNotEmpty ? item.source : 'News',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              if (item.date.isNotEmpty)
                Text(
                  item.date,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: AppTheme.onSurfaceVariant),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
              height: 1.3,
            ),
          ),
          if (item.snippet.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.snippet,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.onSurfaceVariant,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}