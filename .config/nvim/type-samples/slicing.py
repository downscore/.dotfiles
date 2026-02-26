def chunk(lst, n):
  return [lst[i:i+n] for i in range(0, len(lst), n)]

def windows(seq, k):
  return [seq[i:i+k] for i in range(len(seq) - k + 1)]

def interleave(a, b):
  out = [None] * (len(a) + len(b))
  out[::2] = a
  out[1::2] = b
  return out
