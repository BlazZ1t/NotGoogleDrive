from passlib.context import CryptContext
from utils import hash_password, verify_password

def test_password_hashing():
    pwd = "mysecret"
    hashed = hash_password(pwd)
    assert hashed != pwd
    assert verify_password(pwd, hashed)
    assert not verify_password("wrong", hashed)