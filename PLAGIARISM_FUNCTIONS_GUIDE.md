# Group Description Retrieval Functions - Documentation

This document provides comprehensive documentation for all the functions available to retrieve and work with group descriptions from Firestore for plagiarism checking purposes.

## Available Functions in PlagiarismChecker Class

### 1. Basic Retrieval Functions

#### `getAllGroupDescriptions()` 
**Purpose**: Retrieves all group descriptions from Firestore
**Returns**: `Future<List<Map<String, dynamic>>>`
**Usage**:
```dart
List<Map<String, dynamic>> allGroups = await PlagiarismChecker.getAllGroupDescriptions();
```
**Data Structure Returned**:
```dart
{
  'groupId': 'document_id',
  'groupName': 'Group Name',
  'description': 'Project description text',
  'createdAt': 'timestamp',
  'leaderName': 'Leader Name',
  'supervisor_id': 'supervisor_id',
  'member_count': 5
}
```

#### `getOtherGroupDescriptions(String currentGroupId)`
**Purpose**: Gets all group descriptions except the specified current group
**Parameters**: 
- `currentGroupId`: ID of the group to exclude
**Returns**: `Future<List<Map<String, dynamic>>>`
**Usage**:
```dart
List<Map<String, dynamic>> otherGroups = await PlagiarismChecker.getOtherGroupDescriptions("current_group_id");
```

### 2. Plagiarism Checking Functions

#### `checkPlagiarism(String description)`
**Purpose**: Simple plagiarism check (uses real comparison)
**Parameters**: 
- `description`: Text to check for plagiarism
**Returns**: `Future<String>` - Formatted analysis report
**Usage**:
```dart
String result = await PlagiarismChecker.checkPlagiarism("Project description text...");
```

#### `checkRealPlagiarism(String description, {String? currentGroupId, double threshold = 0.3})`
**Purpose**: Advanced plagiarism checking with actual text comparison
**Parameters**: 
- `description`: Text to check
- `currentGroupId`: Optional - group to exclude from comparison
- `threshold`: Similarity threshold (0.0 to 1.0)
**Returns**: `Future<String>` - Detailed analysis report
**Usage**:
```dart
String result = await PlagiarismChecker.checkRealPlagiarism(
  "Project description...",
  currentGroupId: "group123",
  threshold: 0.25
);
```

#### `checkPlagiarismAgainstGroups(String description, {String? currentGroupId})`
**Purpose**: Simulated plagiarism check with group context
**Parameters**: 
- `description`: Text to check
- `currentGroupId`: Optional - group to exclude
**Returns**: `Future<String>` - Analysis report with simulation
**Usage**:
```dart
String result = await PlagiarismChecker.checkPlagiarismAgainstGroups(
  "Project description...",
  currentGroupId: "group123"
);
```

### 3. Similarity Analysis Functions

#### `calculateTextSimilarity(String text1, String text2)`
**Purpose**: Calculate similarity between two text strings using Jaccard coefficient
**Parameters**: 
- `text1`: First text
- `text2`: Second text
**Returns**: `double` - Similarity score (0.0 to 1.0)
**Usage**:
```dart
double similarity = PlagiarismChecker.calculateTextSimilarity(
  "First description",
  "Second description"
);
```

#### `findActualMatches(String currentDescription, String? currentGroupId, {double threshold = 0.3})`
**Purpose**: Find groups with similar descriptions above threshold
**Parameters**: 
- `currentDescription`: Description to compare
- `currentGroupId`: Optional - group to exclude
- `threshold`: Minimum similarity score
**Returns**: `Future<List<Map<String, dynamic>>>` - List of matching groups with similarity scores
**Usage**:
```dart
List<Map<String, dynamic>> matches = await PlagiarismChecker.findActualMatches(
  "Project description...",
  "current_group_id",
  threshold: 0.25
);
```

### 4. Utility Functions

#### `getGroupCount()`
**Purpose**: Get total number of groups in database
**Returns**: `Future<int>`
**Usage**:
```dart
int totalGroups = await PlagiarismChecker.getGroupCount();
```

