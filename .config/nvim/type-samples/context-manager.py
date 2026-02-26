from contextlib import contextmanager

@contextmanager
def open_and_lock(path, mode="r"):
  f = open(path, mode)
  try:
    yield f
  finally:
    f.close()
