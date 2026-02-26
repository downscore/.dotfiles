from typing import Optional

def parse_headers(raw: str) -> dict[str, list[str]]:
  headers: dict[str, list[str]] = {}
  for line in raw.strip().split("\n"):
    key, _, val = line.partition(": ")
    headers.setdefault(key, []).append(val)
  return headers

def first(items: list[int]) -> Optional[int]:
  return items[0] if items else None
