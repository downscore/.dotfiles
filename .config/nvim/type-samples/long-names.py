def calculate_weighted_average_excluding_outliers(measurements):
  sorted_measurements = sorted(measurements)
  lower_bound_index = len(sorted_measurements) // 10
  upper_bound_index = len(sorted_measurements) - lower_bound_index
  trimmed_measurements = sorted_measurements[lower_bound_index:upper_bound_index]
  total_weight = sum(range(1, len(trimmed_measurements) + 1))
  weighted_sum = 0
  for position_index, measurement_value in enumerate(trimmed_measurements):
    current_weight = position_index + 1
    weighted_sum += measurement_value * current_weight
  return weighted_sum / total_weight
