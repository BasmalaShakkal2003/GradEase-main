import '../AI/check_eval.dart';

/// Demo file showing how to use the Gemini AI-powered project evaluation system
class GeminiEvaluationDemo {
  
  /// Demonstrates project evaluation using Gemini AI
  static Future<void> demonstrateProjectEvaluation() async {
    print('=== GEMINI AI PROJECT EVALUATION DEMO ===\n');
    
    // Sample project description
    String sampleProject = '''
The project introduces GradEase, a mobile application designed to streamline and enhance 
the management of graduation projects for students and faculty members. It tackles common 
challenges such as poor communication, missed deadlines, lack of proper guidance, and 
project duplication by offering a centralized, user-friendly platform. Key features include 
AI-powered topic suggestions, plagiarism detection, milestone tracking, real-time messaging, 
and task management. GradEase empowers students to work more independently and efficiently 
while enabling supervisors to monitor progress, provide timely feedback, and ensure academic 
integrity—ultimately improving the graduation project experience for all stakeholders.
''';
    
    print('Evaluating project: ${sampleProject.substring(0, 100)}...\n');
    
    // Call the Gemini AI evaluation
    String evaluation = await ProjectEvaluator.evaluateProject(sampleProject);
    
    print('EVALUATION RESULT:');
    print('=' * 50);
    print(evaluation);
    print('=' * 50);
  }
  
  /// Demonstrates plagiarism checking using Gemini AI
  static Future<void> demonstratePlagiarismCheck() async {
    print('\n=== GEMINI AI PLAGIARISM CHECK DEMO ===\n');
    
    // Sample project descriptions for comparison
    String project1 = '''
The project introduces GradEase, a mobile application designed to streamline and enhance 
the management of graduation projects for students and faculty members. It tackles common 
challenges such as poor communication, missed deadlines, lack of proper guidance, and 
project duplication by offering a centralized, user-friendly platform.
''';
    
    String project2 = '''
This document details a comprehensive graduation project titled "Asclepius", which is a 
web-based platform aimed at streamlining critical medical operations. It enables real-time 
communication and data sharing between hospitals, doctors, and clinics. Features include 
blood donation and tracking, medical case library, and doctor forums for consultations.
''';
    
    print('Comparing two project descriptions for plagiarism...\n');
    
    // Call the Gemini AI plagiarism check
    String plagiarismResult = await ProjectEvaluator.checkPlagiarism(project1, project2);
    
    print('PLAGIARISM CHECK RESULT:');
    print('=' * 50);
    print(plagiarismResult);
    print('=' * 50);
  }
  
  /// Shows setup instructions for Gemini AI
  static void showSetupInstructions() {
    print('\n=== GEMINI AI SETUP INSTRUCTIONS ===\n');
    
    print('To enable Gemini AI evaluation, follow these steps:');
    print('');
    print('1. Get a Gemini API key:');
    print('   - Visit: https://aistudio.google.com/app/apikey');
    print('   - Sign in with your Google account');
    print('   - Create a new API key');
    print('');
    print('2. Set the API key as an environment variable:');
    print('   - Add to your app configuration: GEMINI_API_KEY=your-api-key-here');
    print('   - Or modify the _apiKey constant in check_eval.dart');
    print('');
    print('3. Test the integration:');
    print('   - Run this demo to verify the AI evaluation works');
    print('   - Check the console for any error messages');
    print('');
    print('4. Without API key:');
    print('   - The system will fall back to basic text analysis');
    print('   - Still functional but less intelligent evaluation');
    print('');
    print('Current API Key Status: ${ProjectEvaluator.isApiKeyConfigured ? "CONFIGURED" : "NOT CONFIGURED"}');
    print('');
  }
  
  /// Runs all demo functions
  static Future<void> runAllDemos() async {
    showSetupInstructions();
    await demonstrateProjectEvaluation();
    await demonstratePlagiarismCheck();
    
    print('\n=== DEMO COMPLETED ===');
    print('The Gemini AI integration is now ready for use in GradEase!');
  }
}

/// Main function to run the demo
void main() async {
  await GeminiEvaluationDemo.runAllDemos();
}
