import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/models/article_model.dart';
import 'package:jooyful_heaven/routes/app_routes.dart';

class ArticlesSection extends StatelessWidget {
  final List<ArticleModel> articles;
  
  const ArticlesSection({
    super.key,
    required this.articles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mental Health Articles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(AppRoutes.ALL_ARTICLES);
              },
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 8),
        articles.isEmpty
          ? Center(child: Text('No articles available'))
          : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: articles.length > 3 ? 3 : articles.length,
              itemBuilder: (context, index) {
                final ArticleModel article = articles[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Icon(Icons.article, color: Colors.green),
                    ),
                    title: Text(
                      article.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      article.category,
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.ARTICLE_DETAIL,
                        arguments: article,
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