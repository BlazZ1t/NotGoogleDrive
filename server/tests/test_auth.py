def test_register_and_login(client):
    # 1) Registration of new user
    resp = client.post("/register", json={
        "username": "alice",
        "password": "secret123"
    })
    assert resp.status_code == 201

    # 2) Second registration (409 Conflict)
    resp2 = client.post("/register", json={
        "username": "alice",
        "password": "secret123"
    })
    assert resp2.status_code == 409

    # 3) Log in
    login = client.post("/login", json={
        "username": "alice",
        "password": "secret123"
    })
    assert login.status_code == 200
    data = login.json()
    assert "access_token" in data
