import functools

def retry(max_attempts=3):
  @functools.wraps
  def decorator(func):
    def wrapper(*args, **kwargs):
      for attempt in range(max_attempts):
        try:
          return func(*args, **kwargs)
        except Exception as e:
          if attempt == max_attempts - 1:
            raise
    return wrapper
  return decorator
