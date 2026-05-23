abstract class TicketMediaStorageService {
  Future<List<String>> storeIssueImages(List<String> localReferences);
}

class MockSecureMediaStorageService implements TicketMediaStorageService {
  const MockSecureMediaStorageService();

  @override
  Future<List<String>> storeIssueImages(List<String> localReferences) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return localReferences
        .where((value) => value.trim().isNotEmpty)
        .map((value) => value.trim())
        .map(Uri.encodeComponent)
        .map((value) => 'secure://ticket-media/$value')
        .toList(growable: false);
  }
}
