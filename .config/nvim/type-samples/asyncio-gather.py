import asyncio

async def fetch(url, session):
  async with session.get(url) as resp:
    return await resp.json()

async def fetch_all(urls):
  async with aiohttp.ClientSession() as session:
    tasks = [fetch(url, session) for url in urls]
    return await asyncio.gather(*tasks)

if __name__ == "__main__":
  urls = ["https://api.example.com/1", "https://api.example.com/2"]
  results = asyncio.run(fetch_all(urls))
