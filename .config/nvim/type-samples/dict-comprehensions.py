def invert(d):
  return {v: k for k, v in d.items()}

def group_by(items, key):
  out = {}
  for item in items:
    out.setdefault(key(item), []).append(item)
  return out

def merge(*dicts):
  return {k: v for d in dicts for k, v in d.items()}
