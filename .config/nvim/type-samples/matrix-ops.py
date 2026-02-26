def transpose(matrix):
  return [row[:] for row in zip(*matrix)]

def spiral_order(matrix):
  result = []
  while matrix:
    result += matrix[0]
    matrix = list(zip(*matrix[1:]))[::-1]
  return result

def subgrid(matrix, r, c, size):
  return [row[c:c+size] for row in matrix[r:r+size]]
