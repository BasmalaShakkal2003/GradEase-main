import 'package:grad_ease/AI/check_palagrism.dart';

/// Helper class for testing plagiarism checking functionality
class PlagiarismTestHelper {
  
  /// Test function to retrieve and display all group descriptions
  static Future<void> testRetrieveAllDescriptions() async {
    print("🔍 Fetching all group descriptions...\n");
    
    List<Map<String, dynamic>> descriptions = await PlagiarismChecker.getAllGroupDescriptions();
    
    if (descriptions.isEmpty) {
      print("❌ No group descriptions found in the database.");
      return;
    }
    
    print("✅ Found ${descriptions.length} group descriptions:\n");
    
    for (int i = 0; i < descriptions.length; i++) {
      var group = descriptions[i];
      print("📋 Group ${i + 1}:");
      print("   • Name: ${group['groupName']}");
      print("   • Leader: ${group['leaderName']} (UID: ${group['leaderUid']})");
      print("   • Members: ${group['member_count']}");
      print("   • Description: ${group['description'].toString().substring(0, group['description'].toString().length > 100 ? 100 : group['description'].toString().length)}${group['description'].toString().length > 100 ? '...' : ''}");
      print("   • Group ID: ${group['groupId']}");
      print("");
    }
  }
  
  /// Test function to demonstrate plagiarism checking
  static Future<void> testPlagiarismCheck(String testDescription, {String? excludeGroupId}) async {
    print("🔍 Testing plagiarism check...\n");
    print("📝 Test description: ${testDescription.substring(0, testDescription.length > 100 ? 100 : testDescription.length)}${testDescription.length > 100 ? '...' : ''}\n");
    
    // Test simulation version
    print("--- SIMULATION RESULTS ---");
    String simulationResult = await PlagiarismChecker.checkPlagiarismAgainstGroups(
      testDescription, 
      currentGroupId: excludeGroupId
    );
    print(simulationResult);
    print("\n");
    
    // Test real comparison version
    print("--- REAL COMPARISON RESULTS ---");
    String realResult = await PlagiarismChecker.checkRealPlagiarism(
      testDescription,
      currentGroupId: excludeGroupId,
      threshold: 0.2 // Lower threshold for testing
    );
    print(realResult);
  }
  
  /// Test function to find similar groups
  static Future<void> testFindSimilarGroups(String testDescription, {String? excludeGroupId}) async {
    print("🔍 Finding similar groups...\n");
    
    List<Map<String, dynamic>> matches = await PlagiarismChecker.findActualMatches(
      testDescription,
      excludeGroupId,
      threshold: 0.1 // Very low threshold to find any similarities
    );
    
    if (matches.isEmpty) {
      print("✅ No similar groups found.");
      return;
    }
    
    print("⚠️ Found ${matches.length} potentially similar groups:\n");
    
    for (var match in matches) {
      print("📋 ${match['groupName']}");
      print("   • Similarity: ${match['similarityPercentage']}%");
      print("   • Leader: ${match['leaderName']}");
      print("   • Description: ${match['description'].toString().substring(0, match['description'].toString().length > 150 ? 150 : match['description'].toString().length)}${match['description'].toString().length > 150 ? '...' : ''}");
      print("");
    }
  }
  
