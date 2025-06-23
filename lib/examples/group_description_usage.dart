/// Example usage of group description retrieval functions
/// This file demonstrates how to use the PlagiarismChecker functions
/// to retrieve and work with group descriptions from Firestore

import '../AI/check_palagrism.dart';

class GroupDescriptionUsageExample {
  
  /// Example 1: Basic retrieval of all group descriptions
  static Future<void> basicRetrievalExample() async {
    print("📚 Example 1: Basic Group Description Retrieval");
    print("=" * 50);
    
    // Get all group descriptions
    List<Map<String, dynamic>> allGroups = await PlagiarismChecker.getAllGroupDescriptions();
    
    print("Found ${allGroups.length} groups in the database:");
    
    for (var group in allGroups) {
      print("\n📋 ${group['groupName']}");
      print("   📝 Description: ${group['description']}");
      print("   👨‍🎓 Leader: ${group['leaderName']}");
      print("   👥 Members: ${group['member_count']}");
      print("   🆔 ID: ${group['groupId']}");
    }
  }
  
  /// Example 2: Exclude current group when comparing
  static Future<void> excludeCurrentGroupExample(String currentGroupId) async {
    print("\n\n📚 Example 2: Getting Other Groups (Excluding Current)");
    print("=" * 60);
    
    // Get all groups except the current one
    List<Map<String, dynamic>> otherGroups = await PlagiarismChecker.getOtherGroupDescriptions(currentGroupId);
    
    print("Groups available for comparison (excluding current group): ${otherGroups.length}");
    
    for (var group in otherGroups) {
      print("• ${group['groupName']} (${group['groupId']})");
    }
  }
  
  /// Example 3: Check plagiarism against all groups
  static Future<void> plagiarismCheckExample() async {
    print("\n\n📚 Example 3: Plagiarism Checking");
    print("=" * 40);
    
    String testDescription = """
    Our project focuses on developing a mobile application for student management 
    using Flutter and Firebase. The app will include features for attendance tracking, 
    grade management, and communication between students and teachers. We aim to 
    create an intuitive user interface that simplifies academic processes.
    """;
    
    print("Testing description: ${testDescription.substring(0, 100)}...");
    
    // Method 1: Simple plagiarism check
    String result1 = await PlagiarismChecker.checkPlagiarism(testDescription);
    print("\n--- Simple Check Result ---");
    print(result1);
    
    // Method 2: Real plagiarism check with custom threshold
    String result2 = await PlagiarismChecker.checkRealPlagiarism(
      testDescription,
      threshold: 0.25 // 25% similarity threshold
    );
    print("\n--- Real Check Result ---");
    print(result2);
  }
  
  /// Example 4: Find similar groups
  static Future<void> findSimilarGroupsExample() async {
    print("\n\n📚 Example 4: Finding Similar Groups");
    print("=" * 45);
    
    String testDescription = "Mobile application development using Flutter framework for educational purposes";
    
    List<Map<String, dynamic>> similarGroups = await PlagiarismChecker.findActualMatches(
      testDescription,
      null, // Don't exclude any group
      threshold: 0.1 // Low threshold to find any similarities
    );
    
    print("Found ${similarGroups.length} groups with similar content:");
    
    for (var group in similarGroups) {
      print("\n🔍 ${group['groupName']}");
      print("   Similarity: ${group['similarityPercentage']}%");
      print("   Description: ${group['description'].toString().substring(0, 
        group['description'].toString().length > 100 ? 100 : group['description'].toString().length)}...");
    }
  }
  
  /// Example 5: Search groups by keyword
  static Future<void> searchByKeywordExample() async {
    print("\n\n📚 Example 5: Search Groups by Keyword");
    print("=" * 45);
    
    List<String> keywords = ["mobile", "Flutter", "web", "AI", "blockchain"];
    
    for (String keyword in keywords) {
      List<Map<String, dynamic>> matchingGroups = await PlagiarismChecker.searchGroupsByKeyword(keyword);
      print("\n🔍 Keyword: '$keyword' - Found ${matchingGroups.length} groups");
      
      for (var group in matchingGroups.take(3)) { // Show only first 3 results
        print("   • ${group['groupName']}");
      }
    }
  }
  
  /// Example 6: Get database statistics
  static Future<void> databaseStatsExample() async {
    print("\n\n📚 Example 6: Database Statistics");
    print("=" * 35);
    
    int totalGroups = await PlagiarismChecker.getGroupCount();
    List<Map<String, dynamic>> allGroups = await PlagiarismChecker.getAllGroupDescriptions();
    
    print("📊 Database Statistics:");
    print("   Total Groups: $totalGroups");
    
    if (allGroups.isNotEmpty) {
      // Calculate average description length
      int totalLength = allGroups.fold(0, (sum, group) => sum + group['description'].toString().length);
      double avgLength = totalLength / allGroups.length;
      
      print("   Average Description Length: ${avgLength.toStringAsFixed(1)} characters");
      
      // Find groups with most and least members
      var maxMembers = allGroups.reduce((a, b) => 
        (a['member_count'] ?? 0) > (b['member_count'] ?? 0) ? a : b);
      var minMembers = allGroups.reduce((a, b) => 
        (a['member_count'] ?? 0) < (b['member_count'] ?? 0) ? a : b);
      
      print("   Largest Group: ${maxMembers['groupName']} (${maxMembers['member_count']} members)");
      print("   Smallest Group: ${minMembers['groupName']} (${minMembers['member_count']} members)");
    }
  }
  
  /// Run all examples
  static Future<void> runAllExamples() async {
    print("🚀 Running All Group Description Usage Examples");
    print("=" * 60);
    
    try {
      await basicRetrievalExample();
      
      // For the exclusion example, we'll use the first group's ID if available
      List<Map<String, dynamic>> allGroups = await PlagiarismChecker.getAllGroupDescriptions();
      if (allGroups.isNotEmpty) {
        await excludeCurrentGroupExample(allGroups.first['groupId']);
      }
      
      await plagiarismCheckExample();
      await findSimilarGroupsExample();
      await searchByKeywordExample();
      await databaseStatsExample();
      
      print("\n\n✅ All examples completed successfully!");
      
    } catch (e) {
      print("❌ Error running examples: $e");
    }
  }
}

/// Quick usage guide in comments:
/// 
/// // 1. Get all group descriptions:
/// List<Map<String, dynamic>> allGroups = await PlagiarismChecker.getAllGroupDescriptions();
/// 
/// // 2. Get groups excluding current one:
/// List<Map<String, dynamic>> otherGroups = await PlagiarismChecker.getOtherGroupDescriptions("currentGroupId");
/// 
/// // 3. Check plagiarism:
/// String result = await PlagiarismChecker.checkPlagiarism("description to check");
/// 
/// // 4. Real plagiarism check with options:
/// String realResult = await PlagiarismChecker.checkRealPlagiarism(
///   "description",
///   currentGroupId: "optional_current_group_id",
///   threshold: 0.3 // 30% similarity threshold
/// );
/// 
/// // 5. Find similar groups:
/// List<Map<String, dynamic>> similar = await PlagiarismChecker.findActualMatches(
///   "description to compare",
///   "optional_exclude_group_id",
///   threshold: 0.25
/// );
/// 
/// // 6. Search by keyword:
/// List<Map<String, dynamic>> results = await PlagiarismChecker.searchGroupsByKeyword("Flutter");
/// 
/// // 7. Get group count:
/// int count = await PlagiarismChecker.getGroupCount();
