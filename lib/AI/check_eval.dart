import 'package:google_generative_ai/google_generative_ai.dart';

class ProjectEvaluator {
  // Get API key from environment variable
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY', 
    defaultValue: 'AIzaSyAQAtaGMuZ07Nx3MoFS_HGcz5_VDuLNvSw');
  
  /// Public getter for API key status checking
  static bool get isApiKeyConfigured => _apiKey != 'your-gemini-api-key-here';
  
  /// Evaluates a project description using Gemini AI
  static Future<String> evaluateProject(String description) async {
    try {
      // Initialize the Gemini model
      final model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: _apiKey,
      );
      
      // Create the evaluation prompt based on the prompt.py structure
      final prompt = _buildEvaluationPrompt(description);
      
      // Generate content using Gemini AI
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        return _fallbackEvaluation(description);
      }
    } catch (e) {
      print('Error evaluating project with Gemini AI: $e');
      return _fallbackEvaluation(description);
    }
  }
  
  /// Builds the evaluation prompt focused on graduation projects with technical perspective
  static String _buildEvaluationPrompt(String description) {
    return '''
You are evaluating a GRADUATION PROJECT proposal for a computer science/engineering student. 
Provide a comprehensive technical and academic evaluation based on the following criteria:

**TECHNICAL EVALUATION CRITERIA:**

**1. Technical Depth & Innovation (25%)**
- Complexity and sophistication of technical approach
- Use of modern technologies, frameworks, and tools
- Innovation and originality in solution design
- Technical challenges addressed and solutions proposed

**2. Project Scope & Feasibility (20%)**
- Realistic scope for a graduation project timeline (typically 1-2 semesters)
- Clear definition of project boundaries and limitations
- Feasibility of implementation with available resources
- Appropriate complexity level for undergraduate/graduate work

**3. Problem Definition & Solution (20%)**
- Clear identification of the problem being solved
- Justification for why this problem needs solving
- Proposed solution approach and methodology
- Expected outcomes and deliverables

**4. Technical Architecture & Design (15%)**
- System architecture and design patterns
- Database design and data management approach
- Technology stack selection and justification
- Security, scalability, and performance considerations

**5. Documentation Quality (10%)**
- Grammar, spelling, and professional writing
- Technical vocabulary usage and accuracy
- Clarity of technical explanations
- Logical flow and organization of ideas

**6. Academic Standards (10%)**
- Adherence to academic project requirements
- Potential for learning and skill development
- Research component and literature review potential
- Contribution to the field or practical applications

**EVALUATION OUTPUT FORMAT:**
Provide your evaluation as follows:

**Total Score: XX/100**

**DETAILED BREAKDOWN:**
- Technical Depth & Innovation: XX/25 - [Brief explanation]
- Project Scope & Feasibility: XX/20 - [Brief explanation]
- Problem Definition & Solution: XX/20 - [Brief explanation]
- Technical Architecture & Design: XX/15 - [Brief explanation]
- Documentation Quality: XX/10 - [Brief explanation]
- Academic Standards: XX/10 - [Brief explanation]

**TECHNICAL ASSESSMENT:**
- **Strengths:** [List 3-5 key technical strengths]
- **Areas for Improvement:** [List 3-5 specific technical improvements needed]
- **Technology Recommendations:** [Suggest specific technologies, frameworks, or approaches]

**ACADEMIC EVALUATION:**
- **Grade Recommendation:** [A+/A/B+/B/C+ with justification]
- **Learning Outcomes:** [Expected skills and knowledge to be gained]
- **Research Potential:** [Opportunities for academic research or publication]

**IMPLEMENTATION ROADMAP:**
- **Phase 1 (Months 1-2):** [Critical initial tasks]
- **Phase 2 (Months 3-4):** [Core development phase]
- **Phase 3 (Months 5-6):** [Testing, optimization, documentation]

**SUPERVISOR RECOMMENDATIONS:**
- **Weekly Check-ins:** [Specific areas requiring supervision]
- **Milestone Reviews:** [Key deliverables to track progress]
- **Risk Mitigation:** [Potential challenges and solutions]

**INDUSTRY RELEVANCE:**
- **Market Application:** [Real-world applications and value]
- **Career Development:** [Skills relevant to industry employment]
- **Portfolio Value:** [Contribution to student's professional portfolio]

**PROJECT TO EVALUATE:**
$description

**IMPORTANT:** Focus on technical merit, academic rigor, and practical feasibility for a graduation project. Consider this as a capstone project that should demonstrate the student's technical competency and readiness for professional work.
''';
  }
  
  /// Fallback evaluation method focused on graduation project technical assessment
  static String _fallbackEvaluation(String description) {
    // Enhanced technical analysis for fallback
    final technicalScore = _calculateTechnicalScore(description);
    final scopeAssessment = _assessProjectScope(description);
    final innovationLevel = _assessInnovation(description);
    
    return '''
GRADUATION PROJECT EVALUATION REPORT

**Note:** This evaluation was generated using enhanced technical analysis. For comprehensive AI-powered evaluation, please configure your Gemini API key.

**TECHNICAL ASSESSMENT SUMMARY:**
**Overall Technical Score: ${technicalScore['overall']}/100**

**DETAILED BREAKDOWN:**
- Technical Depth: ${technicalScore['depth']}/25
- Project Scope: ${technicalScore['scope']}/20  
- Problem Definition: ${technicalScore['problem']}/20
- Architecture Design: ${technicalScore['architecture']}/15
- Documentation Quality: ${technicalScore['documentation']}/10
- Academic Standards: ${technicalScore['academic']}/10

**PROJECT ANALYSIS:**
- **Description Length:** ${description.length} characters
- **Technical Complexity:** ${technicalScore['complexity']}
- **Technology Stack Mentioned:** ${_identifyTechnologies(description).isNotEmpty ? 'Yes' : 'No'}
- **Implementation Details:** ${_mentionsImplementation(description) ? 'Adequate' : 'Needs Improvement'}
- **Innovation Level:** $innovationLevel
- **Scope Assessment:** $scopeAssessment

**IDENTIFIED TECHNOLOGIES:**
${_identifyTechnologies(description).isEmpty ? 'None specifically mentioned' : _identifyTechnologies(description).join(', ')}

**GRADUATION PROJECT RECOMMENDATIONS:**

**Technical Improvements:**
1. **Architecture Design:** Include system architecture diagrams and design patterns
2. **Technology Stack:** Specify frameworks, databases, and development tools
3. **Implementation Plan:** Provide detailed development phases and timelines
4. **Testing Strategy:** Include unit testing, integration testing, and user acceptance testing
5. **Deployment Plan:** Specify hosting, CI/CD, and production environment setup

**Academic Requirements:**
1. **Literature Review:** Include relevant research and existing solution analysis
2. **Methodology:** Define development methodology (Agile, Waterfall, etc.)
3. **Evaluation Metrics:** Specify how project success will be measured
4. **Risk Analysis:** Identify potential challenges and mitigation strategies
5. **Documentation:** Ensure technical documentation meets academic standards

**Supervisor Meeting Topics:**
- Project scope validation and feasibility assessment
- Technical architecture review and approval
- Timeline and milestone planning
- Resource requirements and availability
- Academic deliverables and evaluation criteria

**Grade Estimation:** ${_estimateGrade(technicalScore['overall']!)}

**Next Steps:**
1. Configure Gemini API key for detailed AI evaluation
2. Expand technical specifications and architecture details
3. Add implementation timeline with specific milestones
4. Include technology justification and alternative analysis
5. Prepare for supervisor consultation and approval

**To enable full AI evaluation:**
Set the GEMINI_API_KEY environment variable with your Google AI API key for comprehensive graduation project assessment.
''';
  }
  
  /// Calculate technical score for fallback evaluation
  static Map<String, int> _calculateTechnicalScore(String description) {
    final lowerText = description.toLowerCase();
    int depth = 15; // Base technical depth score
    int scope = 10; // Base scope score
    int problem = 10; // Base problem definition score
    int architecture = 8; // Base architecture score
    int documentation = 6; // Base documentation score
    int academic = 6; // Base academic score
    
    // Technical depth assessment
    if (_containsAdvancedTechnologies(lowerText)) depth += 5;
    if (_mentionsAlgorithms(lowerText)) depth += 3;
    if (_mentionsAI_ML(lowerText)) depth += 2;
    
    // Scope assessment
    if (_hasRealisticScope(lowerText)) scope += 5;
    if (_mentionsTimeline(lowerText)) scope += 3;
    if (_mentionsLimitations(lowerText)) scope += 2;
    
    // Problem definition assessment
    if (_definesProblemClearly(lowerText)) problem += 5;
    if (_justifiesSolution(lowerText)) problem += 3;
    if (_mentionsTargetUsers(lowerText)) problem += 2;
    
    // Architecture assessment
    if (_mentionsArchitecture(lowerText)) architecture += 4;
    if (_mentionsDatabase(lowerText)) architecture += 2;
    if (_mentionsSecurity(lowerText)) architecture += 1;
    
    // Documentation quality
    if (description.length > 500) documentation += 2;
    if (_hasProfessionalLanguage(description)) documentation += 2;
    
    // Academic standards
    if (_mentionsResearch(lowerText)) academic += 2;
    if (_mentionsMethodology(lowerText)) academic += 2;
    
    final overall = depth + scope + problem + architecture + documentation + academic;
    
    return {
      'overall': overall,
      'depth': depth,
      'scope': scope,
      'problem': problem,
      'architecture': architecture,
      'documentation': documentation,
      'academic': academic,
      'complexity': _getComplexityLevel(overall),
    };
  }
  
  /// Assess project scope for graduation project appropriateness
  static String _assessProjectScope(String description) {
    final lowerText = description.toLowerCase();
    
    if (_hasOverlyAmbitiousScope(lowerText)) {
      return 'Too Ambitious - Consider reducing scope for graduation project timeline';
    } else if (_hasMinimalScope(lowerText)) {
      return 'Too Simple - Consider adding complexity for graduation-level work';
    } else {
      return 'Appropriate - Good fit for graduation project requirements';
    }
  }
  
  /// Assess innovation level
  static String _assessInnovation(String description) {
    final lowerText = description.toLowerCase();
    
    if (_mentionsAI_ML(lowerText) && _containsAdvancedTechnologies(lowerText)) {
      return 'High - Incorporates cutting-edge technologies';
    } else if (_containsAdvancedTechnologies(lowerText) || _mentionsAI_ML(lowerText)) {
      return 'Moderate - Uses modern technologies';
    } else {
      return 'Basic - Consider adding innovative elements';
    }
  }
  
  /// Estimate grade based on technical score
  static String _estimateGrade(int score) {
    if (score >= 85) return 'A+ (Excellent) - Outstanding graduation project';
    if (score >= 75) return 'A (Very Good) - Strong graduation project';
    if (score >= 65) return 'B+ (Good) - Solid graduation project with improvements needed';
    if (score >= 55) return 'B (Satisfactory) - Adequate but requires significant enhancement';
    return 'C+ (Needs Work) - Major improvements required for graduation standards';
  }
  
  /// Get complexity level description
  static int _getComplexityLevel(int score) {
    if (score >= 80) return 5; // Very High
    if (score >= 70) return 4; // High
    if (score >= 60) return 3; // Moderate
    if (score >= 50) return 2; // Low
    return 1; // Very Low
  }
  
  /// Helper method to check for technical terms
  static bool _containsTechnicalTerms(String text) {
    final technicalTerms = [
      'api', 'database', 'algorithm', 'framework', 'architecture',
      'implementation', 'system', 'development', 'programming',
      'software', 'application', 'platform', 'interface', 'design'
    ];
    
    final lowerText = text.toLowerCase();
    return technicalTerms.any((term) => lowerText.contains(term));
  }
  
  /// Helper method to check for implementation mentions
  static bool _mentionsImplementation(String text) {
    final implementationTerms = [
      'implement', 'develop', 'build', 'create', 'design',
      'code', 'programming', 'coding', 'construction'
    ];
    
    final lowerText = text.toLowerCase();
    return implementationTerms.any((term) => lowerText.contains(term));
  }
  
  /// Identify technologies mentioned in the description
  static List<String> _identifyTechnologies(String text) {
    final technologies = [
      // Frontend Technologies
      'react', 'angular', 'vue', 'flutter', 'react native', 'ionic', 'xamarin',
      'html', 'css', 'javascript', 'typescript', 'bootstrap', 'tailwind',
      
      // Backend Technologies  
      'node.js', 'nodejs', 'express', 'django', 'flask', 'spring', 'laravel',
      'asp.net', '.net', 'ruby on rails', 'php', 'python', 'java', 'c#',
      
      // Databases
      'mysql', 'postgresql', 'mongodb', 'firebase', 'sqlite', 'redis',
      'oracle', 'sql server', 'cassandra', 'dynamodb',
      
      // Cloud & DevOps
      'aws', 'azure', 'google cloud', 'gcp', 'docker', 'kubernetes',
      'jenkins', 'ci/cd', 'terraform', 'ansible',
      
      // AI/ML Technologies
      'tensorflow', 'pytorch', 'scikit-learn', 'opencv', 'nlp', 'machine learning',
      'artificial intelligence', 'deep learning', 'neural network',
      
      // Mobile Technologies
      'android', 'ios', 'swift', 'kotlin', 'flutter', 'react native',
      
      // Other Technologies
      'blockchain', 'iot', 'api', 'rest', 'graphql', 'microservices',
      'websocket', 'oauth', 'jwt', 'git', 'github'
    ];
    
    final lowerText = text.toLowerCase();
    return technologies.where((tech) => lowerText.contains(tech)).toList();
  }
  
  /// Check for advanced technologies
  static bool _containsAdvancedTechnologies(String text) {
    final advanced = [
      'microservices', 'kubernetes', 'machine learning', 'blockchain',
      'artificial intelligence', 'deep learning', 'neural network',
      'tensorflow', 'pytorch', 'websocket', 'graphql', 'redis'
    ];
    return advanced.any((tech) => text.contains(tech));
  }
  
  /// Check for algorithm mentions
  static bool _mentionsAlgorithms(String text) {
    final algorithmTerms = [
      'algorithm', 'sorting', 'searching', 'optimization', 'hashing',
      'encryption', 'compression', 'pathfinding', 'clustering', 'classification'
    ];
    return algorithmTerms.any((term) => text.contains(term));
  }
  
  /// Check for AI/ML mentions
  static bool _mentionsAI_ML(String text) {
    final aimlTerms = [
      'artificial intelligence', 'machine learning', 'deep learning',
      'neural network', 'ai', 'ml', 'nlp', 'computer vision', 'data mining'
    ];
    return aimlTerms.any((term) => text.contains(term));
  }
  
  /// Check for realistic scope indicators
  static bool _hasRealisticScope(String text) {
    final scopeIndicators = [
      'prototype', 'mvp', 'minimum viable product', 'phase', 'milestone',
      'iterative', 'agile', 'sprint', 'feasible', 'realistic'
    ];
    return scopeIndicators.any((indicator) => text.contains(indicator));
  }
  
  /// Check for timeline mentions
  static bool _mentionsTimeline(String text) {
    final timelineTerms = [
      'timeline', 'schedule', 'month', 'week', 'semester', 'phase',
      'deadline', 'milestone', 'sprint', 'iteration'
    ];
    return timelineTerms.any((term) => text.contains(term));
  }
  
  /// Check for limitations mentions
  static bool _mentionsLimitations(String text) {
    final limitationTerms = [
      'limitation', 'constraint', 'scope', 'boundary', 'assumption',
      'risk', 'challenge', 'restriction'
    ];
    return limitationTerms.any((term) => text.contains(term));
  }
  
  /// Check for clear problem definition
  static bool _definesProblemClearly(String text) {
    final problemTerms = [
      'problem', 'issue', 'challenge', 'difficulty', 'pain point',
      'solve', 'address', 'tackle', 'overcome'
    ];
    return problemTerms.any((term) => text.contains(term));
  }
  
  /// Check for solution justification
  static bool _justifiesSolution(String text) {
    final justificationTerms = [
      'because', 'therefore', 'thus', 'since', 'as a result',
      'benefits', 'advantages', 'improves', 'enhances', 'solves'
    ];
    return justificationTerms.any((term) => text.contains(term));
  }
  
  /// Check for target users mention
  static bool _mentionsTargetUsers(String text) {
    final userTerms = [
      'user', 'customer', 'client', 'student', 'teacher', 'admin',
      'stakeholder', 'audience', 'target', 'end user'
    ];
    return userTerms.any((term) => text.contains(term));
  }
  
  /// Check for architecture mentions
  static bool _mentionsArchitecture(String text) {
    final architectureTerms = [
      'architecture', 'design pattern', 'mvc', 'mvvm', 'microservices',
      'monolithic', 'layered', 'component', 'module', 'structure'
    ];
    return architectureTerms.any((term) => text.contains(term));
  }
  
  /// Check for database mentions
  static bool _mentionsDatabase(String text) {
    final dbTerms = [
      'database', 'sql', 'nosql', 'mysql', 'postgresql', 'mongodb',
      'data model', 'schema', 'table', 'collection', 'storage'
    ];
    return dbTerms.any((term) => text.contains(term));
  }
  
  /// Check for security mentions
  static bool _mentionsSecurity(String text) {
    final securityTerms = [
      'security', 'authentication', 'authorization', 'encryption',
      'ssl', 'https', 'oauth', 'jwt', 'firewall', 'vulnerability'
    ];
    return securityTerms.any((term) => text.contains(term));
  }
  
  /// Check for research mentions
  static bool _mentionsResearch(String text) {
    final researchTerms = [
      'research', 'literature', 'study', 'analysis', 'survey',
      'review', 'academic', 'paper', 'publication', 'methodology'
    ];
    return researchTerms.any((term) => text.contains(term));
  }
  
  /// Check for methodology mentions
  static bool _mentionsMethodology(String text) {
    final methodologyTerms = [
      'methodology', 'agile', 'scrum', 'waterfall', 'iterative',
      'development process', 'sdlc', 'approach', 'framework', 'method'
    ];
    return methodologyTerms.any((term) => text.contains(term));
  }
  
  /// Check for professional language
  static bool _hasProfessionalLanguage(String text) {
    // Check for proper capitalization, technical terms, and formal structure
    final sentences = text.split('.');
    final capitalizedSentences = sentences.where((s) => 
      s.trim().isNotEmpty && s.trim()[0].toUpperCase() == s.trim()[0]).length;
    
    return capitalizedSentences / sentences.length > 0.7;
  }
  
  /// Check for overly ambitious scope
  static bool _hasOverlyAmbitiousScope(String text) {
    final ambitiousTerms = [
      'revolutionary', 'completely new', 'never been done', 'breakthrough',
      'industry changing', 'disruptive', 'game changer', 'transform everything'
    ];
    return ambitiousTerms.any((term) => text.contains(term));
  }
  
  /// Check for minimal scope
  static bool _hasMinimalScope(String text) {
    final minimalIndicators = [
      'simple', 'basic', 'easy', 'straightforward', 'minimal',
      'just', 'only', 'small', 'quick', 'fast'
    ];
    return minimalIndicators.any((indicator) => text.contains(indicator)) && 
           text.length < 300;
  }
  
  /// Compares two project descriptions for plagiarism using Gemini AI
  static Future<String> checkPlagiarism(String description1, String description2) async {
    try {
      // Initialize the Gemini model
      final model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: _apiKey,
      );
      
      // Create the plagiarism check prompt based on the prompt.py structure
      final prompt = _buildPlagiarismPrompt(description1, description2);
      
      // Generate content using Gemini AI
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        return _fallbackPlagiarismCheck(description1, description2);
      }
    } catch (e) {
      print('Error checking plagiarism with Gemini AI: $e');
      return _fallbackPlagiarismCheck(description1, description2);
    }
  }
  
  /// Builds the plagiarism check prompt based on the structure from prompt.py
  static String _buildPlagiarismPrompt(String description1, String description2) {
    return '''
Please analyze the provided Descriptions and compare the project idea descriptions to detect any potential plagiarism. Your task is to:
Scan both descriptions for the core idea of the project.
Identify and highlight similar content between the two descriptions.
Output the following information:
The percentage of similarity between the project ideas.
A list or summary of the key similar points or phrases.
Clarify how the plagiarism percentage was calculated (e.g., based on matching phrases, concept overlap, structure, etc.). output as string

Description 1:
$description1

Description 2:
$description2
''';
  }
  
  /// Fallback plagiarism check when Gemini AI is not available
  static String _fallbackPlagiarismCheck(String description1, String description2) {
    // Simple word-based similarity check
    final words1 = description1.toLowerCase().split(RegExp(r'\W+'));
    final words2 = description2.toLowerCase().split(RegExp(r'\W+'));
    
    final commonWords = words1.where((word) => 
      word.length > 3 && words2.contains(word)).toSet();
    
    final totalWords = words1.length + words2.length;
    final similarity = (commonWords.length * 2 / totalWords * 100).round();
    
    return '''
PLAGIARISM ANALYSIS REPORT

**Note:** This analysis was generated using basic text comparison. For more accurate AI-powered plagiarism detection, please configure your Gemini API key.

**Similarity Assessment:**
These projects have **$similarity%** similarity.

**Common Terms Found:**
${commonWords.take(10).join(', ')}

**Analysis Method:**
The similarity percentage is based on common words (longer than 3 characters) found in both descriptions. This is a basic comparison and may not reflect actual conceptual similarity.

**Recommendations:**
1. Configure Gemini API key for AI-powered analysis
2. Review projects manually for conceptual overlap
3. Check for similar methodologies and approaches
4. Ensure project uniqueness and originality

**To enable AI analysis:**
Set the GEMINI_API_KEY environment variable with your Google AI API key.
''';
  }
}
