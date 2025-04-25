// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jooyful_heaven/models/article_model.dart';
// import 'package:jooyful_heaven/controllers/article_detail_controller.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ArticleDetailPage extends GetView<ArticleDetailController> {
//   const ArticleDetailPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Get article from arguments
//     final ArticleModel article = Get.arguments['article'];
    
//     return Scaffold(
//       body: Obx(() => controller.isLoading.value
//         ? const Center(child: CircularProgressIndicator())
//         : _buildArticleContent(context, article)
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Share article
//           Share.share(
//             'Check out this article: ${article.title}\n\nJooyful Heaven App',
//             subject: article.title,
//           );
//         },
//         child: const Icon(Icons.share),
//         tooltip: 'Share Article',
//       ),
//     );
//   }

//   Widget _buildArticleContent(BuildContext context, ArticleModel article) {
//     return CustomScrollView(
//       slivers: [
//         // App Bar
//         SliverAppBar(
//           expandedHeight: 200.0,
//           pinned: true,
//           flexibleSpace: FlexibleSpaceBar(
//             title: Text(
//               article.title ?? 'Article',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 shadows: [
//                   Shadow(
//                     offset: Offset(0, 1),
//                     blurRadius: 3.0,
//                     color: Color.fromARGB(150, 0, 0, 0),
//                   ),
//                 ],
//               ),
//             ),
//             background: _buildHeaderBackground(article),
//           ),
//           actions: [
//             IconButton(
//               icon: Obx(() => Icon(
//                 controller.isBookmarked.value 
//                     ? Icons.bookmark 
//                     : Icons.bookmark_border,
//               )),
//               onPressed: () => controller.toggleBookmark(article),
//               tooltip: 'Bookmark Article',
//             ),
//           ],
//         ),
        
//         // Article metadata
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Category & Read time
//                 Row(
//                   children: [
//                     if (article.category != null) ...[
//                       _buildCategoryChip(article.category!),
//                     ],
//                     const Spacer(),
//                     if (article.readTime != null) ...[
//                       Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${article.readTime} min read',
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                     ],
//                   ],
//                 ),
                
//                 const SizedBox(height: 16),
                
//                 // Author & Date
//                 Row(
//                   children: [
//                     if (article.author != null) ...[
//                       CircleAvatar(
//                         backgroundColor: Colors.blue.shade100,
//                         child: Text(
//                           article.author![0].toUpperCase(),
//                           style: TextStyle(
//                             color: Colors.blue.shade800,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'By ${article.author}',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           if (article.publishDate != null) ...[
//                             Text(
//                               _formatDate(article.publishDate!),
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ],
//                   ],
//                 ),
                
//                 // Divider
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 16.0),
//                   child: Divider(),
//                 ),
                
//                 // Summary
//                 if (article.summary != null) ...[
//                   Text(
//                     article.summary!,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ],
//             ),
//           ),
//         ),
        
//         // Article content
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 80.0), // Extra padding for FAB
//             child: _buildArticleBody(article),
//           ),
//         ),
        
//         // Related articles
//         if (controller.relatedArticles.isNotEmpty) ...[
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Divider(),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Related Articles',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildRelatedArticles(),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ],
//     );
//   }

//   Widget _buildHeaderBackground(ArticleModel article) {
//     // If there's a cover image URL, use it
//     if (article.coverImageUrl != null && article.coverImageUrl!.isNotEmpty) {
//       return Stack(
//         fit: StackFit.expand,
//         children: [
//           Image.network(
//             article.coverImageUrl!,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               // Fallback to gradient if image fails to load
//               return _buildGradientBackground(article);
//             },
//           ),
//           // Dark overlay for better text contrast
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.transparent,
//                   Colors.black.withOpacity(0.7),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       );
//     } else {
//       // Use a gradient based on category if no image
//       return _buildGradientBackground(article);
//     }
//   }
  
//   Widget _buildGradientBackground(ArticleModel article) {
//     // Different gradients based on category
//     List<Color> gradientColors;
    
