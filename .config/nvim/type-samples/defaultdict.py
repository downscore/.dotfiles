from collections import defaultdict

def adjacency_list(edges):
  graph = defaultdict(list)
  for src, dst in edges:
    graph[src].append(dst)
    graph[dst].append(src)
  return dict(graph)
