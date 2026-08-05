import 'dart:convert';
import 'dart:io'; // Crucial for reading local image files
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portfolio/models/project_model.dart'; 
import 'package:portfolio/screens/project_details_screen.dart';
import 'package:portfolio/screens/add_project_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  List<ProjectModel> displayProjects = [];

  final List<String> categories = [
    'All',
    'Mobile Application',
    'Web Application',
    'Backend Architecture',
  ];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final String? projectsJson = prefs.getString('saved_projects');

    if (projectsJson != null) {
      final List<dynamic> decoded = jsonDecode(projectsJson);
      setState(() {
        displayProjects = decoded.map((item) => ProjectModel.fromJson(item)).toList();
      });
    } else {
      setState(() {
        displayProjects = List.from(portfolioProjects);
      });
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProjects = selectedCategory == 'All'
        ? displayProjects
        : displayProjects.where((project) => project.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moosa Raza - Developer Portfolio'),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text(
                "Moosa Raza",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: const Text("Full-Stack Developer & 3D Specialist"),
              currentAccountPicture: GestureDetector(
                // --- SECRET ADMIN TRIGGER ---
                onLongPress: () async {
                  Navigator.pop(context); // Close drawer
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddProjectScreen()),
                  );
                  if (result == true) {
                    _loadProjects(); // Refresh gallery on save
                  }
                },
                child:CircleAvatar(
  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
  backgroundImage: const AssetImage('assets/images/profile.jpg'),
),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Hire me on Fiverr'),
              onTap: () {
                _launchUrl('https://www.fiverr.com/');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('GitHub Projects'),
              onTap: () {
                _launchUrl('https://github.com/sayedmoosanaqvi');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('LinkedIn Profile'),
              onTap: () {
                _launchUrl('https://www.linkedin.com/in/moosa-naqvi/');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
  leading: const Icon(Icons.email),
  title: const Text('Contact Me'),
  onTap: () {
    _launchUrl('mailto:sayedmoosanaqvi@gmail.com?subject=Portfolio%20Inquiry&body=Hi%20Moosa,%0A%0A');
    Navigator.pop(context);
  },
)
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Main Project Grid
          Expanded(
            child: filteredProjects.isEmpty
                ? const Center(child: Text('No projects found in this category.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDetailScreen(project: project),
                            ),
                          );
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Image section supporting both local files & assets
                              Expanded(
                                child: Hero(
                                  tag: project.id,
                                  child: project.imagePaths.isNotEmpty
                                      ? (project.imagePaths.first.startsWith('assets/')
                                          ? Image.asset(
                                              project.imagePaths.first,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: Colors.grey.shade800,
                                                child: const Icon(Icons.code, color: Colors.white54),
                                              ),
                                            )
                                          : Image.file(
                                              File(project.imagePaths.first),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: Colors.grey.shade800,
                                                child: const Icon(Icons.code, color: Colors.white54),
                                              ),
                                            ))
                                      : Container(
                                          color: Colors.grey.shade800,
                                          child: const Icon(Icons.code, color: Colors.white54),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      project.category,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}