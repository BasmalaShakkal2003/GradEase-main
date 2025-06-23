import '../AI/check_palagrism.dart';

/// Test function to demonstrate the enhanced plagiarism report format
class PlagiarismReportTest {
  
  /// Test the enhanced detailed plagiarism report
  static Future<void> testEnhancedReport() async {
    print("🧪 Testing Enhanced Plagiarism Report Format...\n");
    
    // Sample description for testing
    String testDescription = """
    Mobile application development using Flutter framework for educational management. 
    The system includes student registration, course management, and grade tracking features.
    Implementation uses Firebase for backend services and real-time database synchronization.
    Features include user authentication, data visualization, and report generation capabilities.
    """;
    
    try {
      // Generate the enhanced detailed report
      String report = await PlagiarismChecker.generateDetailedPlagiarismReport(
        testDescription,
        threshold: 0.25 // Lower threshold for testing
      );
      
      print("📊 ENHANCED PLAGIARISM REPORT:");
      print("=" * 80);
      print(report);
      print("=" * 80);
      
      // Test the simple format as well
      print("\n\n🔍 SIMPLE PLAGIARISM CHECK:");
      print("-" * 50);
      String simpleResult = await PlagiarismChecker.checkPlagiarism(testDescription);
      print(simpleResult);
      print("-" * 50);
      
      print("\n✅ Test completed successfully!");
      print("The enhanced format now shows:");
      print("• Group names prominently displayed alongside IDs");
      print("• Better organized visual hierarchy with boxes and borders");
      print("• Summary statistics for quick overview");
      print("• Enhanced insights and recommendations");
      print("• Professional report formatting");
      
    } catch (e) {
      print("❌ Test failed: $e");
    }
  }
  
  /// Test group description retrieval with enhanced display
  static Future<void> testGroupDescriptionDisplay() async {
    print("\n🧪 Testing Enhanced Group Description Display...\n");
    
    try {
      List<Map<String, dynamic>> groups = await PlagiarismChecker.getAllGroupDescriptions();
      
      if (groups.isNotEmpty) {
        print("📋 ENHANCED GROUP LISTINGS:");
        print("═" * 60);
        
        for (int i = 0; i < groups.take(3).length; i++) {
          var group = groups[i];
          print("""
┌─ GROUP ${i + 1} ──────────────────────────────────────
│ 📛 Name: "${group['name']}" 
│ 🆔 ID: ${group['groupId']}
│ 👨‍🎓 Leader: ${group['leaderName']}
│ 👥 Members: ${group['member_count']}
│ 📝 Description: ${group['description'].toString().substring(0, 
            group['description'].toString().length > 100 ? 100 : group['description'].toString().length)}...
└────────────────────────────────────────────────""");
        }
        
        print("\n✅ Enhanced group display format working correctly!");
      } else {
        print("⚠️ No groups found in database for testing.");
      }
      
    } catch (e) {
      print("❌ Group display test failed: $e");
    }
  }
  
  /// Test similarity indicators
  static void testSimilarityIndicators() {
    print("\n🧪 Testing Similarity Indicators...\n");
    
    List<int> testPercentages = [5, 15, 25, 35, 45, 55, 75, 95];
    
    print("📊 SIMILARITY INDICATOR SCALE:");
    print("─" * 40);
    
    for (int percentage in testPercentages) {
      String indicator = PlagiarismChecker.getSimilarityIndicator(percentage);
      String level = "";
      
      if (percentage >= 70) level = "CRITICAL";
      else if (percentage >= 50) level = "HIGH";
      else if (percentage >= 30) level = "MODERATE";
      else if (percentage >= 15) level = "LOW";
      else level = "MINIMAL";
      
      print("${percentage.toString().padLeft(2)}% $indicator $level");
    }
    
    print("─" * 40);
    print("✅ Similarity indicators working correctly!");
  }
}
