import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/controllers/intern/intern_controller.dart';
import 'package:jooyful_heaven/models/article_model.dart';

class InternHomePage extends GetView<InternController> {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Intern Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
            onPressed: () {
              // Navigate to chat page
              // Get.toNamed(Routes.CHAT);
            },
            tooltip: 'Chat with Owner & Counsellors',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadInternData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(),
                  const SizedBox(height: 24),

                  // Articles Section
                  _buildSectionTitle('Articles', Icons.article),
                  const SizedBox(height: 12),
                  _buildCategoryTabs(),
                  const SizedBox(height: 24),

                  // Study Materials Section
                  _buildSectionTitle('Study Materials', Icons.book),
                  const SizedBox(height: 12),
                  _buildStudyMaterialsList(),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.loadInternData,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Data',
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Intern!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Access your learning resources and connect with mentors.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoCard('Articles', controller.articles.length.toString()),
              const SizedBox(width: 16),
              _buildInfoCard(
                'Study Materials',
                controller.studyMaterials.length.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Obx(() {
      // Group articles by category
      Map<String, List<ArticleModel>> categorizedArticles = {};
      for (var article in controller.articles) {
        String category = article.category ?? 'uncategorized';
        if (!categorizedArticles.containsKey(category)) {
          categorizedArticles[category] = [];
        }
        categorizedArticles[category]!.add(article);
      }

      return DefaultTabController(
        length: categorizedArticles.keys.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              isScrollable: true,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs:
                  categorizedArticles.keys.map((category) {
                    String displayName = category.replaceAll('-', ' ');
                    displayName =
                        '${displayName[0].toUpperCase()}${displayName.substring(1)}';
                    return Tab(text: displayName);
                  }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: TabBarView(
                children:
                    categorizedArticles.keys.map((category) {
                      return _buildArticlesList(categorizedArticles[category]!);
                    }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildArticlesList(List<ArticleModel> articles) {
    if (articles.isEmpty) {
      return const Center(
        child: Text('No articles available for this category'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to article details page
              // Get.toNamed(
              //   Routes.ARTICLE_DETAIL,
              //   arguments: {'article': article}
              // );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title ?? 'Untitled Article',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (article.authorId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'By ${article.authorId}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    article.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.createdAt != null
                            ? '${article.createdAt} min read'
                            : '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudyMaterialsList() {
    if (controller.studyMaterials.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No study materials available'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.studyMaterials.length,
      itemBuilder: (context, index) {
        final material = controller.studyMaterials[index];
        final String title = material['title'] ?? 'Untitled Material';
        final String? description = material['description'];
        final String? fileUrl = material['fileUrl'];
        final String? fileType = material['fileType'];

        IconData fileIcon;
        switch (fileType?.toLowerCase()) {
          case 'pdf':
            fileIcon = Icons.picture_as_pdf;
            break;
          case 'doc':
          case 'docx':
            fileIcon = Icons.description;
            break;
          case 'ppt':
          case 'pptx':
            fileIcon = Icons.slideshow;
            break;
          case 'xls':
          case 'xlsx':
            fileIcon = Icons.table_chart;
            break;
          default:
            fileIcon = Icons.insert_drive_file;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: Icon(fileIcon, color: Colors.blue),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle:
                description != null
                    ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(description),
                    )
                    : null,
            trailing: IconButton(
              icon: const Icon(Icons.download, color: Colors.blue),
              onPressed: () {
                if (fileUrl != null) {
                  controller.downloadStudyMaterial(material);
                } else {
                  Get.snackbar(
                    'Error',
                    'Download link not available',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            ),
            onTap: () {
              // Get.toNamed(
              //   Routes.STUDY_MATERIAL_DETAIL,
              //   arguments: {'material': material}
              // );
            },
          ),
        );
      },
    );
  }
}
