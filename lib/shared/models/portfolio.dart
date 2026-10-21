/// Immutable domain objects. Optional assets/links are absent until verified.
class DeveloperProfile {
  const DeveloperProfile({
    required this.name,
    required this.title,
    required this.location,
    required this.experience,
    required this.specialization,
    required this.summary,
    required this.email,
    required this.phone,
    required this.phoneUri,
    required this.telegramNumber,
    required this.github,
    this.linkedIn,
    this.telegramUrl,
    this.portraitAsset,
    required this.cvAsset,
  });
  final String name, title, location, experience, specialization, summary;
  final String email, phone, phoneUri, telegramNumber, github, cvAsset;
  final String? linkedIn, telegramUrl, portraitAsset;
}

class PortfolioProject {
  const PortfolioProject({
    required this.id,
    required this.number,
    required this.title,
    required this.category,
    required this.description,
    required this.technologies,
    required this.features,
    required this.contributions,
    required this.architecture,
    required this.integration,
    required this.discussionTopics,
    this.screenshots = const [],
    this.repositoryUrl,
    this.appStoreUrl,
  });
  final String id,
      number,
      title,
      category,
      description,
      architecture,
      integration;
  final List<String> technologies,
      features,
      contributions,
      discussionTopics,
      screenshots;
  final String? repositoryUrl, appStoreUrl;
}

class SkillCategory {
  const SkillCategory(this.name, this.symbol, this.skills);
  final String name, symbol;
  final List<String> skills;
}

class WorkExperience {
  const WorkExperience({
    required this.title,
    required this.period,
    required this.organization,
    required this.location,
    required this.responsibilities,
  });
  final String title, period, organization, location;
  final List<String> responsibilities;
}

class Education {
  const Education(this.institute, this.program, this.period, this.status);
  final String institute, program, period, status;
}

class SpokenLanguage {
  const SpokenLanguage(this.name, this.proficiency);
  final String name, proficiency;
}

class ProgrammingLanguage {
  const ProgrammingLanguage(this.name, this.proficiency, this.percentage);
  final String name;
  final double proficiency;
  final String percentage;
}

class Portfolio {
  const Portfolio({
    required this.profile,
    required this.projects,
    required this.skills,
    required this.experiences,
    required this.educations,
    required this.languages,
    required this.programmingLanguages,
    required this.deployment,
    required this.journey,
  });
  final DeveloperProfile profile;
  final List<PortfolioProject> projects;
  final List<SkillCategory> skills;
  final List<WorkExperience> experiences;
  final List<Education> educations;
  final List<SpokenLanguage> languages;
  final List<ProgrammingLanguage> programmingLanguages;
  final String deployment, journey;

  Education get education => educations.first;
}
