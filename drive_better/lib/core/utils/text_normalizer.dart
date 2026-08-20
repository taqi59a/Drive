class TextNormalizer {
  TextNormalizer._();

  static const _stopWords = {
    'a', 'an', 'the', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
    'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'shall',
    'should', 'may', 'might', 'must', 'can', 'could', 'of', 'in', 'on',
    'at', 'to', 'for', 'with', 'by', 'from', 'up', 'about', 'into', 'through',
    'during', 'before', 'after', 'if', 'then', 'that', 'this', 'these', 'those',
    'it', 'its', 'you', 'your', 'we', 'our', 'they', 'their', 'what', 'which',
    'who', 'how', 'when', 'where', 'why',
  };

  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static List<String> tokenize(String text) {
    return normalize(text)
        .split(' ')
        .where((t) => t.length > 2 && !_stopWords.contains(t))
        .toList();
  }

  static String fixOcrArtifacts(String raw) {
    return raw
        .replaceAll(RegExp(r'\bl\b'), '1')
        .replaceAll(RegExp(r'\bO\b'), '0')
        .replaceAll('|', 'I')
        .replaceAll('`', "'")
        .replaceAll(RegExp(r'\n+'), ' ')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
  }
}
