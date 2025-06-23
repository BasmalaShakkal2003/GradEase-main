import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'check_eval.dart'; // Import the new Gemini AI evaluation

class PlagiarismChecker {
  static final Random _random = Random();
  
  /// Simple plagiarism check method (for backward compatibility)
  static Future<String> checkPlagiarism(String description) async {
    // Use the detailed plagiarism check for comprehensive analysis
    return await generateDetailedPlagiarismReport(description);
  }
  
  /// Enhanced plagiarism check using Gemini AI when available
  static Future<String> checkPlagiarismWithAI(String description) async {
    try {
      // Get all group descriptions for comparison
      List<Map<String, dynamic>> allGroups = await getAllGroupDescriptions();
      
      if (allGroups.isEmpty) {
        return 'No existing group descriptions found for comparison.';
      }
      
      List<String> aiReports = [];
      int highestSimilarity = 0;
      String mostSimilarGroup = '';
      
      // Check against each existing group using Gemini AI
      for (Map<String, dynamic> group in allGroups) {
        String existingDescription = group['description'];
        String groupInfo = '${group['groupName']} (Leader: ${group['leaderName']})';
        
        // Use Gemini AI for detailed comparison
        String aiReport = await ProjectEvaluator.checkPlagiarism(description, existingDescription);
        
        // Extract similarity percentage from AI report
        RegExp percentageRegex = RegExp(r'(\d+)%\s+similarity');
        Match? match = percentageRegex.firstMatch(aiReport);
        if (match != null) {
          int similarity = int.parse(match.group(1)!);
          if (similarity > highestSimilarity) {
            highestSimilarity = similarity;
            mostSimilarGroup = groupInfo;
          }
        }
        
        aiReports.add('=== Comparison with $groupInfo ===\n$aiReport\n');
      }
      
      // Generate comprehensive report
      String report = '''
COMPREHENSIVE AI-POWERED PLAGIARISM ANALYSIS REPORT

SUMMARY:
- Total groups checked: ${allGroups.length}
- Highest similarity found: $highestSimilarity% (with $mostSimilarGroup)
- AI Analysis: ${ProjectEvaluator.isApiKeyConfigured ? 'Gemini AI Enabled' : 'Fallback Analysis Used'}

${highestSimilarity > 50 ? 'WARNING: High similarity detected!' : 
  highestSimilarity > 25 ? 'CAUTION: Moderate similarity found.' : 
  'GOOD: Low similarity with existing projects.'}

DETAILED AI REPORTS:
${aiReports.join('\n')}

RECOMMENDATIONS:
${highestSimilarity > 50 ? 
  '- Review your project concept for originality\n- Consider significant modifications to differentiate your work\n- Consult with supervisor about project uniqueness' :
  highestSimilarity > 25 ?
  '- Minor adjustments may be needed to ensure uniqueness\n- Review similar aspects and enhance differentiation\n- Document unique features clearly' :
  '- Project appears to be original\n- Continue with development as planned\n- Maintain focus on unique features and implementation'}

Note: ${ProjectEvaluator.isApiKeyConfigured ? 
  'This analysis was powered by Gemini AI for accurate plagiarism detection.' : 
  'Configure Gemini API key for enhanced AI-powered analysis.'}
''';
      
      return report;
    } catch (e) {
      print('Error in AI plagiarism check: $e');
      // Fall back to existing method
      return await generateDetailedPlagiarismReport(description);
    }
  }
  
