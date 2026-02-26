def mergesort(arr):
  if len(arr) <= 1:
    return arr
  mid = len(arr) // 2
  left = mergesort(arr[:mid])
  right = mergesort(arr[mid:])
  return merge(left, right)
