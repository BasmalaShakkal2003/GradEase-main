import '../AI/check_palagrism.dart';

/// Example demonstrating the enhanced plagiarism report format
void main() async {
  print("🚀 Enhanced Plagiarism Report Demo\n");
  
  // Sample project description
  String projectDescription = """
  Mobile learning application built with Flutter framework for university students.
  Features include course management, assignment tracking, and grade monitoring.
  Backend implementation uses Firebase for real-time data synchronization.
  User interface designed with Material Design principles for optimal user experience.
  Authentication system supports both email/password and social media login options.
  """;
  
  try {
    print("📝 Analyzing project description...\n");
    
    // Generate enhanced detailed report
    String detailedReport = await PlagiarismChecker.generateDetailedPlagiarismReport(
      projectDescription,
      threshold: 0.25  // Lower threshold to catch more potential matches
    );
    
    print(detailedReport);
    
    // Demonstrate similarity indicators
    print("\n\n🎨 Similarity Indicator Examples:");
    print("═" * 50);
    
    List<Map<String, dynamic>> examples = [
      {"percentage": 5, "description": "Excellent originality"},
      {"percentage": 20, "description": "Good with minor similarities"},
      {"percentage": 35, "description": "Moderate overlap detected"},
      {"percentage": 55, "description": "High similarity found"},
      {"percentage": 80, "description": "Critical - major revision needed"}
    ];
    
    for (var example in examples) {
      String indicator = PlagiarismChecker.getSimilarityIndicator(example['percentage']);
      print("${example['percentage']}% $indicator - ${example['description']}");
    }
    
    print("\n✅ Demo completed! The enhanced format provides:");
    print("• Clear group names alongside IDs");
    print("• Professional report formatting");
    print("• Visual similarity indicators");
    print("• Comprehensive analysis insights");
    print("• Better organized information hierarchy");
    
  } catch (e) {
    print("❌ Demo failed: $e");
    print("Make sure Firebase is properly configured for this demo.");
  }
}

/// Quick function to demonstrate group listing format
Future<void> demoGroupListing() async {
  print("\n📋 Enhanced Group Listing Demo:");
  print("═" * 60);
  
  try {
    List<Map<String, dynamic>> groups = await PlagiarismChecker.getAllGroupDescriptions();
    
    if (groups.isNotEmpty) {
      // Show first 3 groups with enhanced format
      for (int i = 0; i < groups.take(3).length; i++) {
        var group = groups[i];
        print("""
┌─ 📚 GROUP ${i + 1} ──────────────────────────────────
│ 🏷️  Name: "${group['name']}"
│ 🆔 ID: ${group['groupId']}
│ 👨‍🎓 Leader: ${group['leaderName']}
│ 👥 Team: ${group['member_count']} member${group['member_count'] == 1 ? '' : 's'}
│ 📅 Created: ${group.containsKey('createdAt') ? group['createdAt'].toString() : 'Date not available'}
│ 📝 Description Preview: 
│    ${group['description'].toString().length > 80 
         ? group['description'].toString().substring(0, 80) + '...' 
         : group['description']}
└────────────────────────────────────────────────""");
      }
      
      print("\n✨ Enhanced group display shows complete information at a glance!");
    } else {
      print("⚠️ No groups found in database.");
    }
    
  } catch (e) {
    print("❌ Group listing demo failed: $e");
  }
}
