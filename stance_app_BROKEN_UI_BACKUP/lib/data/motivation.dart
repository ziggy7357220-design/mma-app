// ============================================================
// Motivation Data — curated quotes for the athlete.
// ============================================================

class Quote {
  final String text;
  final String author;
  final String category;
  final String? sport;

  const Quote({
    required this.text,
    required this.author,
    required this.category,
    this.sport,
  });
}

class MotivationLibrary {
  static const List<Quote> quotes = [
    // Legends
    Quote(text: 'Float like a butterfly, sting like a bee.', author: 'Muhammad Ali', category: 'Legends', sport: 'Boxing'),
    Quote(text: 'The more you sweat in training, the less you bleed in combat.', author: 'Unknown', category: 'Legends'),
    Quote(text: 'I fear not the man who has practiced 10,000 kicks once, but I fear the man who has practiced one kick 10,000 times.', author: 'Bruce Lee', category: 'Legends'),

    // Discipline & Consistency
    Quote(text: 'Discipline is doing what needs to be done, even if you don\'t want to do it.', author: 'Unknown', category: 'Discipline'),
    Quote(text: 'We are what we repeatedly do. Excellence, then, is not an act, but a habit.', author: 'Aristotle', category: 'Consistency'),
    Quote(text: 'Small daily improvements are the key to staggering long-term results.', author: 'Unknown', category: 'Consistency'),

    // Mental Toughness
    Quote(text: 'The only limit to our realization of tomorrow will be our doubts of today.', author: 'Franklin D. Roosevelt', category: 'Mental Toughness'),
    Quote(text: 'It\'s not about how hard you hit. It\'s about how hard you can get hit and keep moving forward.', author: 'Rocky Balboa', category: 'Mental Toughness'),
    Quote(text: 'Hard work beats talent when talent doesn\'t work hard.', author: 'Tim Notke', category: 'Mental Toughness'),

    // Focus
    Quote(text: 'Focus on the process, not the outcome.', author: 'Unknown', category: 'Focus'),
    Quote(text: 'Concentrate all your thoughts upon the work at hand.', author: 'Unknown', category: 'Focus'),

    // Coaches & Champions
    Quote(text: 'A champion is someone who gets up when they can\'t.', author: 'Jack Dempsey', category: 'Champions', sport: 'Boxing'),
    Quote(text: 'The fight is won or lost far away from witnesses—behind the lines, in the gym, and out there on the road.', author: 'Muhammad Ali', category: 'Champions', sport: 'Boxing'),
  ];

  static List<String> get categories => {
    for (var q in quotes) q.category
  }.toList()..sort();

  static Quote getQuoteOfDay() {
    // Use a stable seed based on the date to ensure everyone gets the same QOTD
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    return quotes[seed % quotes.length];
  }
}
