import '../AI/check_palagrism.dart';
import '../AI/check_eval.dart';

/// Comprehensive example showing how to use both standalone Gemini AI evaluation
/// and integrated plagiarism checking with AI enhancement
class ComprehensiveAIDemo {
  
  /// Demonstrates standalone AI project evaluation
  static Future<void> demonstrateStandaloneEvaluation() async {
    print('=== STANDALONE GEMINI AI EVALUATION ===\n');
    
    String projectDescription = '''
EduTrack Pro is an innovative learning management system designed to revolutionize 
educational technology in higher education institutions. The platform combines 
artificial intelligence, machine learning, and cloud computing to provide 
personalized learning experiences. Key features include adaptive learning paths, 
intelligent tutoring systems, real-time progress analytics, collaborative project 
management, and integrated assessment tools. The system uses microservices 
architecture built with Node.js and React, deployed on AWS with MongoDB for 
data persistence. Advanced features include natural language processing for 
automated essay grading, computer vision for plagiarism detection in submitted 
images, and predictive analytics for student performance forecasting.
''';
    
    print('Evaluating project with Gemini AI...\n');
    String evaluation = await ProjectEvaluator.evaluateProject(projectDescription);
    
    print('GEMINI AI EVALUATION:');
    print('=' * 60);
    print(evaluation);
    print('=' * 60);
  }
  
  /// Demonstrates integrated plagiarism checking with AI enhancement
  static Future<void> demonstrateIntegratedPlagiarismCheck() async {
    print('\n=== INTEGRATED AI PLAGIARISM CHECKING ===\n');
    
    String newProjectDescription = '''
SmartCampus is a comprehensive university management application that leverages 
IoT sensors, mobile technology, and data analytics to optimize campus operations. 
The platform provides real-time monitoring of lecture halls, library occupancy, 
parking availability, and energy consumption. Students can use the mobile app 
to find available study spaces, reserve equipment, track campus shuttle locations, 
and receive personalized recommendations for courses and activities. The backend 
is built using Python Django with PostgreSQL, while the mobile app uses Flutter 
for cross-platform compatibility. Machine learning algorithms analyze usage 
patterns to predict peak times and optimize resource allocation.
''';
    
    print('Checking plagiarism with AI enhancement...\n');
    print('This will compare against all existing group descriptions in Firebase');
    print('and use Gemini AI for intelligent similarity analysis.\n');
    
    String plagiarismReport = await PlagiarismChecker.checkPlagiarismWithAI(newProjectDescription);
    
    print('AI-ENHANCED PLAGIARISM REPORT:');
    print('=' * 60);
    print(plagiarismReport);
    print('=' * 60);
  }
  
  /// Demonstrates side-by-side comparison of two specific projects
  static Future<void> demonstrateDirectComparison() async {
    print('\n=== DIRECT PROJECT COMPARISON ===\n');
    
    String project1 = '''
HealthSync is a telemedicine platform that connects patients with healthcare 
providers through secure video consultations, electronic health records 
management, and prescription tracking. The system includes appointment 
scheduling, medical history storage, and integration with pharmacy systems 
for digital prescriptions.
''';
    
    String project2 = '''
MediConnect is a digital health platform designed to facilitate remote 
consultations between patients and medical professionals. Features include 
secure video calling, patient record management, appointment booking, and 
electronic prescription services with pharmacy integration.
''';
    
    print('Comparing two projects directly with Gemini AI...\n');
    String comparison = await ProjectEvaluator.checkPlagiarism(project1, project2);
    
    print('DIRECT COMPARISON RESULT:');
    print('=' * 60);
    print(comparison);
    print('=' * 60);
  }
  
  /// Shows the benefits of AI integration
  static void showAIBenefits() {
    print('\n=== AI INTEGRATION BENEFITS ===\n');
    
    print('🤖 GEMINI AI ADVANTAGES:');
    print('   ✓ Contextual understanding of project concepts');
    print('   ✓ Intelligent similarity detection beyond keyword matching');
    print('   ✓ Professional evaluation criteria analysis');
    print('   ✓ Detailed explanations of similarity calculations');
    print('   ✓ Grammar, spelling, and coherence assessment');
    print('   ✓ Diagram and documentation evaluation');
    print('');
    
    print('🔧 SYSTEM INTEGRATION:');
    print('   ✓ Seamless fallback to basic analysis if AI unavailable');
    print('   ✓ Real-time comparison with Firebase group database');
    print('   ✓ Comprehensive reporting with actionable recommendations');
    print('   ✓ Support for both standalone and integrated usage');
    print('   ✓ Error handling and graceful degradation');
    print('');
    
    print('📊 EVALUATION CRITERIA:');
    print('   • Grammar and sentence structure analysis');
    print('   • Spelling accuracy verification');
    print('   • Vocabulary richness assessment');
    print('   • Clarity and readability measurement');
    print('   • Logical coherence evaluation');
    print('   • Diagram relevance and accuracy checking');
    print('');
    
    print('🔑 API STATUS: ${ProjectEvaluator.isApiKeyConfigured ? "CONFIGURED" : "NOT CONFIGURED"}');
    if (!ProjectEvaluator.isApiKeyConfigured) {
      print('   ⚠️  Set GEMINI_API_KEY environment variable for full AI features');
    }
    print('');
  }
  
  /// Runs all demonstration functions
  static Future<void> runComprehensiveDemo() async {
    print('=' * 80);
    print('    GRADEASE AI-POWERED EVALUATION SYSTEM DEMO');
    print('=' * 80);
    
    showAIBenefits();
    await demonstrateStandaloneEvaluation();
    await demonstrateDirectComparison();
    await demonstrateIntegratedPlagiarismCheck();
    
    print('\n' + '=' * 80);
    print('    DEMO COMPLETED SUCCESSFULLY');
    print('=' * 80);
    print('The AI integration is ready for production use in GradEase!');
    print('Students and supervisors can now benefit from intelligent project analysis.');
  }
}

/// Main function to run the comprehensive demo
void main() async {
  await ComprehensiveAIDemo.runComprehensiveDemo();
}
