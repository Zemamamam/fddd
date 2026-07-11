import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../services/health_News_Service.dart';
import 'all_HealthNewsScreen.dart';
import 'newsDetailScreen.dart';

class MedicalNewsWidget extends StatefulWidget {
  const MedicalNewsWidget({super.key});

  @override
  State<MedicalNewsWidget> createState() => _MedicalNewsWidgetState();
}

class _MedicalNewsWidgetState extends State<MedicalNewsWidget> {
  List<HealthNewsItem> news = [];
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    final loadedNews = await HealthNewsService.fetchMedicalNews();
    if (!mounted) return;
    setState(() {
      news = loadedNews;
      isLoading = false;
    });
  }

  Widget _buildImageFallback() {
    return Container(
      width: double.infinity,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'آخر الأخبار الطبية',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllHealthNewsScreen(newsList: news),
                    ),
                  );
                },
                child: const Text("عرض الكل"),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (news.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
              ),
              child: const Text(
                'لا توجد أخبار طبية متاحة حالياً. اسحب لتحديث الصفحة وحاول مرة أخرى.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, _) {
              final screenSize = MediaQuery.sizeOf(context);
              final screenWidth = screenSize.width;
              final compact = screenWidth < 360;
              final tickerHeight = math.min(math.max(screenSize.height * 0.11, compact ? 112.0 : 118.0), 144.0);
              final imageHeight = tickerHeight * (compact ? 0.34 : 0.36);
              final cardWidth = math.min(math.max(screenWidth * (compact ? 0.82 : 0.74), 210.0), 300.0);
              final titleSize = compact ? 12.5 : 13.5;
              final sourceSize = compact ? 10.5 : 11.0;
              return SizedBox(
                height: tickerHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  itemCount: news.length,
                  itemBuilder: (context, index) {
                    final article = news[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewsDetailScreen(news: article),
                          ),
                        );
                      },
                      child: Container(
                        width: cardWidth,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.12),
                              blurRadius: isDarkMode ? 0 : 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: imageHeight,
                              width: double.infinity,
                              child: article.imageUrl.isNotEmpty
                                  ? Image.network(
                                      article.imageUrl,
                                      width: double.infinity,
                                      height: imageHeight,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildImageFallback(),
                                    )
                                  : _buildImageFallback(),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 5 : 6),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        article.title,
                                        maxLines: compact ? 2 : 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontWeight: FontWeight.bold, height: 1.2, fontSize: titleSize),
                                      ),
                                      SizedBox(height: compact ? 3 : 4),
                                      Text(
                                        article.source,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: sourceSize, color: Colors.grey, height: 1.1),
                                      ),
                                    ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
