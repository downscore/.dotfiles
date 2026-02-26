import asyncio

async def fetch_with_timeout(coro, seconds=5.0):
  try:
    return await asyncio.wait_for(coro, timeout=seconds)
  except asyncio.TimeoutError:
    return None
