import requests
import os

GHOST_URL = os.getenv("GHOST_URL")
KEY = os.getenv("CONTENT_API_KEY")

def test_posts():
    url = f"{GHOST_URL}/ghost/api/content/posts/?key={KEY}"
    r = requests.get(url)
    assert r.status_code == 200
    assert "posts" in r.json()
