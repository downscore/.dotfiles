def flatten(nested):
  for item in nested:
    if isinstance(item, list):
      yield from flatten(item)
    else:
      yield item
