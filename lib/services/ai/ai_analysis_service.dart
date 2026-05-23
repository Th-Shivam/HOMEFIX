import '../../models/service_request_model.dart';

class AiAnalysisResult {
  final int urgencyScore;
  final String suggestedIssueCategory;
  final double confidenceScore;
  final String summary;

  const AiAnalysisResult({
    required this.urgencyScore,
    required this.suggestedIssueCategory,
    required this.confidenceScore,
    required this.summary,
  });
}

abstract class AiAnalysisService {
  Future<AiAnalysisResult> analyzeIssue({
    required ServiceType serviceType,
    required List<String> secureImageUris,
  });
}

class MockAiAnalysisService implements AiAnalysisService {
  const MockAiAnalysisService();

  @override
  Future<AiAnalysisResult> analyzeIssue({
    required ServiceType serviceType,
    required List<String> secureImageUris,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final seed = secureImageUris.isEmpty
        ? DateTime.now().millisecond
        : secureImageUris.first.length * secureImageUris.length;
    final urgency = (seed % 100) + 1;
    final category = serviceType == ServiceType.electrician
        ? 'Electrical Fault Diagnosis'
        : 'Plumbing Leakage Inspection';

    return AiAnalysisResult(
      urgencyScore: urgency,
      suggestedIssueCategory: category,
      confidenceScore: 0.7 + ((seed % 25) / 100),
      summary: 'AI has detected a probable ${serviceType.name} issue. Review and assign priority.',
    );
  }
}
