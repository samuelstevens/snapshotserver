import time

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from services import weather, quotes, theme

app = FastAPI()

app.mount("/static", StaticFiles(directory="static"), name="static")


@app.get("/api/snapshot")
async def snapshot():
    return {
        "weather": weather.current(),
        "quote": quotes.todays_quote(),
        "theme": theme.palette(),
        "ts": int(time.time()),
    }


@app.get("/ping")
async def ping():
    return {"ok": True}
