import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:jooyful_heaven/controllers/article_controller.dart';

class UploadArticleScreen extends StatefulWidget {
  const UploadArticleScreen({super.key});

  @override
  State<UploadArticleScreen> createState() => _UploadArticleScreenState();
}

class _UploadArticleScreenState extends State<UploadArticleScreen> {
  final ArticleController controller = Get.find<ArticleController>();
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  
  String selectedCategory = 'mental-health';
  List<String> categories = [
    'mental-health',
    'anxiety',
    'depression',
    'stress',
    'relationships',
    'self-care',
    'trauma',
    'therapy-techniques',
    'counseling-basics',
    'other'
  ];
  
  File? selectedImage;
  List<String> selectedTags = [];
  final List<String> availableTags = [
    'beginner',
    'advanced',
    'techniques',
    'case-study',
    'research',
    'exercises',
    'theory',
    'practice',
    'daily-tips',
    'professional'
  ];
  
  // Define audience options
  final Map<String, bool> audienceOptions = {
    'clients': true,
    'interns': false,
    'counselors': false,
  };
  
  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }
  
  void _submitArticle() {
    if (_formKey.currentState!.validate()) {
      // Get audience as a list of strings
      List<String> audience = audienceOptions.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      
      // Call the controller to upload the article
      controller.uploadArticle(
        title: titleController.text,
        content: contentController.text,
        category: selectedCategory,
        tags: selectedTags,
        image: selectedImage,
        audience: audience,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Article/Resource'),
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create New Article',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title field
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter article title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Category dropdown
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category.replaceAll('-', ' ').capitalize!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tags selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tags (Select all that apply)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableTags.map((tag) {
                            final isSelected = selectedTags.contains(tag);
                            return FilterChip(
                              label: Text(tag.replaceAll('-', ' ').capitalize!),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedTags.add(tag);
                                  } else {
                                    selectedTags.remove(tag);
                                  }
                                });
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: Colors.blue[100],
                              checkmarkColor: Colors.blue[800],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Audience selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Who can access this article?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...audienceOptions.entries.map((entry) {
                          return CheckboxListTile(
                            title: Text(entry.key.capitalize!),
                            value: entry.value,
                            onChanged: (value) {
                              setState(() {
                                audienceOptions[entry.key] = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }).toList(),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Image upload
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Featured Image (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_photo_alternate, size: 40),
                                      const SizedBox(height: 8),
                                      const Text('Click to upload image'),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Content field
                    TextFormField(
                      controller: contentController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        hintText: 'Write your article content here...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter article content';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitArticle,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Upload Article',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}