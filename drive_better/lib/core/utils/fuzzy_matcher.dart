import 'package:string_similarity/string_similarity.dart';
import 'text_normalizer.dart';

class FuzzyMatcher {
  FuzzyMatcher._();

  /// Returns a score between 0 and 1 (higher = better match).
  static double score(String query, String candidate) {
    final q = TextNormalizer.normalize(query);
    final c = TextNormalizer.normalize(candidate);
    if (q.isEmpty || c.isEmpty) return 0;
    final diceSim = StringSimilarity.compareTwoStrings(q, c);
    final tokenSim = _tokenSetRatio(q, c);
    return (diceSim * 0.4 + tokenSim * 0.6).clamp(0.0, 1.0);
  }

  static double _tokenSetRatio(String a, String b) {
    final setA = a.split(' ').toSet();
    final setB = b.split(' ').toSet();
    if (setA.isEmpty || setB.isEmpty) return 0;
    final intersection = setA.intersection(setB);
    final union = setA.union(setB);
    return intersection.length / union.length;
  }
}
