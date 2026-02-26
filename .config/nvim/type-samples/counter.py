from collections import Counter

def most_common_words(text, n=5):
  words = text.lower().split()
  counts = Counter(words)
  return dict(counts.most_common(n))
