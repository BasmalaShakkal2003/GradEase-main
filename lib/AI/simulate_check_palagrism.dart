import 'dart:math';

class PlagiarismChecker {
  static final Random _random = Random();
  
  /// Simulates plagiarism checking for a project description
  static Future<String> checkPlagiarism(String description) async {
    // Simulate API delay
    await Future.delayed(Duration(seconds: 2 + _random.nextInt(3)));
    
    // Calculate similarity percentage (for simulation)
    int similarityPercentage = _random.nextInt(40) + 5; // 5-45%
    
    String result;
    List<String> suggestions = [];
    
    if (similarityPercentage < 15) {
      result = "✅ **Excellent!** Your project description appears to be original with very low similarity detected.";
      suggestions = [
        "Your description shows good originality",
        "Consider adding more technical details to make it even more unique",
        "Great work on creating an original project concept!"
      ];
    } else if (similarityPercentage < 25) {
      result = "⚠️ **Good** - Low similarity detected, but some common phrases found.";
      suggestions = [
        "Try rephrasing some technical terms with more specific language",
        "Add more details about your unique implementation approach",
        "Consider highlighting what makes your solution different"
      ];
    } else if (similarityPercentage < 35) {
      result = "⚠️ **Moderate** - Some similarity found with existing projects.";
      suggestions = [
        "Rephrase common technical descriptions",
        "Add more specific details about your methodology",
        "Emphasize your unique contribution to the field",
        "Consider restructuring some paragraphs"
      ];
    } else {
      result = "🚨 **High Similarity** - Significant overlap detected with existing content.";
      suggestions = [
        "Major revision needed - rewrite key sections",
        "Focus on what makes your approach truly unique",
        "Add specific technical innovations you're implementing",
        "Consult with your supervisor about originality requirements"
      ];
    }
    
    String analysisReport = """
📊 **Plagiarism Analysis Report**

**Similarity Score: ${similarityPercentage}%**

$result

**Detailed Analysis:**
• Word similarity: ${similarityPercentage - 5}%
• Phrase matching: ${(similarityPercentage * 0.8).round()}%
• Structure similarity: ${(similarityPercentage * 0.6).round()}%

**Recommendations:**
${suggestions.map((s) => "• $s").join('\n')}

**Next Steps:**
1. Review the highlighted areas
2. Implement suggested changes
3. Re-run the check after revisions
4. Ensure all sources are properly cited

*This analysis helps ensure academic integrity and originality of your work.*
""";
    
    return analysisReport;
  }
}
