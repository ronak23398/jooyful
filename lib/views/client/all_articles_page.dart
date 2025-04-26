import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/article_controller.dart';
import 'package:jooyful_heaven/models/article_model.dart';
import 'package:jooyful_heaven/routes/app_routes.dart';

class AllArticlesPage extends StatefulWidget {
  const AllArticlesPage({Key? key}) : super(key: key);

  @override
  State<AllArticlesPage> createState() => _AllArticlesPageState();
}

class _AllArticlesPageState extends State<AllArticlesPage> {
  final ArticleController _articleController = Get.find<ArticleController>();
  String? selectedCategory;
  String? selectedAudience;
  String searchQuery = '';
  
  final TextEditingController _searchController = TextEditingController();
  
  // Get unique categories from articles
  List<String> get categories {
    final Set<String> uniqueCategories = _articleController.articles
        .map((article) => article.category)
        .toSet();
    return ['All', ...uniqueCategories.toList()];
  }
  
  // Get unique audiences from articles
  List<String> get audiences {
    final Set<String> uniqueAudiences = {};
    for (final article in _articleController.articles) {
      uniqueAudiences.addAll(article.audience);
    }
    return ['All', ...uniqueAudiences.toList()];
  }
  
  // Get filtered articles
  List<ArticleModel> get filteredArticles {
    return _articleController.filterArticles(
      category: selectedCategory == 'All' ? null : selectedCategory,
      audience: selectedAudience == 'All' ? null : selectedAudience,
      searchQuery: searchQuery.isEmpty ? null : searchQuery,
    );
  }
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Articles'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search articles...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Filter options
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Category filter
                      Container(
                        padding: EdgeInsets.only(right: 12),
                        child: DropdownButton<String>(
                          hint: Text('Category'),
                          value: selectedCategory,
                          underline: Container(),
                          icon: Icon(Icons.arrow_drop_down),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          },
                          items: categories.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value == 'All' ? null : value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      
                      // Audience filter
                      Container(
                        padding: EdgeInsets.only(right: 12),
                        child: DropdownButton<String>(
                          hint: Text('Audience'),
                          value: selectedAudience,
                          underline: Container(),
                          icon: Icon(Icons.arrow_drop_down),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedAudience = newValue;
                            });
                          },
                          items: audiences.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value == 'All' ? null : value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      
                      // Clear filters
                      if (selectedCategory != null || selectedAudience != null || searchQuery.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedCategory = null;
                              selectedAudience = null;
                              searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          icon: Icon(Icons.clear, size: 16),
                          label: Text('Clear'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Articles list
          Expanded(
            child: Obx(() {
              if (_articleController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              
              final articles = filteredArticles;
              
              if (articles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No articles found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () => _articleController.fetchArticles(),
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return ArticleCard(article: article);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  
  const ArticleCard({
    super.key,
    required this.article,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.ARTICLE_DETAIL, arguments: article);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image if available
            if (article.imageUrl != null)
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(article.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and date
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
                      Spacer(),
                      Text(
                        '${article.createdAt.day}/${article.createdAt.month}/${article.createdAt.year}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Title
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Content preview
                  Text(
                    article.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Tags
                  if (article.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: article.tags.take(3).map((tag) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 12,
                          ),
                        ),
                      )).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}