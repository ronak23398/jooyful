import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/models/article_model.dart';

class ArticleDetailsPage extends StatelessWidget {
  late final ArticleModel article;

  ArticleDetailsPage({super.key}) {
    // Get the article passed as argument
    article = Get.arguments as ArticleModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article header
            Text(
              article.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            
            // Article metadata
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    article.category,
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${article.createdAt.day}/${article.createdAt.month}/${article.createdAt.year}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            // Image if available
            if (article.imageUrl != null) ...[
              SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
            ],
            
            // Tags
            if (article.tags.isNotEmpty) ...[
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: article.tags.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(fontSize: 12),
                )).toList(),
              ),
            ],
            
            // Content
            SizedBox(height: 24),
            Text(
              article.content,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
            
            // Author info if available
            if (article.authorName != null) ...[
              SizedBox(height: 32),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.person, color: Colors.blue),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Written by ${article.authorName}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
            
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}