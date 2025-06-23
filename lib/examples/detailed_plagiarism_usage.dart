/// Detailed Plagiarism Analysis Usage Examples
/// This file shows how to use the enhanced plagiarism checking functions
/// that provide comprehensive details about matching groups

import '../AI/check_palagrism.dart';

class DetailedPlagiarismUsageExample {
  
  /// Example 1: Get detailed plagiarism matches with comprehensive analysis
  static Future<void> detailedMatchesExample() async {
    print("📊 Example 1: Detailed Plagiarism Matches");
    print("=" * 50);
    
    String testDescription = """
    Our graduation project focuses on developing a comprehensive mobile application
    for student management using Flutter framework and Firebase backend. The application
    will include features for attendance tracking, grade management, assignment submission,
    and real-time communication between students and teachers. We aim to create an
    intuitive and user-friendly interface that simplifies academic processes.
    """;
    
    // Get detailed matches with comprehensive analysis
    List<Map<String, dynamic>> detailedMatches = await PlagiarismChecker.getDetailedPlagiarismMatches(
      testDescription,
      threshold: 0.2 // 20% similarity threshold
    );
    
    print("Found ${detailedMatches.length} detailed matches:");
    
    for (int i = 0; i < detailedMatches.length; i++) {
      var match = detailedMatches[i];
      var analysis = match['detailedAnalysis'];
      
      print("\n🎯 Match ${i + 1}: ${match['groupName']}");
      print("   📈 Overall Similarity: ${match['similarityPercentage']}%");
      print("   👨‍🎓 Leader: ${match['leaderName']}");
      print("   👥 Team Size: ${match['member_count']} members");
      print("   📅 Created: ${analysis['timeDifference']}");
      print("   🔤 Word Overlap: ${analysis['wordOverlapPercentage']}%");
      print("   📝 Common Phrases: ${analysis['phraseMatchCount']}");
      print("   💬 Common Words: ${analysis['commonWordsCount']}");
      
      if (analysis['commonWords'].isNotEmpty) {
        print("   🔍 Top Common Words: ${analysis['commonWords'].take(5).join(', ')}");
      }
      
      if (analysis['commonPhrases'].isNotEmpty) {
        print("   📋 Common Phrases: ${analysis['commonPhrases'].take(2).join(', ')}");
      }
    }
  }
  
  /// Example 2: Generate comprehensive plagiarism report
  static Future<void> comprehensiveReportExample() async {
    print("\n\n📄 Example 2: Comprehensive Plagiarism Report");
    print("=" * 60);
    
    String projectDescription = """
    We are developing an AI-powered mobile application using Flutter and machine learning
    algorithms for automated student performance analysis. The system will integrate with
    Firebase for real-time data synchronization and will include features like predictive
    analytics, personalized learning recommendations, and automated report generation.
    Our innovative approach combines natural language processing with educational data mining
    to provide insights for both students and educators.
    """;
    
    // Generate detailed report
    String detailedReport = await PlagiarismChecker.generateDetailedPlagiarismReport(
      projectDescription,
      threshold: 0.25 // 25% threshold
    );
    
    print(detailedReport);
  }
  
  /// Example 3: Compare specific project with exclusion
  static Future<void> excludeCurrentGroupExample() async {
    print("\n\n🔄 Example 3: Analysis Excluding Current Group");
    print("=" * 55);
    
    String currentGroupDescription = """
    Our project involves creating a blockchain-based voting system for secure
    and transparent elections. We use smart contracts, cryptographic hashing,
    and decentralized storage to ensure vote integrity and prevent tampering.
    """;
    
    // First, get all groups to simulate having a current group ID
    List<Map<String, dynamic>> allGroups = await PlagiarismChecker.getAllGroupDescriptions();
    
    if (allGroups.isNotEmpty) {
      String currentGroupId = allGroups.first['groupId'];
      print("Excluding current group: ${allGroups.first['groupName']}");
      
      String report = await PlagiarismChecker.generateDetailedPlagiarismReport(
        currentGroupDescription,
        currentGroupId: currentGroupId,
        threshold: 0.15
      );
      
      print(report);
    } else {
      print("No groups found in database for this example.");
    }
  }
  
  /// Example 4: Analyze word and phrase overlaps
  static Future<void> wordPhraseAnalysisExample() async {
    print("\n\n🔤 Example 4: Word & Phrase Analysis");
    print("=" * 45);
    
    String description1 = "Mobile application development using Flutter framework for educational management";
    String description2 = "Educational mobile app development with Flutter framework and student management features";
    
    // Calculate basic similarity
    double similarity = PlagiarismChecker.calculateTextSimilarity(description1, description2);
    print("Basic similarity: ${(similarity * 100).round()}%");
    
    // Get detailed analysis
    List<Map<String, dynamic>> matches = await PlagiarismChecker.getDetailedPlagiarismMatches(
      description1,
      threshold: 0.1 // Very low threshold to show analysis details
    );
    
    if (matches.isNotEmpty) {
      var analysis = matches.first['detailedAnalysis'];
      print("\nDetailed Analysis:");
      print("• Common words: ${analysis['commonWords']}");
      print("• Word overlap: ${analysis['wordOverlapPercentage']}%");
      print("• Common phrases: ${analysis['commonPhrases']}");
      print("• Unique to original: ${analysis['uniqueToOriginal'].take(5).toList()}");
    }
  }
  
