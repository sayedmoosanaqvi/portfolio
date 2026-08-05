import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:portfolio/models/project_model.dart';

class AddProjectScreen extends StatefulWidget {
  final ProjectModel? existingProject; // Optional parameter for editing

  const AddProjectScreen({super.key, this.existingProject});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _githubController;
  late TextEditingController _liveLinkController;
  late TextEditingController _toolsController;
  
  String? _savedImagePath;
  String _selectedCategory = 'Mobile Application';
  
  final List<String> _categories = [
    'Mobile Application',
    'Web Application',
    'Backend Architecture',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill data if editing an existing project
    final project = widget.existingProject;
    _titleController = TextEditingController(text: project?.title ?? '');
    _descriptionController = TextEditingController(text: project?.description ?? '');
    _githubController = TextEditingController(text: project?.githubLink ?? '');
    _liveLinkController = TextEditingController(text: project?.liveLink ?? '');
    _toolsController = TextEditingController(text: project?.toolsUsed.join(', ') ?? '');
    
    if (project != null) {
      _selectedCategory = project.category;
      if (project.imagePaths.isNotEmpty && !project.imagePaths.first.startsWith('assets/')) {
        _savedImagePath = project.imagePaths.first;
      }
    }
  }

  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final savedPath = '${directory.path}/$fileName';
      
      await File(pickedFile.path).copy(savedPath);

      setState(() {
        _savedImagePath = savedPath;
      });
    }
  }

  Future<void> _saveProject() async {
    if (_formKey.currentState!.validate()) {
      
      // Keep existing placeholder if no image was selected and no old image exists
      List<String> imageList = ['assets/images/placeholder.png'];
      if (_savedImagePath != null) {
        imageList = [_savedImagePath!];
      } else if (widget.existingProject != null && widget.existingProject!.imagePaths.isNotEmpty) {
        imageList = widget.existingProject!.imagePaths;
      }

      // If editing, keep the same ID. If new, generate a new ID.
      final String projectId = widget.existingProject?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final updatedProject = ProjectModel(
        id: projectId, 
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        imagePaths: imageList, 
        githubLink: _githubController.text.isNotEmpty ? _githubController.text.trim() : null,
        liveLink: _liveLinkController.text.isNotEmpty ? _liveLinkController.text.trim() : null,
        toolsUsed: _toolsController.text.split(',').map((e) => e.trim()).toList(),
      );
      
      final prefs = await SharedPreferences.getInstance();
      final String? projectsJson = prefs.getString('saved_projects');
      List<ProjectModel> currentProjects = [];

      if (projectsJson != null) {
        final List<dynamic> decoded = jsonDecode(projectsJson);
        currentProjects = decoded.map((item) => ProjectModel.fromJson(item)).toList();
      } else {
        currentProjects = List.from(portfolioProjects); // fallback data
      }

      // Remove the old version if it exists, then add the updated version
      currentProjects.removeWhere((item) => item.id == projectId);
      currentProjects.add(updatedProject);

      final String encodedData = jsonEncode(currentProjects.map((p) => p.toJson()).toList());
      await prefs.setString('saved_projects', encodedData);

      if (mounted) {
        Navigator.pop(context, true); // Pop and signal a refresh
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _githubController.dispose();
    _liveLinkController.dispose();
    _toolsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingProject != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Admin: Edit App' : 'Admin: Add New App'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickAndSaveImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  image: _savedImagePath != null
                      ? DecorationImage(
                          image: FileImage(File(_savedImagePath!)),
                          fit: BoxFit.cover,
                        )
                      : (widget.existingProject?.imagePaths.isNotEmpty == true && 
                         widget.existingProject!.imagePaths.first.startsWith('assets/'))
                          ? DecorationImage(
                              image: AssetImage(widget.existingProject!.imagePaths.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child: _savedImagePath == null && 
                       (widget.existingProject == null || widget.existingProject!.imagePaths.first == 'assets/images/placeholder.png')
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 50),
                          SizedBox(height: 8),
                          Text('Tap to update App Cover Image')
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'App Title', border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _toolsController,
              decoration: const InputDecoration(labelText: 'Tools Used (comma separated)', border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? 'Please list at least one tool' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _githubController,
              decoration: const InputDecoration(labelText: 'GitHub Link (Optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _liveLinkController,
              decoration: const InputDecoration(labelText: 'Live Demo Link (Optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saveProject,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(isEditing ? 'Update Project' : 'Save to Portfolio', style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}