//     switch (article.category?.toLowerCase()) {
//       case 'mental-health':
//         gradientColors = [Colors.purple.shade300, Colors.purple.shade700];
//         break;
//       case 'anxiety':
//         gradientColors = [Colors.blue.shade300, Colors.blue.shade700];
//         break;
//       case 'depression':
//         gradientColors = [Colors.teal.shade300, Colors.teal.shade700];
//         break;
//       default:
//         gradientColors = [Colors.indigo.shade300, Colors.indigo.shade700];
//     }
    
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: gradientColors,
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryChip(String category) {
//     String displayName = category.replaceAll('-', ' ');
//     displayName = '${displayName[0].toUpperCase()}${displayName.substring(1)}';
    
//     // Different colors based on category
//     Color chipColor;
//     switch (category.toLowerCase()) {
//       case 'mental-health':
//         chipColor = Colors.purple;
//         break;
//       case 'anxiety':
//         chipColor = Colors.blue;
//         break;
//       case 'depression':
//         chipColor = Colors.teal;
//         break;
//       default:
//         chipColor = Colors.indigo;
//     }
    
//     return Chip(
//       label: Text(
//         displayName,
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       backgroundColor: chipColor,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//     );
//   }

//   Widget _buildArticleBody(ArticleModel article) {
//     final String content = article.content ?? 'No content available';
    
//     // Check if content is markdown format
//     if (article.contentFormat?.toLowerCase() == 'markdown' || 
//         content.contains('#') || content.contains('*') || 
//         content.contains('```') || content.contains('---')) {
//       return MarkdownBody(
//         data: content,
//         selectable: true,
//         styleSheet: MarkdownStyleSheet(
//           h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           h3: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           p: const TextStyle(fontSize: 16, height: 1.5),
//           blockquote: TextStyle(
//             fontSize: 16,
//             fontStyle: FontStyle.italic,
//             color: Colors.grey[700],
//             decoration: TextDecoration.none,
//           ),
//           blockquoteDecoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(4),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           code: TextStyle(
//             backgroundColor: Colors.grey[200],
//             fontFamily: 'monospace',
//             fontSize: 14,
//           ),
//           codeblockDecoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//         onTapLink: (text, href, title) {
//           if (href != null) {
//             launchUrl(Uri.parse(href));
//           }
//         },
//       );
//     } else {
//       // For plain text content
//       return SelectableText(
//         content,
//         style: const TextStyle(fontSize: 16, height: 1.5),
//       );
//     }
//   }

//   Widget _buildRelatedArticles() {
//     return SizedBox(
//       height: 220,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: controller.relatedArticles.length,
//         itemBuilder: (context, index) {
//           final relatedArticle = controller.relatedArticles[index];
          
//           return Container(
//             width: 160,
//             margin: const EdgeInsets.only(right: 12),
//             child: Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: InkWell(
//                 onTap: () {
//                   // Navigate to related article
//                   Get.offAndToNamed(
//                     '/article-detail',
//                     arguments: {'article': relatedArticle},
//                   );
//                 },
//                 borderRadius: BorderRadius.circular(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Article image or color header
//                     Container(
//                       height: 80,
//                       decoration: BoxDecoration(
//                         borderRadius: const BorderRadius.vertical(
//                           top: Radius.circular(12),
//                         ),
//                         image: relatedArticle.coverImageUrl != null
//                             ? DecorationImage(
//                                 image: NetworkImage(relatedArticle.coverImageUrl!),
//                                 fit: BoxFit.cover,
//                               )
//                             : null,
//                         color: relatedArticle.coverImageUrl == null
//                             ? _getCategoryColor(relatedArticle.category)
//                             : null,
//                       ),
//                     ),
                    
//                     // Article details
//                     Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             relatedArticle.title ?? 'Untitled',
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           if (relatedArticle.author != null) ...[
//                             Text(
//                               'By ${relatedArticle.author}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                           const SizedBox(height: 4),
//                           if (relatedArticle.readTime != null) ...[
//                             Text(
//                               '${relatedArticle.readTime} min read',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
  
//   Color _getCategoryColor(String? category) {
//     switch (category?.toLowerCase()) {
//       case 'mental-health':
//         return Colors.purple.shade300;
//       case 'anxiety':
//         return Colors.blue.shade300;
//       case 'depression':
//         return Colors.teal.shade300;
//       default:
//         return Colors.indigo.shade300;
//     }
//   }
  
//   String _formatDate(DateTime date) {
//     final months = [
//       'January', 'February', 'March', 'April', 'May', 'June', 
//       'July', 'August', 'September', 'October', 'November', 'December'
//     ];
    
//     return '${months[date.month - 1]} ${date.day}, ${date.year}';
//   }
// }