  /// Example 5: Batch analysis for multiple descriptions
  static Future<void> batchAnalysisExample() async {
    print("\n\n📊 Example 5: Batch Analysis");
    print("=" * 35);
    
    List<String> testDescriptions = [
      "Web development project using React and Node.js for e-commerce platform",
      "Mobile app for fitness tracking using React Native and health APIs",
      "Machine learning project for image classification using TensorFlow",
      "IoT system for smart home automation using Arduino and sensors"
    ];
    
    print("Analyzing ${testDescriptions.length} project descriptions...\n");
    
    for (int i = 0; i < testDescriptions.length; i++) {
      print("📝 Project ${i + 1}: ${testDescriptions[i].substring(0, 50)}...");
      
      List<Map<String, dynamic>> matches = await PlagiarismChecker.getDetailedPlagiarismMatches(
        testDescriptions[i],
        threshold: 0.2
      );
      
      if (matches.isNotEmpty) {
        print("   ⚠️  ${matches.length} matches found - highest similarity: ${matches.first['similarityPercentage']}%");
        print("   📋 Similar to: ${matches.take(2).map((m) => m['groupName']).join(', ')}");
      } else {
        print("   ✅ No significant matches found - appears unique");
      }
      print("");
    }
  }
  
  /// Example 6: Threshold comparison analysis
  static Future<void> thresholdComparisonExample() async {
    print("\n\n🎯 Example 6: Threshold Comparison Analysis");
    print("=" * 50);
    
    String testDescription = """
    Our project creates a comprehensive student information system using modern
    web technologies including React frontend and Node.js backend with MongoDB
    database for efficient data management and user experience optimization.
    """;
    
    List<double> thresholds = [0.1, 0.2, 0.3, 0.4];
    
    print("Testing different similarity thresholds:\n");
    
    for (double threshold in thresholds) {
      List<Map<String, dynamic>> matches = await PlagiarismChecker.getDetailedPlagiarismMatches(
        testDescription,
        threshold: threshold
      );
      
      print("🎯 Threshold ${(threshold * 100).round()}%: ${matches.length} matches found");
      
      if (matches.isNotEmpty) {
        double avgSimilarity = matches.fold<double>(0.0, (sum, match) => sum + ((match['similarity'] as double?) ?? 0.0)) / matches.length;
        print("   📊 Average similarity: ${(avgSimilarity * 100).round()}%");
        print("   📋 Groups: ${matches.take(3).map((m) => m['groupName']).join(', ')}");
      }
      print("");
    }
  }
  
  /// Example 7: Real-time plagiarism monitoring simulation
  static Future<void> realTimeMonitoringExample() async {
    print("\n\n⚡ Example 7: Real-time Monitoring Simulation");
    print("=" * 55);
    
    String baseDescription = "Mobile application for student management";
    List<String> incrementalText = [
      " using Flutter framework",
      " with Firebase backend integration",
      " including attendance tracking features",
      " and real-time communication capabilities",
      " with advanced analytics and reporting tools"
    ];
    
    print("Simulating real-time plagiarism checking as user types:\n");
    
    String currentText = baseDescription;
    
    for (int i = 0; i < incrementalText.length; i++) {
      currentText += incrementalText[i];
      
      print("📝 Step ${i + 1}: ${currentText}");
      
      List<Map<String, dynamic>> matches = await PlagiarismChecker.getDetailedPlagiarismMatches(
        currentText,
        threshold: 0.25
      );
      
      if (matches.isNotEmpty) {
        double maxSimilarity = matches.first['similarity'];
        print("   ⚠️  Similarity detected: ${(maxSimilarity * 100).round()}% with ${matches.first['groupName']}");
      } else {
        print("   ✅ No significant similarity detected");
      }
      print("");
    }
  }
  
  /// Run all detailed examples
  static Future<void> runAllDetailedExamples() async {
    print("🚀 Running All Detailed Plagiarism Analysis Examples");
    print("=" * 65);
    
    try {
      await detailedMatchesExample();
      await comprehensiveReportExample();
      await excludeCurrentGroupExample();
      await wordPhraseAnalysisExample();
      await batchAnalysisExample();
      await thresholdComparisonExample();
      await realTimeMonitoringExample();
      
      print("\n✅ All detailed examples completed successfully!");
      
    } catch (e) {
      print("❌ Error running detailed examples: $e");
    }
  }
}

/// Quick reference for the new detailed functions:
/// 
/// // 1. Get detailed matches with comprehensive analysis:
/// List<Map<String, dynamic>> detailedMatches = await PlagiarismChecker.getDetailedPlagiarismMatches(
///   "description",
///   currentGroupId: "optional_group_id",
///   threshold: 0.3
/// );
/// 
/// // 2. Generate comprehensive plagiarism report:
/// String detailedReport = await PlagiarismChecker.generateDetailedPlagiarismReport(
///   "description",
///   currentGroupId: "optional_group_id", 
///   threshold: 0.25
/// );
/// 
/// // 3. Simple check (now uses detailed analysis):
/// String result = await PlagiarismChecker.checkPlagiarism("description");
/// 
/// // The detailed analysis includes:
/// // - Word overlap percentage
/// // - Common phrases detection
/// // - Time difference analysis
/// // - Group information (leader, size, creation date)
/// // - Specific recommendations based on findings
/// // - Breakdown of similarity components
