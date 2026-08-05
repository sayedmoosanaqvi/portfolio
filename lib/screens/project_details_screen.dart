import 'dart:convert';
import 'dart:io'; // Required for displaying local device images
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:portfolio/models/project_model.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portfolio/screens/add_project_screen.dart'; // Required for editing

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.project.videoPath != null) {
      _videoController = VideoPlayerController.asset(widget.project.videoPath!)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  // Helper method to remove project from local storage
  Future<void> _deleteProject() async {
    final prefs = await SharedPreferences.getInstance();
    final String? projectsJson = prefs.getString('saved_projects');

    if (projectsJson != null) {
      final List<dynamic> decoded = jsonDecode(projectsJson);
      List<ProjectModel> currentProjects =
          decoded.map((item) => ProjectModel.fromJson(item)).toList();

      // Remove item matching this project's ID
      currentProjects.removeWhere((item) => item.id == widget.project.id);

      // Re-encode and update storage
      final String encodedData =
          jsonEncode(currentProjects.map((p) => p.toJson()).toList());
      await prefs.setString('saved_projects', encodedData);

      if (mounted) {
        Navigator.pop(context, true); // Pop screen and trigger home refresh
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text('Are you sure you want to remove "${widget.project.title}" from your portfolio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteProject();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.title),
        actions: [
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blueAccent),
            tooltip: 'Edit Project',
            onPressed: () async {
              // Navigate to the edit screen, passing the current project
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProjectScreen(existingProject: widget.project),
                ),
              );
              
              // If the project was updated, return true to the Home Screen so it refreshes
              if (result == true && mounted) {
                Navigator.pop(context, true); 
              }
            },
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete Project',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview supporting both asset paths and device file paths
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Hero(
                  tag: widget.project.id,
                  child: widget.project.imagePaths.isNotEmpty
                      ? (widget.project.imagePaths.first.startsWith('assets/')
                          ? Image.asset(
                              widget.project.imagePaths.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.image, size: 50, color: Colors.white54),
                              ),
                            )
                          : Image.file(
                              File(widget.project.imagePaths.first),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.image, size: 50, color: Colors.white54),
                              ),
                            ))
                      : Container(color: Colors.grey.shade800),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category & Title
            Text(
              widget.project.category,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.project.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              widget.project.description,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Tools Used Tags
            const Text(
              "Tools & Technologies",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: widget.project.toolsUsed
                  .map((tool) => Chip(
                        label: Text(tool),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Action Buttons for GitHub / Live Demo Links
            if (widget.project.githubLink != null ||
                widget.project.liveLink != null) ...[
              Row(
                children: [
                  if (widget.project.githubLink != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(widget.project.githubLink!),
                        icon: const Icon(Icons.code),
                        label: const Text('View Code'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (widget.project.githubLink != null &&
                      widget.project.liveLink != null)
                    const SizedBox(width: 12),
                  if (widget.project.liveLink != null)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _launchUrl(widget.project.liveLink!),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Live Demo'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // 3D Model Viewer Section
            if (widget.project.modelPath != null) ...[
              const Text(
                "Interactive 3D View",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Drag to rotate, pinch to zoom",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 300,
                  child: ModelViewer(
                    src: widget.project.modelPath!,
                    alt: "A 3D model of ${widget.project.title}",
                    ar: true,
                    autoRotate: true,
                    cameraControls: true,
                    backgroundColor: Colors.black12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Video Demo Section
            if (widget.project.videoPath != null) ...[
              const Text(
                "Demo Video",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: _videoController?.value.isInitialized == true
                      ? _videoController!.value.aspectRatio
                      : 16 / 9,
                  child: _videoController != null &&
                          _videoController!.value.isInitialized
                      ? Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(_videoController!),
                            VideoProgressIndicator(_videoController!,
                                allowScrubbing: true),
                            Center(
                              child: IconButton(
                                iconSize: 50,
                                icon: Icon(
                                  _videoController!.value.isPlaying
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _videoController!.value.isPlaying
                                        ? _videoController!.pause()
                                        : _videoController!.play();
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                      : Container(
                          color: Colors.black26,
                          child: const Center(
                              child: CircularProgressIndicator()),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}