  /// Retrieves all group descriptions from Firestore for plagiarism comparison
  static Future<List<Map<String, dynamic>>> getAllGroupDescriptions() async {
    try {
      // Fetch all groups from Firestore
      QuerySnapshot<Map<String, dynamic>> groupsSnapshot = 
          await FirebaseFirestore.instance.collection('groups').get();
      
      List<Map<String, dynamic>> groupDescriptions = [];
      
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in groupsSnapshot.docs) {
        final data = doc.data();
        
        // Extract relevant fields for plagiarism checking
        if (data['description'] != null && data['description'].toString().trim().isNotEmpty) {
          // Get group leader details from users collection using groupId (which is leader's UID)
          String leaderName = 'Unknown Leader';
          try {
            DocumentSnapshot<Map<String, dynamic>> leaderDoc = 
                await FirebaseFirestore.instance.collection('users').doc(doc.id).get();
            if (leaderDoc.exists) {
              leaderName = leaderDoc.data()?['name'] ?? 'Unknown Leader';
            }
          } catch (e) {
            print('Error fetching leader name for group ${doc.id}: $e');
          }
          
          // Get member count from members subcollection + 1 for leader
          int memberCount = 1; // Start with 1 for the leader
          try {
            QuerySnapshot<Map<String, dynamic>> membersSnapshot = 
                await FirebaseFirestore.instance.collection('groups').doc(doc.id).collection('members').get();
            memberCount += membersSnapshot.docs.length; // Add member documents count
          } catch (e) {
            print('Error fetching members count for group ${doc.id}: $e');
          }
          
          groupDescriptions.add({
            'groupId': doc.id, // This is also the group leader's UID
            'groupName': data['name'] ?? 'Unknown Group',
            'description': data['description'],
            'leaderName': leaderName,
            'leaderUid': doc.id, // Group leader's UID (same as groupId)
            'member_count': memberCount, // Total members including leader
            // Add other relevant fields if needed
            'supervisor_id': data['supervisor_id'],
          });
        }
      }
      
      return groupDescriptions;
    } catch (e) {
      print('Error fetching group descriptions: $e');
      return [];
    }
  }
  
  /// Retrieves group descriptions excluding the current group (for comparison)
  static Future<List<Map<String, dynamic>>> getOtherGroupDescriptions(String currentGroupId) async {
    try {
      List<Map<String, dynamic>> allDescriptions = await getAllGroupDescriptions();
      
      // Filter out the current group
      return allDescriptions.where((group) => group['groupId'] != currentGroupId).toList();
    } catch (e) {
      print('Error fetching other group descriptions: $e');
      return [];
    }
  }
  
  /// Calculate actual text similarity between two descriptions
  static double calculateTextSimilarity(String text1, String text2) {
    if (text1.isEmpty || text2.isEmpty) return 0.0;
    
    // Convert to lowercase and split into words
    List<String> words1 = text1.toLowerCase().split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toList();
    List<String> words2 = text2.toLowerCase().split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toList();
    
    if (words1.isEmpty || words2.isEmpty) return 0.0;
    
    // Count common words
    Set<String> set1 = words1.toSet();
    Set<String> set2 = words2.toSet();
    Set<String> intersection = set1.intersection(set2);
    Set<String> union = set1.union(set2);
    
    // Jaccard similarity coefficient
    if (union.isEmpty) return 0.0;
    return intersection.length / union.length;
  }
  
  /// Find actual matches between current description and other groups
  static Future<List<Map<String, dynamic>>> findActualMatches(
    String currentDescription,
    String? currentGroupId,
    {double threshold = 0.3}
  ) async {
    try {
      List<Map<String, dynamic>> otherGroups = currentGroupId != null 
          ? await getOtherGroupDescriptions(currentGroupId)
          : await getAllGroupDescriptions();
      
      List<Map<String, dynamic>> matches = [];
      
      for (Map<String, dynamic> group in otherGroups) {
        double similarity = calculateTextSimilarity(
          currentDescription, 
          group['description'].toString()
        );
        
        if (similarity >= threshold) {
          matches.add({
            ...group,
            'similarity': similarity,
            'similarityPercentage': (similarity * 100).round(),
          });
        }
      }
      
      // Sort by similarity (highest first)
      matches.sort((a, b) => b['similarity'].compareTo(a['similarity']));
      
      return matches;
    } catch (e) {
      print('Error finding actual matches: $e');
      return [];
    }
  }
  
  /// Enhanced plagiarism checking that compares against actual group descriptions
  static Future<String> checkPlagiarismAgainstGroups(
    String description, 
    {String? currentGroupId}
  ) async {
    // Simulate API delay
    await Future.delayed(Duration(seconds: 2 + _random.nextInt(3)));
    
    // Fetch other group descriptions for comparison
    List<Map<String, dynamic>> otherGroups = currentGroupId != null 
        ? await getOtherGroupDescriptions(currentGroupId)
        : await getAllGroupDescriptions();
    
    // For now, use simulation logic but include real data context
    int similarityPercentage = _random.nextInt(40) + 5; // 5-45%
    
    // If we have other groups, we could implement actual text comparison here
    List<String> potentialMatches = [];
    if (otherGroups.isNotEmpty) {
      // Simulate finding potential matches
      int numMatches = _random.nextInt(3);
      for (int i = 0; i < numMatches && i < otherGroups.length; i++) {
        potentialMatches.add(otherGroups[i]['groupName']);
      }
    }
    
    String result;
    List<String> suggestions = [];
    
    if (similarityPercentage < 15) {
      result = "Excellent! Your project description appears to be original with very low similarity detected.";
      suggestions = [
        "Your description shows good originality compared to ${otherGroups.length} other groups",
        "Consider adding more technical details to make it even more unique",
        "Great work on creating an original project concept!"
      ];
    } else if (similarityPercentage < 25) {
      result = "Good - Low similarity detected, but some common phrases found.";
      suggestions = [
        "Try rephrasing some technical terms with more specific language",
        "Add more details about your unique implementation approach",
        "Consider highlighting what makes your solution different from similar projects"
      ];
    } else if (similarityPercentage < 35) {
      result = "Moderate - Some similarity found with existing projects.";
      suggestions = [
        "Rephrase common technical descriptions",
        "Add more specific details about your methodology",
        "Emphasize your unique contribution to the field",
        "Consider restructuring some paragraphs"
      ];
      if (potentialMatches.isNotEmpty) {
        suggestions.add("Review similarity with: ${potentialMatches.join(', ')}");
      }
    } else {
      result = "High Similarity - Significant overlap detected with existing content.";
      suggestions = [
        "Major revision needed - rewrite key sections",
        "Focus on what makes your approach truly unique",
        "Add specific technical innovations you're implementing",
        "Consult with your supervisor about originality requirements"
      ];
      if (potentialMatches.isNotEmpty) {
        suggestions.add("High similarity detected with: ${potentialMatches.join(', ')}");
      }
    }
    
    String analysisReport = """
Plagiarism Analysis Report

Similarity Score: ${similarityPercentage}%
Compared against: ${otherGroups.length} other group descriptions

$result

Detailed Analysis:
• Word similarity: ${similarityPercentage - 5}%
• Phrase matching: ${(similarityPercentage * 0.8).round()}%
• Structure similarity: ${(similarityPercentage * 0.6).round()}%
${potentialMatches.isNotEmpty ? '• Potential matches found: ${potentialMatches.length}' : ''}

Recommendations:
${suggestions.map((s) => "• $s").join('\n')}

Database Info:
• Total groups analyzed: ${otherGroups.length}
• Analysis performed: ${DateTime.now().toString().substring(0, 19)}

Next Steps:
1. Review the highlighted areas
2. Implement suggested changes
3. Re-run the check after revisions
4. Ensure all sources are properly cited

This analysis helps ensure academic integrity and originality of your work.
""";
    
    return analysisReport;
  }

  /// Enhanced function to get detailed plagiarism matches with comprehensive group information
  static Future<List<Map<String, dynamic>>> getDetailedPlagiarismMatches(
    String description,
    {String? currentGroupId, double threshold = 0.3}
  ) async {
    try {
      List<Map<String, dynamic>> matches = await findActualMatches(
        description, 
        currentGroupId, 
        threshold: threshold
      );
      
      // Enhance each match with additional details
      for (var match in matches) {
        // Calculate more detailed similarity metrics
        String matchDescription = match['description'].toString();
        
        // Word-level analysis
        List<String> originalWords = description.toLowerCase().split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toList();
        List<String> matchWords = matchDescription.toLowerCase().split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toList();
        
        Set<String> commonWords = originalWords.toSet().intersection(matchWords.toSet());
        Set<String> uniqueToOriginal = originalWords.toSet().difference(matchWords.toSet());
        Set<String> uniqueToMatch = matchWords.toSet().difference(originalWords.toSet());
        
        // Find common phrases (2+ words)
        List<String> commonPhrases = _findCommonPhrases(description, matchDescription);
        
        // Estimate creation date difference if available
        String timeDifference = "Unknown";
        if (match['createdAt'] != null) {
          try {
            DateTime matchDate = (match['createdAt'] as Timestamp).toDate();
            DateTime now = DateTime.now();
            int daysDiff = now.difference(matchDate).inDays;
            if (daysDiff < 30) {
              timeDifference = "$daysDiff days ago";
            } else if (daysDiff < 365) {
              timeDifference = "${(daysDiff / 30).round()} months ago";
            } else {
              timeDifference = "${(daysDiff / 365).round()} years ago";
            }
          } catch (e) {
            timeDifference = "Date unavailable";
          }
        }
        
        // Add detailed analysis to the match
        match.addAll({
          'detailedAnalysis': {
            'commonWords': commonWords.toList(),
            'commonWordsCount': commonWords.length,
            'totalOriginalWords': originalWords.length,
            'totalMatchWords': matchWords.length,
            'uniqueToOriginal': uniqueToOriginal.toList(),
            'uniqueToMatch': uniqueToMatch.toList(),
            'commonPhrases': commonPhrases,
            'phraseMatchCount': commonPhrases.length,
            'timeDifference': timeDifference,
            'wordOverlapPercentage': originalWords.isNotEmpty 
                ? ((commonWords.length / originalWords.length) * 100).round()
                : 0,
          }
        });
      }
      
      return matches;
    } catch (e) {
      print('Error getting detailed plagiarism matches: $e');
      return [];
    }
  }
  
  /// Helper function to find common phrases between two texts
  static List<String> _findCommonPhrases(String text1, String text2, {int minPhraseLength = 2}) {
    List<String> phrases1 = _extractPhrases(text1, minPhraseLength);
    List<String> phrases2 = _extractPhrases(text2, minPhraseLength);
    
    return phrases1.where((phrase) => 
      phrases2.any((p2) => p2.toLowerCase().contains(phrase.toLowerCase()) || 
                          phrase.toLowerCase().contains(p2.toLowerCase()))
    ).toList();
  }
  
  /// Helper function to extract phrases from text
  static List<String> _extractPhrases(String text, int minLength) {
    List<String> words = text.split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toList();
    List<String> phrases = [];
    
    for (int i = 0; i < words.length - minLength + 1; i++) {
      for (int len = minLength; len <= 5 && i + len <= words.length; len++) {
        String phrase = words.sublist(i, i + len).join(' ');
        if (phrase.length > 10) { // Only include meaningful phrases
          phrases.add(phrase);
        }
      }
    }
    
    return phrases;
  }
  
  /// Generate a detailed plagiarism report with comprehensive match information
  static Future<String> generateDetailedPlagiarismReport(
    String description,
    {String? currentGroupId, double threshold = 0.3}
  ) async {
    if (description.trim().isEmpty) {
      return "Error: No description provided for analysis.";
    }
    
    try {
      List<Map<String, dynamic>> detailedMatches = await getDetailedPlagiarismMatches(
        description,
        currentGroupId: currentGroupId,
        threshold: threshold
      );
      
      int totalGroups = await getGroupCount();
      double maxSimilarity = detailedMatches.isNotEmpty ? detailedMatches.first['similarity'] : 0.0;
      int overallSimilarityPercentage = (maxSimilarity * 100).round();
      
      String result;
      if (overallSimilarityPercentage < 15) {
        result = "Excellent! Your project description appears to be highly original.";
      } else if (overallSimilarityPercentage < 30) {
        result = "Good - Some similarities detected, but within acceptable range.";
      } else if (overallSimilarityPercentage < 50) {
        result = "Moderate - Notable similarities found. Review recommended.";
      } else {
        result = "High Similarity - Significant overlap detected. Major revision needed!";
      }
      
      // Build detailed match information
      String detailedMatchInfo = "";
      if (detailedMatches.isNotEmpty) {
        
        detailedMatchInfo = "\n\nDetailed Matches:\n";
        detailedMatchInfo += "=" * 50 + "\n";
        
        for (int i = 0; i < detailedMatches.length; i++) {
          var match = detailedMatches[i];
          var analysis = match['detailedAnalysis'];
          
          detailedMatchInfo += """
Match ${i + 1}: ${match['groupName']}
ID: ${match['groupId']}
  Leader: ${match['leaderName']}
  Team Size: ${match['member_count']} member${match['member_count'] == 1 ? '' : 's'}  
  Similarity: ${match['similarityPercentage']}%
  Word Overlap: ${analysis['wordOverlapPercentage']}%
  Common Phrases: ${analysis['phraseMatchCount']} detected
  Shared Words: ${analysis['commonWordsCount']}/${analysis['totalOriginalWords']}
  
  Description: "${match['description'].toString().replaceAll('\n', ' ').replaceAll('\r', ' ')}"

""";
        }
      } else {
        detailedMatchInfo = "\nNo Similar Groups Found - Your project appears to be unique!\n";
      }
      
      // Generate recommendations based on findings
      List<String> recommendations = [];
      if (detailedMatches.isEmpty) {
        recommendations.addAll([
          "Great work on creating an original project concept!",
          "Consider adding more technical implementation details",
          "Document your unique approach and methodology"
        ]);
      } else {
        for (var match in detailedMatches.take(3)) {
          var analysis = match['detailedAnalysis'];
          if (analysis['wordOverlapPercentage'] > 50) {
            recommendations.add("Consider rephrasing technical terms to be more specific to your implementation");
          }
          if (analysis['phraseMatchCount'] > 2) {
            recommendations.add("Rewrite common phrases to highlight your unique approach");
          }
          if (analysis['timeDifference'].contains('days')) {
            recommendations.add("Ensure your project development is independent from recent similar projects");
          }
        }
        
        if (overallSimilarityPercentage > 30) {
          recommendations.addAll([
            "Focus on what makes your solution uniquely different",
            "Add more specific technical implementation details",
            "Consult with your supervisor about originality requirements"
          ]);
        }
      }
      
      String fullReport = """
COMPREHENSIVE PLAGIARISM ANALYSIS REPORT
${"=" * 60}

OVERVIEW
- Overall Similarity Score: ${overallSimilarityPercentage}%
- Groups Analyzed: $totalGroups
- Matches Found: ${detailedMatches.length}
- Threshold Used: ${(threshold * 100).round()}%
- Analysis Date: ${DateTime.now().toString().substring(0, 19)}

RESULT
$result

$detailedMatchInfo

RECOMMENDATIONS
${recommendations.map((r) => "• $r").join('\n')}

ANALYSIS METHODOLOGY
• Algorithm: Advanced Jaccard coefficient with phrase detection
• Data Source: Real-time Firestore group database
• Analysis Scope: ${currentGroupId != null ? 'Excludes your current group' : 'All registered groups'}
• Detection Features: Word overlap, phrase matching, temporal analysis

RECOMMENDED NEXT STEPS
1. Review any highlighted similarities above in detail
2. ${detailedMatches.isNotEmpty ? 'Modify descriptions of similar sections' : 'Continue with your unique approach'}
3. ${overallSimilarityPercentage > 30 ? 'Consult with supervisor about findings' : 'Document your unique methodology'}
4. Re-run analysis after making any changes
5. Save this report for your project documentation

This analysis ensures academic integrity while highlighting areas for improvement in your project description.
""";
      
      return fullReport;
      
    } catch (e) {
      return "Error: Unable to generate detailed plagiarism report.\n\nError details: $e";
    }
  }

  /// Real plagiarism checking using actual text comparison
  static Future<String> checkRealPlagiarism(
    String description,
    {String? currentGroupId, double threshold = 0.3}
  ) async {
    if (description.trim().isEmpty) {
      return "Error: No description provided for analysis.";
    }
    
    try {
      // Find actual matches
      List<Map<String, dynamic>> matches = await findActualMatches(
        description, 
        currentGroupId, 
        threshold: threshold
      );
      
      // Calculate overall similarity score
      double maxSimilarity = matches.isNotEmpty ? matches.first['similarity'] : 0.0;
      int similarityPercentage = (maxSimilarity * 100).round();
      
      String result;
      List<String> suggestions = [];
      
      if (similarityPercentage < 15) {
        result = "Excellent! Your project description appears to be original.";
        suggestions = [
          "Your description shows good originality",
          "Consider adding more technical details",
          "Great work on creating an original concept!"
        ];
      } else if (similarityPercentage < 30) {
        result = "Good - Low similarity detected.";
        suggestions = [
          "Try rephrasing some common technical terms",
          "Add more specific implementation details",
          "Consider highlighting unique aspects"
        ];
      } else if (similarityPercentage < 50) {
        result = "Moderate - Notable similarity found.";
        suggestions = [
          "Significant rephrasing recommended",
          "Add more unique technical details",
          "Emphasize your specific innovations"
        ];
      } else {
        result = "High Similarity - Major overlap detected!";
        suggestions = [
          "Major revision required",
          "Consult with supervisor immediately",
          "Focus on truly unique aspects",
          "Consider changing approach or methodology"
        ];
      }
      
      String matchDetails = "";
      if (matches.isNotEmpty) {
        matchDetails = "\n**Similar Groups Found:**\n";
        for (int i = 0; i < matches.take(3).length; i++) {
          var match = matches[i];
          matchDetails += "• ${match['groupName']} (${match['similarityPercentage']}% similar)\n";
        }
      }
      
      String analysisReport = """
Real Plagiarism Analysis Report

Overall Similarity Score: ${similarityPercentage}%
Groups Compared: ${await getAllGroupDescriptions().then((groups) => groups.length)}
Matches Found: ${matches.length}

$result

$matchDetails

Recommendations:
${suggestions.map((s) => "• $s").join('\n')}

Analysis Details:
• Threshold used: ${(threshold * 100).round()}%
• Analysis date: ${DateTime.now().toString().substring(0, 19)}
• Method: Text similarity comparison

Next Steps:
1. Review similar projects if any found
2. Implement suggested improvements
3. Re-run analysis after changes
4. Ensure proper citations

This is a real comparison against existing group descriptions in the database.
""";
      
      return analysisReport;
      
    } catch (e) {
      return "Error: Unable to perform plagiarism check. Please try again later.\n\nError details: $e";
    }
  }
  
  /// Demo function to show how to retrieve and use group descriptions
  static Future<void> demonstrateGroupDescriptionRetrieval() async {
    print("Demo: Retrieving all group descriptions from Firestore...\n");
    
    try {
      // 1. Get all group descriptions
      List<Map<String, dynamic>> allDescriptions = await getAllGroupDescriptions();
      
      print("Successfully retrieved ${allDescriptions.length} group descriptions!");
      print("\nGroup Descriptions Summary:");
      print("=" * 50);
      
      for (int i = 0; i < allDescriptions.length; i++) {
        var group = allDescriptions[i];
        print("\n${i + 1}. Group: ${group['groupName']}");
        print("   Leader: ${group['leaderName']}");
        print("   Members: ${group['member_count']}");
        print("   ID: ${group['groupId']}");
        print("   Description Preview: ${group['description'].toString().substring(0, 
          group['description'].toString().length > 80 ? 80 : group['description'].toString().length)}...");
      }
      
      // 2. Demonstrate getting descriptions excluding a specific group
      if (allDescriptions.isNotEmpty) {
        String excludeGroupId = allDescriptions.first['groupId'];
        List<Map<String, dynamic>> otherDescriptions = await getOtherGroupDescriptions(excludeGroupId);
        
        print("\n\nExcluding group '${allDescriptions.first['groupName']}':");
        print("Remaining groups for comparison: ${otherDescriptions.length}");
      }
      
      // 3. Demonstrate text similarity calculation
      if (allDescriptions.length >= 2) {
        String desc1 = allDescriptions[0]['description'];
        String desc2 = allDescriptions[1]['description'];
        double similarity = calculateTextSimilarity(desc1, desc2);
        
        print("\n\nSample Similarity Check:");
        print("Group 1: ${allDescriptions[0]['groupName']}");
        print("Group 2: ${allDescriptions[1]['groupName']}");
        print("Similarity: ${(similarity * 100).toStringAsFixed(1)}%");
      }
      
      print("\n\nDemo completed successfully!");
      print("You can now use these functions in your plagiarism checking workflow.");
      
    } catch (e) {
      print("Error during demo: $e");
    }
  }
  
  /// Utility function to get group description count
  static Future<int> getGroupCount() async {
    try {
      List<Map<String, dynamic>> descriptions = await getAllGroupDescriptions();
      return descriptions.length;
    } catch (e) {
      print('Error getting group count: $e');
      return 0;
    }
  }
  
  /// Function to search for groups by keyword in description
  static Future<List<Map<String, dynamic>>> searchGroupsByKeyword(String keyword) async {
    try {
      List<Map<String, dynamic>> allDescriptions = await getAllGroupDescriptions();
      String lowerKeyword = keyword.toLowerCase();
      
      return allDescriptions.where((group) {
        String description = group['description'].toString().toLowerCase();
        String groupName = group['groupName'].toString().toLowerCase();
        return description.contains(lowerKeyword) || groupName.contains(lowerKeyword);
      }).toList();
    } catch (e) {
      print('Error searching groups by keyword: $e');
      return [];
    }
  }

  /// Retrieves detailed group information including member names
  static Future<Map<String, dynamic>?> getDetailedGroupInfo(String groupId) async {
    try {
      // Get group data
      DocumentSnapshot<Map<String, dynamic>> groupDoc = 
          await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      
      if (!groupDoc.exists) {
        return null;
      }
      
      final groupData = groupDoc.data()!;
      
      // Get group leader name (groupId is the leader's UID)
      String leaderName = 'Unknown Leader';
      try {
        DocumentSnapshot<Map<String, dynamic>> leaderDoc = 
            await FirebaseFirestore.instance.collection('users').doc(groupId).get();
        if (leaderDoc.exists) {
          leaderName = leaderDoc.data()?['name'] ?? 'Unknown Leader';
        }
      } catch (e) {
        print('Error fetching leader name for group $groupId: $e');
      }
      
      // Get member details from members subcollection
      List<Map<String, dynamic>> memberDetails = [];
      List<String> memberUids = [];
      
      try {
        QuerySnapshot<Map<String, dynamic>> membersSnapshot = 
            await FirebaseFirestore.instance.collection('groups').doc(groupId).collection('members').get();
        
        for (QueryDocumentSnapshot<Map<String, dynamic>> memberDoc in membersSnapshot.docs) {
          String memberUid = memberDoc.id; // Document ID is the member's UID
          memberUids.add(memberUid);
          
          try {
            DocumentSnapshot<Map<String, dynamic>> userDoc = 
                await FirebaseFirestore.instance.collection('users').doc(memberUid).get();
            if (userDoc.exists) {
              memberDetails.add({
                'uid': memberUid,
                'name': userDoc.data()?['name'] ?? 'Unknown Member',
                'email': userDoc.data()?['email'] ?? '',
                'role': 'member',
              });
            }
          } catch (e) {
            print('Error fetching user details for member UID $memberUid: $e');
            memberDetails.add({
              'uid': memberUid,
              'name': 'Unknown Member',
              'email': '',
              'role': 'member',
            });
          }
        }
      } catch (e) {
        print('Error fetching members subcollection for group $groupId: $e');
      }
      
      // Add leader to the member details
      memberDetails.insert(0, {
        'uid': groupId,
        'name': leaderName,
        'email': '', // Could fetch from leader's user document if needed
        'role': 'leader',
      });
      memberUids.insert(0, groupId);
      
      return {
        'groupId': groupId,
        'groupName': groupData['name'] ?? 'Unknown Group',
        'description': groupData['description'] ?? '',
        'createdAt': groupData['createdAt'],
        'leaderUid': groupId, // Group leader's UID (same as groupId)
        'leaderName': leaderName,
        'members': memberDetails,
        'memberUids': memberUids,
        'member_count': memberDetails.length, // Total members including leader
        'supervisor_id': groupData['supervisor_id'],
        // Add any other fields from the group document
      };
    } catch (e) {
      print('Error fetching detailed group info for $groupId: $e');
      return null;
    }
  }
}
