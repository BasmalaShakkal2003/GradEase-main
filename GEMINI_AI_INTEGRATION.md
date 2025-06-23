# Gemini AI Integration Guide for GradEase

## Overview

The GradEase project now features **real Gemini AI integration** for intelligent project evaluation and plagiarism detection. This replaces the previous simulation system with actual AI-powered analysis using Google's Gemini 2.0 Flash model.

## Features

### 1. **AI-Powered Project Evaluation** 
- **Grammar Analysis**: Checks sentence structure and verb tenses
- **Spelling Verification**: Identifies spelling errors and inconsistencies  
- **Vocabulary Assessment**: Evaluates word choice richness and appropriateness
- **Clarity Measurement**: Determines how clear and understandable the text is
- **Coherence Analysis**: Examines logical flow and idea connections
- **Diagram Evaluation**: Assesses diagram relevance, clarity, accuracy, and integration

### 2. **Intelligent Plagiarism Detection**
- **Conceptual Analysis**: Compares core project ideas and concepts
- **Similarity Scoring**: Provides percentage-based similarity assessment
- **Feature Comparison**: Identifies overlapping functionalities and approaches
- **Detailed Reporting**: Explains how similarity percentages are calculated

### 3. **Fallback System**
- **Graceful Degradation**: Works even without API key configuration
- **Basic Analysis**: Provides fundamental text analysis when AI is unavailable
- **Error Handling**: Robust error management for API failures

## Installation & Setup

### Step 1: Dependencies
The required dependency is already added to `pubspec.yaml`:
```yaml
dependencies:
  google_generative_ai: ^0.4.3
```

### Step 2: Get Gemini API Key
1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Create a new API key
4. Copy the generated key

### Step 3: Configure API Key

**Option A: Environment Variable (Recommended)**
```bash
export GEMINI_API_KEY="your-actual-api-key-here"
```

**Option B: Direct Code Modification**
Update the `_apiKey` constant in `lib/AI/check_eval.dart`:
```dart
static const String _apiKey = 'your-actual-api-key-here';
```

### Step 4: Install Dependencies
```bash
flutter pub get
```

## Usage Examples

### Project Evaluation
```dart
import 'package:grad_ease/AI/check_eval.dart';

// Evaluate a project description
String projectDescription = "Your project description here...";
String evaluation = await ProjectEvaluator.evaluateProject(projectDescription);
print(evaluation);
```

### Plagiarism Detection
```dart
import 'package:grad_ease/AI/check_eval.dart';

// Compare two project descriptions
String project1 = "First project description...";
String project2 = "Second project description...";
String plagiarismReport = await ProjectEvaluator.checkPlagiarism(project1, project2);
print(plagiarismReport);
```

### Demo Usage
```dart
// Run the comprehensive demo
import 'package:grad_ease/examples/gemini_evaluation_demo.dart';

void main() async {
  await GeminiEvaluationDemo.runAllDemos();
}
```

## API Response Format

### Project Evaluation Response
```
Total Percentage: 85%

- Grammar: 80% - Generally good grammar with minor sentence structure issues
- Spelling: 95% - Very few spelling errors detected
- Vocabulary: 75% - Adequate vocabulary with room for improvement
- Clarity: 80% - Clear and understandable with some complex sections
- Coherence: 85% - Good logical flow with minor transition improvements needed
- Diagram Relevance: 90% - Diagrams effectively support the content
- Diagram Clarity: 70% - Some diagrams need clearer labeling
- Diagram Accuracy: 85% - Technically correct with minor annotation issues
- Diagram Integration: 75% - Good correlation between text and diagrams
```

### Plagiarism Detection Response
```
The projects have a 15% similarity.

Similar Points:
- Both projects operate within the healthcare domain
- Both include blood donation components
- Both aim to improve communication and coordination

Explanation of Plagiarism Percentage Calculation:
The 15% similarity arises from overlapping healthcare context and shared blood donation features. While projects have similar components, their overall scope and functionalities differ significantly.
```

## Integration Points

### 1. In Existing Plagiarism Checker
The new AI evaluation can be integrated with the existing plagiarism system in `lib/AI/check_palagrism.dart`:

```dart
// Add this import
import 'check_eval.dart';

// Use in plagiarism checking
String aiAnalysis = await ProjectEvaluator.checkPlagiarism(description1, description2);
```

### 2. In Project Management Features
Integrate evaluation into student project submission workflows:

```dart
// When student submits project description
String evaluation = await ProjectEvaluator.evaluateProject(studentProject);
// Display evaluation to student and supervisor
```

## Error Handling

The system includes comprehensive error handling:

1. **API Key Missing**: Falls back to basic text analysis
2. **Network Issues**: Graceful degradation with informative messages  
3. **Rate Limiting**: Proper error messages for API quota exceeded
4. **Invalid Responses**: Fallback evaluation when AI response is empty

## Security Considerations

1. **API Key Protection**: Never commit API keys to version control
2. **Environment Variables**: Use secure environment variable management
3. **Rate Limiting**: Implement proper rate limiting for production use
4. **Data Privacy**: Ensure project descriptions are handled securely

## Performance Notes

- **Response Time**: Typically 2-5 seconds per evaluation
- **Rate Limits**: Google AI has usage quotas - monitor in production
- **Caching**: Consider caching results for repeated evaluations
- **Batch Processing**: Process multiple evaluations efficiently

## Troubleshooting

### Common Issues

1. **"API key not configured" error**
   - Verify GEMINI_API_KEY environment variable is set
   - Check if API key is valid and active

2. **Network connection errors**
   - Verify internet connectivity
   - Check firewall settings

3. **Quota exceeded errors**
   - Monitor API usage in Google AI Studio
   - Implement usage tracking in your app

4. **Empty responses**
   - System automatically falls back to basic analysis
   - Check API key permissions

### Testing the Integration

Run the demo to verify everything works:
```bash
cd /path/to/gradease
dart run lib/examples/gemini_evaluation_demo.dart
```

## Future Enhancements

1. **Advanced Prompting**: Customize evaluation criteria based on project type
2. **Multi-language Support**: Evaluate projects in different languages  
3. **Batch Processing**: Evaluate multiple projects simultaneously
4. **Custom Scoring**: Allow supervisors to set evaluation weights
5. **Historical Analysis**: Track evaluation improvements over time

## Files Modified

- `lib/AI/check_eval.dart` - Main evaluation logic with Gemini AI
- `pubspec.yaml` - Added google_generative_ai dependency
- `lib/examples/gemini_evaluation_demo.dart` - Comprehensive demo
- `GEMINI_AI_INTEGRATION.md` - This documentation

## Support

For technical issues:
1. Check the troubleshooting section above
2. Verify API key configuration
3. Run the demo file to test integration
4. Review error messages in console output

The Gemini AI integration brings powerful, intelligent evaluation capabilities to GradEase, providing students and supervisors with professional-grade project analysis and plagiarism detection.
