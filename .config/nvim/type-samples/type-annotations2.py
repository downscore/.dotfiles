from typing import Callable, TypeVar

T = TypeVar("T")

def apply_all(funcs: list[Callable[[T], T]], val: T) -> T:
  for fn in funcs:
    val = fn(val)
  return val
