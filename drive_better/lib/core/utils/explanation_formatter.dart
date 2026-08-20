extension ExplanationFormatter on String? {
  String get cleanExplanation {
    if (this == null || this!.isEmpty) return '';
    String text = this!;
    
    // 1. Fix missing space/colon in LESSON 1If -> LESSON 1: If
    text = text.replaceAllMapped(
      RegExp(r'\bLESSON\s+(\d+)([A-Za-z])'),
      (match) => 'LESSON ${match[1]}: ${match[2]}',
    );
    
    // 2. Fix missing space after dot/period before capital letters: .The -> . The
    text = text.replaceAllMapped(
      RegExp(r'\.([A-Z])'),
      (match) => '. ${match[1]}',
    );
    
    // 3. Fix missing space after quote-dot/period: '.Put or ’.Put -> '. Put or ’. Put
    text = text.replaceAllMapped(
      RegExp(r"('\.|\u2019\.)([A-Z])"),
      (match) => '${match[1]} ${match[2]}',
    );

    // 4. Fix missing space after parenthesis-dot/period: ).It -> ). It
    text = text.replaceAllMapped(
      RegExp(r'\)\.([A-Z])'),
      (match) => '). ${match[1]}',
    );

    // 5. Fix missing space after colon (avoiding URLs like http:// or https://)
    text = text.replaceAllMapped(
      RegExp(r'(?<!http|https):([a-zA-Z])'),
      (match) => ': ${match[1]}',
    );
    
    return text;
  }
}
