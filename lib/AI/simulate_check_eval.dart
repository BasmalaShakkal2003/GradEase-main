import 'dart:math';

class ProjectEvaluator {
  static final Random _random = Random();
  
  /// Simulates project evaluation for a project description
  static Future<String> evaluateProject(String description) async {
    // Simulate API delay
    await Future.delayed(Duration(seconds: 2 + _random.nextInt(4)));
    
    // Calculate evaluation scores (for simulation)
    int overallScore = _random.nextInt(40) + 60; // 60-100%
    int innovationScore = _random.nextInt(30) + 70;
    int feasibilityScore = _random.nextInt(25) + 75;
    int clarityScore = _random.nextInt(35) + 65;
    int technicalScore = _random.nextInt(30) + 70;
    
    String grade;
    String feedback;
    List<String> strengths = [];
    List<String> improvements = [];
    
    if (overallScore >= 90) {
      grade = "A+ (Excellent)";
      feedback = "🌟 **Outstanding Project!** Your proposal demonstrates exceptional quality and innovation.";
      strengths = [
        "Excellent technical approach and methodology",
        "Clear and well-structured project description",
        "Strong innovation and originality",
        "Realistic timeline and deliverables"
      ];
      improvements = [
        "Consider adding more specific technical details",
        "Include potential risk mitigation strategies"
      ];
    } else if (overallScore >= 80) {
      grade = "A (Very Good)";
      feedback = "✨ **Great Work!** Your project shows strong potential with solid planning.";
      strengths = [
        "Good technical foundation",
        "Clear project objectives",
        "Well-defined scope and methodology",
        "Appropriate technology stack"
      ];
      improvements = [
        "Enhance innovation aspects",
        "Provide more detailed implementation plan",
        "Consider adding more advanced features"
      ];
    } else if (overallScore >= 70) {
      grade = "B+ (Good)";
      feedback = "👍 **Good Project** - Solid foundation with room for enhancement.";
      strengths = [
        "Adequate technical approach",
        "Reasonable project scope",
        "Basic methodology outlined"
      ];
      improvements = [
        "Strengthen technical innovation",
        "Improve clarity of objectives",
        "Add more detailed timeline",
        "Consider advanced technologies"
      ];
    } else {
      grade = "B (Satisfactory)";
      feedback = "⚠️ **Needs Improvement** - Basic concept present but requires significant enhancement.";
      strengths = [
        "Basic project idea identified",
        "Some technical components mentioned"
      ];
      improvements = [
        "Significantly improve technical depth",
        "Clarify project objectives and scope",
        "Develop comprehensive methodology",
        "Add innovation and uniqueness",
        "Improve overall presentation"
      ];
    }
    
    String evaluationReport = """
🎓 **Project Evaluation Report**

**Overall Grade: $grade**
**Overall Score: $overallScore/100**

$feedback

**Detailed Scores:**
• Innovation & Originality: $innovationScore/100
• Technical Feasibility: $feasibilityScore/100
• Clarity & Organization: $clarityScore/100
• Technical Depth: $technicalScore/100

**Strengths:**
${strengths.map((s) => "✅ $s").join('\n')}

**Areas for Improvement:**
${improvements.map((i) => "📝 $i").join('\n')}

**Recommendations:**
1. Review and address the improvement areas
2. Enhance technical specifications
3. Consider supervisor feedback for refinement
4. Prepare detailed implementation timeline
5. Document potential challenges and solutions

**Next Steps:**
• Schedule a meeting with your supervisor
• Revise the proposal based on feedback
• Begin preliminary research and planning
• Prepare detailed project plan

*This evaluation helps guide your project development for academic success.*
""";
    
    return evaluationReport;
  }
}
