import '../models/portfolio.dart';

abstract interface class PortfolioRepository {
  Portfolio load();
}

/// The single source of truth for the supplied 2026 CV. No backend required.
class LocalPortfolioRepository implements PortfolioRepository {
  const LocalPortfolioRepository();
  @override
  Portfolio load() => const Portfolio(
    profile: DeveloperProfile(
      name: 'Yorn Nona',
      title: 'Flutter Developer',
      location: 'Phnom Penh, Cambodia',
      experience: '6 months',
      specialization: 'iOS & Android mobile applications',
      summary:
          'Flutter developer with 6 months of experience building iOS and Android apps. I work with REST APIs, state management, and reusable interfaces, with hands-on experience deploying to the App Store.',
      email: 'Yornnonaistad@gmail.com',
      phone: '+855 96 809 3758',
      phoneUri: '+855968093758',
      telegramNumber: '0968093758',
      github: 'https://github.com/yornnona',
      linkedIn: 'https://www.linkedin.com/in/yorn-nona-69a90a345',
      telegramUrl: 'https://t.me/YornNona',
      portraitAsset: 'assets/images/yorn_nona_portrait.jpg',
      cvAsset: 'assets/documents/yorn_nona_cv.pdf',
      // Add verified linkedIn and telegramUrl here when supplied.
    ),
    projects: [
      PortfolioProject(
        id: 'notes',
        number: '01',
        title: 'Notes App',
        category: 'Productivity',
        description:
            'An iOS-style notes app with folders, rich content, and REST API integration.',
        technologies: ['Flutter', 'GetX', 'Dio', 'GetStorage'],
        features: [
          'Authentication and login',
          'Folder management',
          'Notes management',
          'Rich content handling',
          'Attachment workflows',
          'API integration',
          'Local session storage',
          'Modern iOS-style interface',
        ],
        contributions: [
          'Developed an iOS-style mobile interface.',
          'Implemented authentication, folder and notes management.',
          'Integrated REST APIs using Dio.',
          'Used GetX for state management and GetStorage for local session storage.',
          'Built rich content and attachment workflows.',
        ],
        architecture:
            'Conceptual flow: Flutter views, GetX state, and Dio REST APIs, with GetStorage for sessions. Based on the listed stack; the source structure is not available.',
        integration:
            'Dio connects authentication and notes to REST APIs. GetStorage keeps local sessions. Endpoint schemas are not available.',
        discussionTopics: [
          'Authentication and session lifecycle',
          'Rich content and attachment handling',
          'API errors and loading states',
        ],
      ),
      PortfolioProject(
        id: 'products',
        number: '02',
        title: 'E-commerce App',
        category: 'E-commerce',
        description:
            'A mobile shopping app with product discovery, favorites, and a shopping cart.',
        technologies: ['Flutter', 'Provider', 'REST API'],
        features: [
          'Product listing',
          'Product search',
          'Favorites management',
          'Shopping cart',
          'Checkout flow',
          'API-based product data',
          'Reusable widgets',
          'Responsive mobile layouts',
        ],
        contributions: [
          'Built responsive product browsing and search interfaces.',
          'Implemented favorites, a shopping cart and a checkout flow.',
          'Used Provider for application state management.',
          'Integrated API-based product data.',
          'Created reusable widgets for mobile layouts.',
        ],
        architecture:
            'Conceptual flow: reusable Flutter views, Provider state, and REST API product data. Based on the listed stack; the source structure is not available.',
        integration:
            'REST APIs provide product data. Provider manages browsing and shopping state. Payment processing is outside the documented scope.',
        discussionTopics: [
          'Keeping cart and favorites state consistent',
          'Product search and API loading states',
          'Reusable layouts across screen sizes',
        ],
      ),
    ],
    skills: [
      SkillCategory('Mobile development', 'mobile', [
        'Flutter',
        'Dart',
        'iOS and Android UI development',
        'Responsive layouts',
        'Reusable Flutter widgets',
      ]),
      SkillCategory('State management', 'state', [
        'GetX',
        'Provider',
        'Riverpod',
      ]),
      SkillCategory('API & data handling', 'api', [
        'RESTful APIs',
        'Dio',
        'JSON parsing',
        'Authentication',
        'Error handling',
        'GetStorage',
      ]),
      SkillCategory('Architecture', 'architecture', [
        'MVVM fundamentals',
        'Reusable component architecture',
        'Navigation and routing',
        'Application structure',
      ]),
      SkillCategory('Development tools', 'tools', [
        'Git',
        'GitHub',
        'Xcode',
        'App Store Connect',
        'Visual Studio Code',
      ]),
      SkillCategory('Working style', 'people', [
        'Mobile UI implementation',
        'API integration and debugging',
        'Team collaboration',
        'Problem-solving',
        'Continuous learning',
      ]),
    ],
    experiences: [
      WorkExperience(
        title: 'Flutter Developer',
        period: '2026 · 6 months',
        organization: 'OTOKHI Company',
        location: 'iOS & Android',
        responsibilities: [
          'Built responsive mobile interfaces for iOS and Android.',
          'Developed reusable Flutter widgets and navigation flows.',
          'Integrated REST APIs using Dio.',
          'Implemented authentication, JSON parsing, and error handling.',
          'Used GetX, Provider, and Riverpod for application state management.',
          'Worked with Xcode and App Store Connect for iOS deployment.',
        ],
      ),
      WorkExperience(
        title: 'Computer Teacher',
        period: '2024–2025',
        organization: 'Addbook Computer Center',
        location: 'Phnom Penh, Cambodia',
        responsibilities: [
          'Taught Microsoft Word, Excel, and PowerPoint.',
          'Delivered practical computer lessons.',
          'Provided technical guidance and student support.',
        ],
      ),
    ],
    educations: [
      Education(
        'Norton University',
        'Software Development',
        '3 Years',
        'Completed',
        logoAsset: 'assets/images/education_norton.png',
      ),
      Education(
        'Institute of Science and Technology Advanced Development (ISTAD)',
        'Web Development',
        '2 Years',
        'Completed',
        logoAsset: 'assets/images/education_cstad.png',
      ),
      Education(
        'ETEC Computer Center',
        'Mobile Development',
        'Short Course',
        'Completed',
        logoAsset: 'assets/images/education_etec.png',
      ),
      Education(
        'Sastra Digital Solution',
        'Flutter Development',
        'Short Course',
        'Completed',
        logoAsset: 'assets/images/education_sastra.png',
        monochromeLogo: true,
      ),
    ],
    languages: [
      SpokenLanguage('Khmer', 'Native'),
      SpokenLanguage('English', 'Basic'),
    ],
    programmingLanguages: [
      ProgrammingLanguage('Dart', 0.90, '90%'),
      ProgrammingLanguage('Kotlin', 0.70, '70%'),
      ProgrammingLanguage('Java', 0.60, '60%'),
      ProgrammingLanguage('Swift', 0.50, '50%'),
    ],
    journey:
        'I started by teaching computer skills at Addbook Computer Center. Today, I’m studying Software Development at ISTAD and building Flutter apps for iOS and Android.',
    deployment:
        'Deployed a Flutter iOS app with Xcode and App Store Connect, from signing and build preparation to release submission.',
  );
}
