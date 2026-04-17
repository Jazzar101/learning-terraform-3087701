import requests
import json
import sys

DIRECTUS_URL = "http://18.170.111.59"
ADMIN_EMAIL = "admin@admin.com"
ADMIN_PASSWORD = "password123"


def test_health():
    r = requests.get(f"{DIRECTUS_URL}/server/health")
    assert r.status_code == 200, f"Health check failed. Response: {r.text}. Code: {r.status_code}"
    assert r.json()["status"] == "ok"
    print("[OK] Health check")


def login():
    r = requests.post(
        f"{DIRECTUS_URL}/auth/login",
        json={
            "email": ADMIN_EMAIL,
            "password": ADMIN_PASSWORD
        }
    )
    assert r.status_code == 200, "Login failed"
    data = r.json()["data"]
    assert "access_token" in data, f"No access token found. Response: {r.text}. Code: {r.status_code}"
    print("[OK] Login success")
    return data["access_token"]


def test_list_collections(token):
    r = requests.get(
        f"{DIRECTUS_URL}/collections",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert r.status_code == 200, f"Unable to list collections. Response: {r.text}. Code: {r.status_code}"
    print("[OK] Collections listing works")


def test_create_collection(token):
    payload = {
        "collection": "test_items",
        "schema": {"name": "Test Items"}
    }

    r = requests.post(
        f"{DIRECTUS_URL}/collections",
        json=payload,
        headers={"Authorization": f"Bearer {token}"}
    )

    # 200 if ok,  201 if created, 400 if already exists (acceptable)
    assert r.status_code in [200, 201, 400], f"Bad response code. Response: {r.text}. Code: {r.status_code}"
    print("[OK] Collection created or already exists")


def test_add_field(token):
    payload = {
        "field": "name",
        "type": "string"
    }

    r = requests.post(
        f"{DIRECTUS_URL}/fields/test_items",
        json=payload,
        headers={"Authorization": f"Bearer {token}"}
    )

    # 200 if ok, 201 if new, 400 if already exists (acceptable)
    assert r.status_code in [200, 201, 400], f"Bad response code. Response: {r.text}. Code: {r.status_code}"
    print("[OK] Field created or already exists")


def test_insert_item(token):
    payload = {"name": "My First Test Item"}

    r = requests.post(
        f"{DIRECTUS_URL}/items/test_items",
        json=payload,
        headers={"Authorization": f"Bearer {token}"}
    )

    assert r.status_code in [200, 201], f"Failed to create test item. Response: {r.text}. Code: {r.status_code}"
    item_id = r.json()["data"]["id"]
    print(f"[OK] Item inserted (id={item_id})")
    return item_id


def test_get_items(token):
    r = requests.get(
        f"{DIRECTUS_URL}/items/test_items",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert r.status_code == 200, "Unable to fetch items. Response: {r.text}. Code: {r.status_code}"
    assert isinstance(r.json()["data"], list)
    print("[OK] Item read works")


def test_update_item(token, item_id):
    payload = {"name": "Updated Item"}

    r = requests.patch(
        f"{DIRECTUS_URL}/items/test_items/{item_id}",
        json=payload,
        headers={"Authorization": f"Bearer {token}"}
    )

    assert r.status_code in [200, 201], f"Failed to update item. Response: {r.text}. Code: {r.status_code}"
    print("[OK] Item update works")


def test_delete_item(token, item_id):
    r = requests.delete(
        f"{DIRECTUS_URL}/items/test_items/{item_id}",
        headers={"Authorization": f"Bearer {token}"}
    )

    assert r.status_code in [200, 204], f"Failed to delete item. Response: {r.text}. Code: {r.status_code}"
    print("[OK] Item delete works")


if __name__ == "__main__":
    print("Starting Directus API tests...\n")

    test_health()
    token = login()
    test_list_collections(token)
    test_create_collection(token)
    test_add_field(token)

    item_id = test_insert_item(token)
    test_get_items(token)
    test_update_item(token, item_id)
    test_delete_item(token, item_id)

    print("\n✅ ALL TESTS PASSED SUCCESSFULLY ✅")
