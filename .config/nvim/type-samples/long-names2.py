def find_longest_consecutive_sequence(input_values):
  unique_values = set(input_values)
  longest_streak_length = 0
  for current_value in unique_values:
    if current_value - 1 not in unique_values:
      current_streak_length = 1
      while current_value + current_streak_length in unique_values:
        current_streak_length += 1
      longest_streak_length = max(longest_streak_length, current_streak_length)
  return longest_streak_length