#### `searchGroupsByKeyword(String keyword)`
**Purpose**: Search groups by keyword in description or name
**Parameters**: 
- `keyword`: Search term
**Returns**: `Future<List<Map<String, dynamic>>>`
**Usage**:
```dart
List<Map<String, dynamic>> results = await PlagiarismChecker.searchGroupsByKeyword("Flutter");
```

#### `demonstrateGroupDescriptionRetrieval()`
**Purpose**: Demo function showing all capabilities
**Returns**: `Future<void>`
**Usage**:
```dart
await PlagiarismChecker.demonstrateGroupDescriptionRetrieval();
```

## Integration Examples

### Example 1: Basic Plagiarism Check in UI
```dart
Future<void> checkUserDescription(String userInput) async {
  try {
    String result = await PlagiarismChecker.checkPlagiarism(userInput);
    
    // Display result in UI
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Plagiarism Check Results"),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  } catch (e) {
    // Handle error
    print("Error: $e");
  }
}
```

### Example 2: Advanced Comparison with Current Group
```dart
Future<String> checkAgainstOtherGroups(String description, String currentGroupId) async {
  try {
    // Get other groups for comparison
    List<Map<String, dynamic>> otherGroups = 
        await PlagiarismChecker.getOtherGroupDescriptions(currentGroupId);
    
    print("Comparing against ${otherGroups.length} other groups");
    
    // Perform real plagiarism check
    String result = await PlagiarismChecker.checkRealPlagiarism(
      description,
      currentGroupId: currentGroupId,
      threshold: 0.2 // 20% similarity threshold
    );
    
    return result;
  } catch (e) {
    return "Error performing plagiarism check: $e";
  }
}
```

### Example 3: Find and Display Similar Groups
```dart
Future<void> findSimilarProjects(String projectDescription) async {
  try {
    List<Map<String, dynamic>> similarGroups = 
        await PlagiarismChecker.findActualMatches(
          projectDescription,
          null, // Include all groups
          threshold: 0.15 // Low threshold to find any similarities
        );
    
    if (similarGroups.isNotEmpty) {
      print("Found ${similarGroups.length} similar projects:");
      
      for (var group in similarGroups) {
        print("- ${group['groupName']}: ${group['similarityPercentage']}% similar");
      }
    } else {
      print("No similar projects found - your project appears to be unique!");
    }
  } catch (e) {
    print("Error finding similar groups: $e");
  }
}
```

## Error Handling

All functions include proper error handling:

```dart
try {
  List<Map<String, dynamic>> groups = await PlagiarismChecker.getAllGroupDescriptions();
  // Process groups...
} catch (e) {
  print('Error fetching group descriptions: $e');
  // Handle error appropriately
}
```

## Database Structure Expected

The functions expect groups to be stored in Firestore with the following structure:

```
groups/ (collection)
  ├── group_id_1/ (document)
  │   ├── groupName: "Group Name"
  │   ├── description: "Project description text"
  │   ├── leaderName: "Leader Name"
  │   ├── createdAt: Timestamp
  │   ├── supervisor_id: "supervisor_id"
  │   └── member_count: 5
  └── group_id_2/ (document)
      └── ... (same structure)
```

## Performance Considerations

1. **Caching**: Consider implementing caching for frequently accessed group data
2. **Pagination**: For large datasets, implement pagination in `getAllGroupDescriptions()`
3. **Indexing**: Ensure Firestore has appropriate indexes for search operations
4. **Rate Limiting**: Be mindful of Firestore read quotas

## Testing

Use the `PlagiarismTestHelper` class and `GroupDescriptionUsageExample` for comprehensive testing:

```dart
// Run all tests
await GroupDescriptionUsageExample.runAllExamples();

// Run specific tests
await PlagiarismTestHelper.testRetrieveAllDescriptions();
await PlagiarismTestHelper.testPlagiarismCheck("test description");
```

## Summary

These functions provide a complete solution for:
- ✅ Retrieving all group descriptions from Firestore
- ✅ Excluding current group from comparisons
- ✅ Performing real text similarity analysis
- ✅ Finding groups with similar content
- ✅ Searching by keywords
- ✅ Getting database statistics
- ✅ Comprehensive error handling
- ✅ Multiple plagiarism checking methods

The implementation is ready for production use and can be easily integrated into your existing Flutter app with Firebase backend.
