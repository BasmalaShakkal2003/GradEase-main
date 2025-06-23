import 'lib/AI/check_palagrism.dart';

void main() async {
  print("Testing simple plagiarism checker...");
  
  // Test simple plagiarism check
  String testDescription = "This is a simple test description for a mobile app project using Flutter and Firebase.";
  
  try {
    String result = await PlagiarismChecker.checkPlagiarism(testDescription);
    print("\n--- SIMPLE PLAGIARISM CHECK RESULT ---");
    print(result);
    print("\n--- TEST COMPLETED SUCCESSFULLY ---");
  } catch (e) {
    print("Error during test: $e");
  }
}
