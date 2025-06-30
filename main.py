import time

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from services import weather, quotes, theme
from pydantic import BaseModel

app = FastAPI()

app.mount("/", StaticFiles(directory="static"), name="static")


class Snapshot(BaseModel):
    unix_ms: int
    quote: str


@app.get("/api/snapshot")
async def snapshot() -> Snapshot:
    return Snapshot(unix_ms=int(time.time() * 1000), quote="Who are you?")


@app.get("/ping")
async def ping() -> str:
    return "ok"
