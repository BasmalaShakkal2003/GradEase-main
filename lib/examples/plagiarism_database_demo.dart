import 'package:grad_ease/AI/check_palagrism.dart';

/// Example usage of the updated plagiarism checker with proper database structure
void main() async {
  print("=== GradEase Plagiarism Checker Demo ===\n");
  
  // Example 1: Get all group descriptions with proper structure
  print("1. Fetching all groups with proper database structure...");
  List<Map<String, dynamic>> groups = await PlagiarismChecker.getAllGroupDescriptions();
  
  if (groups.isNotEmpty) {
    print("✅ Found ${groups.length} groups");
    
    // Show details of first group
    var firstGroup = groups.first;
    print("\nFirst Group Details:");
    print("• Group ID (Document ID): ${firstGroup['groupId']}");
    print("• Group Name: ${firstGroup['groupName']}");
    print("• Leader UID (same as Group ID): ${firstGroup['leaderUid']}");
    print("• Leader Name (from users table): ${firstGroup['leaderName']}");
    print("• Members: ${firstGroup['member_count']} total (1 leader + ${firstGroup['member_count'] - 1} members)");
    
    // Example 2: Get detailed group information including member names
    print("\n2. Getting detailed group information...");
    Map<String, dynamic>? detailedInfo = await PlagiarismChecker.getDetailedGroupInfo(firstGroup['groupId']);
    
    if (detailedInfo != null) {
      print("✅ Detailed info retrieved:");
      print("• Group: ${detailedInfo['groupName']}");
      print("• Leader: ${detailedInfo['leaderName']}");
      print("• Total Members: ${detailedInfo['member_count']}");
      print("• Members from subcollection 'members':");
      
      List<Map<String, dynamic>> members = detailedInfo['members'];
      for (var member in members) {
        String roleLabel = member['role'] == 'leader' ? '(Leader)' : '(Member)';
        print("  - ${member['name']} $roleLabel (${member['uid']})");
      }
      
      print("• Member count calculation: 1 leader + ${members.length - 1} members from subcollection = ${members.length} total");
    }
    
    // Example 3: Test plagiarism checking
    print("\n3. Testing plagiarism checking...");
    String testDescription = "Our project is a mobile application for student management using Flutter and Firebase technology.";
    
    String result = await PlagiarismChecker.checkPlagiarism(testDescription);
    print("Plagiarism Check Result:");
    print(result.substring(0, result.length > 200 ? 200 : result.length) + "...");
    
  } else {
    print("❌ No groups found in database");
  }
  
  print("\n=== Demo completed ===");
  
  // Run comprehensive tests if needed
  // await PlagiarismTestHelper.runAllTests();
}
