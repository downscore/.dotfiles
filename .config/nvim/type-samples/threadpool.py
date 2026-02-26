from concurrent.futures import ThreadPoolExecutor, as_completed

def fetch_all(urls):
  results = {}
  with ThreadPoolExecutor(max_workers=4) as pool:
    futures = {pool.submit(fetch, url): url for url in urls}
    for future in as_completed(futures):
      url = futures[future]
      try:
        results[url] = future.result()
      except Exception as e:
        results[url] = e
  return results
