class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> imagePaths;
  final String? videoPath;
  final String? modelPath; 
  final String? githubLink;
  final String? liveLink;
  final List<String> toolsUsed;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imagePaths,
    this.videoPath,
    this.modelPath,
    this.githubLink,
    this.liveLink,
    required this.toolsUsed,
  });

  // Converts the object into a map for saving to local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imagePaths': imagePaths,
      'videoPath': videoPath,
      'modelPath': modelPath,
      'githubLink': githubLink,
      'liveLink': liveLink,
      'toolsUsed': toolsUsed,
    };
  }

  // Creates an object from local storage data
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
      videoPath: json['videoPath'],
      modelPath: json['modelPath'],
      githubLink: json['githubLink'],
      liveLink: json['liveLink'],
      toolsUsed: List<String>.from(json['toolsUsed'] ?? []),
    );
  }
}

// Keep your sample list here as default/fallback data
final List<ProjectModel> portfolioProjects = [
  ProjectModel(
    id: 'ridex_live_01',
    title: 'RideX',
    description: 'A cross-platform full-stack ride-hailing application featuring live Google Maps API tracking, dynamic fare calculations, and role-based authentication.',
    category: 'Mobile Application',
    imagePaths: ['assets/images/ridex_app.png'], // You can replace this with a real screenshot asset later
    githubLink: 'https://github.com/sayedmoosanaqvi',
    liveLink: 'https://sayedmoosanaqvi.github.io/RideX-Hosting/',
    toolsUsed: ['Flutter', 'Firebase', 'Google Maps API'],
  ),
  ProjectModel(
    id: 'tee_store_01',
    title: '3D Tee Store',
    description: 'An interactive 3D product visualization web application utilizing Blender, modelviewer, and AR view for real-time garment customization.',
    category: 'Web Application',
    imagePaths: ['assets/images/3d_app.png'],
    githubLink: 'https://github.com/sayedmoosanaqvi',
    liveLink: 'https://custom-360-tee-store.web.app/',
    toolsUsed: ['Flutter', 'Blender', 'ModelViewer', 'WebGL', 'Three.js'],
  ),
  ProjectModel(
    id: 'emergency_sos_01',
    title: 'Emergency SOS',
    description: 'An Emergency Alert System',
    category: 'Web Application',
    imagePaths: ['assets/images/emergency_sos.png'],
    githubLink: 'https://github.com/sayedmoosanaqvi',
    liveLink: 'https://sayedmoosanaqvi.github.io/AidSphere-Hosting/',
    toolsUsed: ['Flutter', 'Firebase'],
  ),
   ProjectModel(
    id: 'toefl_practice_01',
    title: 'TOEFL Practice',
    description: 'A web application for practicing TOEFL exam questions',
    category: 'Web Application',
    imagePaths: ['assets/images/speakeval_app.png'],
    githubLink: 'https://github.com/sayedmoosanaqvi',
    liveLink: 'https://speakeval-2a29e.firebaseapp.com/',
    toolsUsed: ['Flutter', 'Firebase'],
  ),
];