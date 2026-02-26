import asyncio

async def producer(queue, n):
  for i in range(n):
    await asyncio.sleep(0.1)
    await queue.put(i)
  await queue.put(None)

async def consumer(queue):
  while True:
    item = await queue.get()
    if item is None:
      break
    print(f"processing {item}")
    queue.task_done()

async def main():
  queue = asyncio.Queue(maxsize=10)
  await asyncio.gather(producer(queue, 20), consumer(queue))
