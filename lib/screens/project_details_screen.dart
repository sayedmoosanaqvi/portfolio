import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:portfolio/models/project_model.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portfolio/screens/add_project_screen.dart';

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
    if (widget.project.videoPath != null && widget.project.videoPath!.isNotEmpty) {
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

  Future<void> _deleteProject() async {
    final prefs = await SharedPreferences.getInstance();
    final String? projectsJson = prefs.getString('saved_projects');

    if (projectsJson != null) {
      final List<dynamic> decoded = jsonDecode(projectsJson);
      List<ProjectModel> currentProjects =
          decoded.map((item) => ProjectModel.fromJson(item)).toList();

      currentProjects.removeWhere((item) => item.id == widget.project.id);

      final String encodedData =
          jsonEncode(currentProjects.map((p) => p.toJson()).toList());
      await prefs.setString('saved_projects', encodedData);

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  void _confirmDelete() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Project?'),
        content: Text('Are you sure you want to remove "${widget.project.title}" from your portfolio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteProject();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: theme.colorScheme.secondary),
            tooltip: 'Edit Project',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProjectScreen(existingProject: widget.project),
                ),
              );
              
              if (result == true && mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
            tooltip: 'Delete Project',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Banner Preview Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
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
                                color: theme.colorScheme.surface,
                                child: const Icon(Icons.image, size: 50, color: Colors.grey),
                              ),
                            )
                          : Image.file(
                              File(widget.project.imagePaths.first),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: theme.colorScheme.surface,
                                child: const Icon(Icons.image, size: 50, color: Colors.grey),
                              ),
                            ))
                      : Container(color: theme.colorScheme.surface),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Badge & Title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.project.category.toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.project.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              widget.project.description,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 24),

            // Tools Used Section
            Text(
              "Technologies Used",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: widget.project.toolsUsed
                  .map((tool) => Chip(
                        label: Text(tool),
                        backgroundColor: theme.colorScheme.surface,
                        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Link Action Buttons
            if (widget.project.githubLink != null || widget.project.liveLink != null) ...[
              Row(
                children: [
                  if (widget.project.githubLink != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _launchUrl(widget.project.githubLink!),
                        icon: const Icon(Icons.code_rounded),
                        label: const Text('View Source'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // Match new pill theme
                          ),
                        ),
                      ),
                    ),
                  if (widget.project.githubLink != null && widget.project.liveLink != null)
                    const SizedBox(width: 12),
                  if (widget.project.liveLink != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(widget.project.liveLink!),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Live Demo'),
                        // Leverages the global ElevatedButtonTheme automatically
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),
            ],

            // 2026 Modern 3D Model Interactive Card
            if (widget.project.modelPath != null && widget.project.modelPath!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.view_in_ar_rounded, color: theme.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    "Interactive 3D Experience",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Touch and drag to rotate the model in 360° space",
                style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Container(
                height: 320,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                clipBehavior: Clip.antiAlias,
                child: ModelViewer(
                  src: widget.project.modelPath!,
                  alt: "A 3D model of ${widget.project.title}",
                  ar: true,
                  autoRotate: true,
                  cameraControls: true,
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 28),
            ],

            // 2026 Video Demo Player Showcase
            if (widget.project.videoPath != null && widget.project.videoPath!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.play_circle_fill_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    "Video Showcase",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                clipBehavior: Clip.antiAlias,
                child: AspectRatio(
                  aspectRatio: _videoController?.value.isInitialized == true
                      ? _videoController!.value.aspectRatio
                      : 16 / 9,
                  child: _videoController != null && _videoController!.value.isInitialized
                      ? Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(_videoController!),
                            VideoProgressIndicator(
                              _videoController!,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: theme.colorScheme.secondary,
                              ),
                            ),
                            Center(
                              child: IconButton(
                                iconSize: 56,
                                icon: Icon(
                                  _videoController!.value.isPlaying
                                      ? Icons.pause_circle_filled_rounded
                                      : Icons.play_circle_fill_rounded,
                                  color: Colors.white.withOpacity(0.9),
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
                          color: theme.colorScheme.surface,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ],
        ),
      ),
    );
  }
}