  /// Test function to demonstrate detailed plagiarism analysis
  static Future<void> testDetailedPlagiarismAnalysis(String testDescription, {String? excludeGroupId}) async {
    print("🔍 Testing detailed plagiarism analysis...\n");
    print("📝 Test description: ${testDescription.substring(0, testDescription.length > 100 ? 100 : testDescription.length)}${testDescription.length > 100 ? '...' : ''}\n");
    
    // Test detailed analysis
    print("--- DETAILED ANALYSIS RESULTS ---");
    String detailedResult = await PlagiarismChecker.generateDetailedPlagiarismReport(
      testDescription,
      currentGroupId: excludeGroupId,
      threshold: 0.15 // Lower threshold for testing
    );
    print(detailedResult);
    print("\n");
    
    // Test getting detailed matches separately
    print("--- DETAILED MATCHES DATA ---");
    List<Map<String, dynamic>> detailedMatches = await PlagiarismChecker.getDetailedPlagiarismMatches(
      testDescription,
      currentGroupId: excludeGroupId,
      threshold: 0.1
    );
    
    if (detailedMatches.isNotEmpty) {
      print("Found ${detailedMatches.length} detailed matches:");
      for (var match in detailedMatches.take(2)) { // Show first 2 matches
        var analysis = match['detailedAnalysis'];
        print("\n📊 ${match['groupName']}:");
        print("   • Similarity: ${match['similarityPercentage']}%");
        print("   • Common words: ${analysis['commonWordsCount']}");
        print("   • Common phrases: ${analysis['phraseMatchCount']}");
        print("   • Word overlap: ${analysis['wordOverlapPercentage']}%");
        print("   • Time difference: ${analysis['timeDifference']}");
        if (analysis['commonWords'].isNotEmpty) {
          print("   • Top common words: ${analysis['commonWords'].take(5).join(', ')}");
        }
        if (analysis['commonPhrases'].isNotEmpty) {
          print("   • Common phrases: ${analysis['commonPhrases'].take(2).join(', ')}");
        }
      }
    } else {
      print("✅ No detailed matches found.");
    }
  }
  
  /// Test function to demonstrate detailed group information retrieval
  static Future<void> testDetailedGroupInfo(String groupId) async {
    print("🔍 Testing detailed group information retrieval...\n");
    print("📝 Group ID: $groupId\n");
    
    Map<String, dynamic>? groupInfo = await PlagiarismChecker.getDetailedGroupInfo(groupId);
    
    if (groupInfo == null) {
      print("❌ Group not found or error occurred.");
      return;
    }
    
    print("✅ Group information retrieved successfully:");
    print("📋 Group Details:");
    print("   • Group ID: ${groupInfo['groupId']}");
    print("   • Group Name: ${groupInfo['groupName']}");
    print("   • Leader: ${groupInfo['leaderName']} (UID: ${groupInfo['leaderUid']})");
    print("   • Total Members: ${groupInfo['member_count']}");
    print("   • Supervisor ID: ${groupInfo['supervisor_id'] ?? 'Not assigned'}");
    print("   • Created At: ${groupInfo['createdAt']}");
    
    print("\n👥 Member Details:");
    List<Map<String, dynamic>> members = groupInfo['members'];
    if (members.isEmpty) {
      print("   • No members found");
    } else {
      for (int i = 0; i < members.length; i++) {
        var member = members[i];
        String roleLabel = member['role'] == 'leader' ? '(Leader)' : '(Member)';
        print("   ${i + 1}. ${member['name']} $roleLabel (UID: ${member['uid']})");
        if (member['email'].isNotEmpty) {
          print("      Email: ${member['email']}");
        }
      }
      print("   • Total: ${members.length} (1 leader + ${members.length - 1} members)");
    }
    
    print("\n📝 Description Preview:");
    String description = groupInfo['description'];
    print("   ${description.substring(0, description.length > 200 ? 200 : description.length)}${description.length > 200 ? '...' : ''}");
  }

  /// Test function to compare database structures
  static Future<void> testDatabaseStructure() async {
    print("🔍 Testing database structure understanding...\n");
    
    // Get all groups
    List<Map<String, dynamic>> groups = await PlagiarismChecker.getAllGroupDescriptions();
    
    if (groups.isEmpty) {
      print("❌ No groups found in database.");
      return;
    }
    
    print("✅ Database Structure Analysis:");
    print("📊 Total Groups: ${groups.length}\n");
    
    // Test the first group in detail
    var firstGroup = groups.first;
    print("🧪 Detailed Analysis of First Group:");
    print("   • Group Document ID: ${firstGroup['groupId']}");
    print("   • Group Name: ${firstGroup['groupName']}");
    print("   • Leader UID (same as Group ID): ${firstGroup['leaderUid']}");
    print("   • Leader Name (from users table): ${firstGroup['leaderName']}");
    print("   • Member Count: ${firstGroup['member_count']}");
    
    print("\n🔎 Testing detailed group info for this group...");
    await testDetailedGroupInfo(firstGroup['groupId']);
  }
  
