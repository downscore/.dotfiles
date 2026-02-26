def rotate(lst, k):
  k %= len(lst)
  return lst[-k:] + lst[:-k]

def trim_and_pad(data, length, fill=0):
  return (data[:length] + [fill] * length)[:length]

def head_tail(seq):
  return seq[0], seq[1:], seq[-1], seq[:-1]
