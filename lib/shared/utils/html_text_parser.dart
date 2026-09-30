/// Strips common HTML tags and returns clean text.
/// Handles: <p>, <br>, <b>, <strong>, <i>, <em>, <ul>, <ol>, <li>, <a>, <h1>-<h6>, <span>, <div>
/// Converts block-level elements to newlines for readability.
String stripHtmlTags(String html) {
  if (html.isEmpty) return html;

  String text = html;

  // Replace block-level closing tags with newlines
  text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');
  text = text.replaceAll(RegExp(r'</div>', caseSensitive: false), '\n');
  text = text.replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');
  text = text.replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n');
  text = text.replaceAll(RegExp(r'<br\s*/?>',caseSensitive: false), '\n');

  // Replace list items with bullet
  text = text.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ');

  // Remove all remaining HTML tags
  text = text.replaceAll(RegExp(r'<[^>]*>'), '');

  // Decode common HTML entities
  text = text
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ');

  // Collapse multiple newlines into max 2
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  // Trim leading/trailing whitespace
  text = text.trim();

  return text;
}
