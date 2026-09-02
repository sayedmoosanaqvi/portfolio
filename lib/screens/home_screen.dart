import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portfolio/models/project_model.dart'; 
import 'package:portfolio/screens/project_details_screen.dart';
import 'package:portfolio/screens/add_project_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portfolio/theme/theme_provider.dart';

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
        // Assuming portfolioProjects is your fallback dummy data
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

  void _launchUrlAndClose(String urlString) {
    _launchUrl(urlString);
    Navigator.pop(context);
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        hoverColor: theme.colorScheme.primary.withOpacity(0.05),
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    final filteredProjects = selectedCategory == 'All'
        ? displayProjects
        : displayProjects.where((project) => project.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Moosa Raza',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: false,
        actions: [
          // Quick Theme Toggle
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: theme.colorScheme.primary,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
            tooltip: 'Refresh Showcase',
            onPressed: _loadProjects,
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        width: MediaQuery.of(context).size.width * 0.75, // Slightly slimmer, modern width
        child: Column(
          children: [
            // Custom Airy Header
            Container(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05), // Very subtle primary tint
                border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onLongPress: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddProjectScreen()),
                      );
                      if (result == true) {
                        _loadProjects();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4), // Space for the ring
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3), 
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: theme.colorScheme.surface,
                        backgroundImage: const AssetImage('assets/images/profile.jpg'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Moosa Raza",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Full-Stack Developer\n& 3D Specialist",
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Drawer Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.work_outline_rounded,
                    title: 'Hire me on Fiverr',
                    onTap: () => _launchUrlAndClose('https://www.fiverr.com/'),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.code_rounded,
                    title: 'GitHub Projects',
                    onTap: () => _launchUrlAndClose('https://github.com/sayedmoosanaqvi'),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.link_rounded,
                    title: 'LinkedIn Profile',
                    onTap: () => _launchUrlAndClose('https://www.linkedin.com/in/moosa-naqvi/'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Divider(color: Colors.grey.withOpacity(0.1)),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.email_outlined,
                    title: 'Contact Me',
                    onTap: () => _launchUrlAndClose('mailto:sayedmoosanaqvi@gmail.com?subject=Portfolio%20Inquiry'),
                  ),
                ],
              ),
            ),
            
            // Clean Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "© 2026 Moosa Raza",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 4.0),
            child: Text(
              "My Portfolio",
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Clean Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? theme.colorScheme.primary : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
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

          // Clean Vertical Feed
          Expanded(
            child: filteredProjects.isEmpty
                ? const Center(child: Text('No projects found in this category.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () async {
                            final refresh = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectDetailScreen(project: project),
                              ),
                            );
                            if (refresh == true) {
                              _loadProjects();
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Image Banner
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Hero(
                                  tag: project.id,
                                  child: project.imagePaths.isNotEmpty
                                      ? (project.imagePaths.first.startsWith('assets/')
                                          ? Image.asset(
                                              project.imagePaths.first,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(project.imagePaths.first),
                                              fit: BoxFit.cover,
                                            ))
                                      : Container(
                                          color: theme.colorScheme.surface,
                                          child: const Icon(Icons.image, color: Colors.grey),
                                        ),
                                ),
                              ),
                              
                              // Card Content
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          project.category.toUpperCase(),
                                          style: TextStyle(
                                            color: theme.colorScheme.secondary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 16,
                                          color: Colors.grey.withOpacity(0.5),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      project.title,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      project.description,
                                      style: TextStyle(
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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