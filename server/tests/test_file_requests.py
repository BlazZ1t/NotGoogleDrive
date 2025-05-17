import io

def test_upload_and_list(client):
    # Creating file in memory
    file_content = b"hello world"
    file_obj = io.BytesIO(file_content)
    file_obj.name = "hello.txt"

    # Uploading
    resp = client.post("/upload", files={"file": (file_obj.name, file_obj)})
    assert resp.status_code == 201
    file_id = resp.json()["file_id"]

    # List of files
    resp2 = client.get("/files")
    assert resp2.status_code == 200
    files = resp2.json()
    assert any(f["id"] == file_id for f in files)