  /// Test function to verify member count accuracy
  static Future<void> testMemberCountAccuracy() async {
    print("🔍 Testing member count accuracy...\n");
    
    List<Map<String, dynamic>> groups = await PlagiarismChecker.getAllGroupDescriptions();
    
    if (groups.isEmpty) {
      print("❌ No groups found for testing.");
      return;
    }
    
    print("📊 Member Count Verification:");
    print("=" * 50);
    
    for (int i = 0; i < groups.length && i < 3; i++) { // Test first 3 groups
      var group = groups[i];
      String groupId = group['groupId'];
      
      print("\n📋 Group ${i + 1}: ${group['groupName']}");
      print("   • Group ID: $groupId");
      print("   • Reported Member Count: ${group['member_count']}");
      
      // Get detailed info to verify count
      Map<String, dynamic>? detailedInfo = await PlagiarismChecker.getDetailedGroupInfo(groupId);
      
      if (detailedInfo != null) {
        List<Map<String, dynamic>> members = detailedInfo['members'];
        int leaderCount = members.where((m) => m['role'] == 'leader').length;
        int memberCount = members.where((m) => m['role'] == 'member').length;
        
        print("   • Detailed Count Breakdown:");
        print("     - Leaders: $leaderCount");
        print("     - Members: $memberCount");
        print("     - Total: ${members.length}");
        print("   • Member List:");
        
        for (var member in members) {
          String roleLabel = member['role'] == 'leader' ? '👑' : '👤';
          print("     $roleLabel ${member['name']} (${member['role']})");
        }
        
        // Verify accuracy
        bool isAccurate = group['member_count'] == members.length;
        print("   • Count Accuracy: ${isAccurate ? '✅ Correct' : '❌ Incorrect'}");
        
        if (!isAccurate) {
          print("     Expected: ${group['member_count']}, Actual: ${members.length}");
        }
      } else {
        print("   • ❌ Could not fetch detailed info");
      }
    }
    
    print("\n✅ Member count verification completed!");
  }
  
  /// Sample test descriptions for testing
  static const List<String> sampleDescriptions = [
    "Our project focuses on developing a mobile application for student management using Flutter and Firebase. The app will include features for attendance tracking, grade management, and communication between students and teachers.",
    
    "We are building a web-based e-commerce platform using React and Node.js. The system will handle product catalog, shopping cart, payment processing, and order management for online retailers.",
    
    "This project involves creating an AI-powered chatbot for customer service using natural language processing and machine learning. The bot will handle common customer queries and provide automated responses.",
    
    "Our graduation project is a blockchain-based voting system that ensures transparency and security in electoral processes. We use smart contracts and cryptographic techniques to maintain vote integrity.",
    
    "We are developing a IoT-based smart home automation system using Arduino and sensors. The system will control lighting, temperature, security, and energy consumption through a mobile interface."
  ];
  
  /// Run comprehensive tests
  static Future<void> runAllTests() async {
    print("🚀 Starting comprehensive plagiarism checker tests...\n");
    
    // Test 1: Member count accuracy verification
    await testMemberCountAccuracy();
    
    print("\n" + "="*50 + "\n");
    
    // Test 2: Database structure understanding
    await testDatabaseStructure();
    
    print("\n" + "="*50 + "\n");
    
    // Test 3: Retrieve all descriptions
    await testRetrieveAllDescriptions();
    
    print("\n" + "="*50 + "\n");
    
    // Test 4: Test detailed plagiarism analysis
    print("🧪 Detailed Analysis Test:");
    await testDetailedPlagiarismAnalysis(sampleDescriptions[0]);
    print("\n" + "-"*30 + "\n");
    
    // Test 5: Test standard plagiarism checking with sample descriptions
    for (int i = 0; i < sampleDescriptions.length && i < 2; i++) {
      print("🧪 Standard Test ${i + 1}:");
      await testPlagiarismCheck(sampleDescriptions[i]);
      print("\n" + "-"*30 + "\n");
    }
    
    print("✅ All tests completed!");
  }
}
