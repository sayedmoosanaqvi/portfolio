import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:portfolio/models/project_model.dart';

class AddProjectScreen extends StatefulWidget {
  final ProjectModel? existingProject;

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
  
  late TextEditingController _videoPathController;
  late TextEditingController _modelPathController;
  
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
    final project = widget.existingProject;
    
    _titleController = TextEditingController(text: project?.title ?? '');
    _descriptionController = TextEditingController(text: project?.description ?? '');
    _githubController = TextEditingController(text: project?.githubLink ?? '');
    _liveLinkController = TextEditingController(text: project?.liveLink ?? '');
    _toolsController = TextEditingController(text: project?.toolsUsed.join(', ') ?? '');
    
    _videoPathController = TextEditingController(text: project?.videoPath ?? '');
    _modelPathController = TextEditingController(text: project?.modelPath ?? '');
    
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
      
      List<String> imageList = ['assets/images/placeholder.png'];
      if (_savedImagePath != null) {
        imageList = [_savedImagePath!];
      } else if (widget.existingProject != null && widget.existingProject!.imagePaths.isNotEmpty) {
        imageList = widget.existingProject!.imagePaths;
      }

      final String projectId = widget.existingProject?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final updatedProject = ProjectModel(
        id: projectId, 
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        imagePaths: imageList, 
        githubLink: _githubController.text.isNotEmpty ? _githubController.text.trim() : null,
        liveLink: _liveLinkController.text.isNotEmpty ? _liveLinkController.text.trim() : null,
        videoPath: _videoPathController.text.isNotEmpty ? _videoPathController.text.trim() : null,
        modelPath: _modelPathController.text.isNotEmpty ? _modelPathController.text.trim() : null,
        toolsUsed: _toolsController.text.split(',').map((e) => e.trim()).toList(),
      );
      
      final prefs = await SharedPreferences.getInstance();
      final String? projectsJson = prefs.getString('saved_projects');
      List<ProjectModel> currentProjects = [];

      if (projectsJson != null) {
        final List<dynamic> decoded = jsonDecode(projectsJson);
        currentProjects = decoded.map((item) => ProjectModel.fromJson(item)).toList();
      } else {
        // Assuming portfolioProjects is globally accessible
        // currentProjects = List.from(portfolioProjects); 
      }

      currentProjects.removeWhere((item) => item.id == projectId);
      currentProjects.add(updatedProject);

      final String encodedData = jsonEncode(currentProjects.map((p) => p.toJson()).toList());
      await prefs.setString('saved_projects', encodedData);

      if (mounted) {
        Navigator.pop(context, true); 
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
    _videoPathController.dispose();
    _modelPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingProject != null;
    final theme = Theme.of(context);

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
                  color: theme.inputDecorationTheme.fillColor, // Inherits the theme's input background
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
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
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 50, color: theme.colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to update App Cover Image',
                            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                          )
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              // Stripped hardcoded borders so it uses your global InputDecorationTheme
              decoration: const InputDecoration(labelText: 'App Title'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _toolsController,
              decoration: const InputDecoration(labelText: 'Tools Used (comma separated)'),
              validator: (value) => value == null || value.isEmpty ? 'Please list at least one tool' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _githubController,
              decoration: const InputDecoration(labelText: 'GitHub Link (Optional)'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _liveLinkController,
              decoration: const InputDecoration(labelText: 'Live Demo Link (Optional)'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _videoPathController,
              decoration: const InputDecoration(
                labelText: 'Video Asset Path (Optional)', 
                hintText: 'e.g., assets/videos/Headset.mp4',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modelPathController,
              decoration: const InputDecoration(
                labelText: '3D Model Asset Path (Optional)', 
                hintText: 'e.g., assets/models/headset.glb',
              ),
            ),
            const SizedBox(height: 32),
            // Replaced with ElevatedButton to trigger global custom button theme
            ElevatedButton(
              onPressed: _saveProject,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56), // Gives the button a nice full width
              ),
              child: Text(
                isEditing ? 'Update Project' : 'Save to Portfolio',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}