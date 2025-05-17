# server/tests/test_utils.py

from mongo_manager import MongoManager

def test_password_hashing_with_pwd_context():
    mgr = MongoManager()
    pwd = "mysecret"
    hashed = mgr.pwd_context.hash(pwd)
    assert hashed != pwd
    assert mgr.pwd_context.verify(pwd, hashed)
    assert not mgr.pwd_context.verify("wrong", hashed)

def test_create_and_verify_user():
    mgr = MongoManager()
    username = "alice"
    password = "secret123"

    created = mgr.create_user(username, password)
    assert created is True

    # verify_user возвращает dict при верном пароле
    assert isinstance(mgr.verify_user(username, password), dict)
    # и None при неверном
    assert mgr.verify_user(username, "badpass") is None
