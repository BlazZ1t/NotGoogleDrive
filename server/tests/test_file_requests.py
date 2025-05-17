import io

def test_upload_and_list(client):
    # 1) User registration
    resp = client.post("/register", json={"username": "bob", "password": "pass"})
    assert resp.status_code == 201

    # 2) Log in and get token
    login = client.post("/login", json={"username": "bob", "password": "pass"})
    assert login.status_code == 200
    token = login.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 3) File uploading (file and 'filename' field)
    content = b"hello world"
    file_obj = io.BytesIO(content)
    file_obj.name = "hello.txt"
    upload = client.post(
        "/upload",
        headers=headers,
        data={"filename": file_obj.name},
        files={"file": (file_obj.name, file_obj)},
    )
    # FastAPI will return 200 OK by deafult
    assert upload.status_code == 200
    assert "uploaded successfully" in upload.json().get("message", "")

    # 4) Getting list of objects
    resp_list = client.get("/list", headers=headers)
    assert resp_list.status_code == 200
    items = resp_list.json()
    assert isinstance(items, list)
