import dataclasses
from dataclasses import field, dataclass
from datetime import datetime, timedelta

@dataclass
class CodeEntry:
    code: str
    createdAt: datetime = field(default_factory=datetime.now)

    def isExpired(self) -> bool:
        return datetime.now() - self.createdAt > timedelta(minutes=5)

CodeStorage: dict[str, CodeEntry] = {}

def saveCode(email: str, code:str):
    CodeStorage[email] = CodeEntry(code)

def verifyCode(email: str, inputCode: str) -> bool:
    entry = CodeStorage.get(email)
    if entry is None:
        return False

    if entry.isExpired():
        del CodeStorage[email]
        return False

    if entry.code == inputCode:
        del CodeStorage[email]
        return True

    return False
