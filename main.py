import time
import random
import datetime

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

app = FastAPI()


app.mount("/static", StaticFiles(directory="static", html=True), name="static")

QUOTES = {
    "dawn": [
        "In the space between night and day, between sleep and waking, lies the door to all possibilities. Here, the mind is most receptive to the infinite.",
        "The liminal hour whispers secrets that the day will forget. Listen now, while the veil is thin.",
        "Before the world wakes, you are everything and nothing. This is the truest state of being.",
        "Dawn is not merely light returning, but consciousness remembering itself.",
        "In this threshold moment, past and future dissolve. Only presence remains.",
        "The first light carries messages from the void. Each ray is a teaching.",
        "Between darkness and light, the soul finds its true nature.",
        "This is the hour of potential, when all paths remain open.",
    ],
    "morning": [
        "The best surfer out there is the one having the most fun. Nature doesn't hurry, yet everything is accomplished.",
        "Every wave is a teacher. The ocean speaks to those who listen with their whole being.",
        "Morning glass reflects not just light, but consciousness itself.",
        "The dawn patrol knows truths that books cannot teach.",
        "Salt water cures all wounds. The ocean remembers everything and forgives all.",
        "Perfect conditions exist only in this moment. Yesterday's waves are gone, tomorrow's haven't formed.",
        "The lineup is a meditation hall. Each set brings a new teaching.",
        "Flow state is the natural state. Everything else is resistance.",
    ],
    "midday": [
        "At the zenith, shadows disappear. Truth stands alone without interpretation. This is the hour of direct knowing.",
        "When the sun reaches its peak, illusions burn away. Only essence remains.",
        "High noon: the moment when light reveals everything and hides nothing.",
        "In full illumination, complexity dissolves into simplicity.",
        "The meridian teaches that extremes contain their own balance.",
        "Maximum light brings maximum clarity. This is the gift of the zenith.",
        "At solar apex, consciousness mirrors the sun - pure, direct, unwavering.",
        "Noon wisdom: what seems opposite at dawn and dusk is one at the peak.",
    ],
    "afternoon": [
        "The afternoon knows what the morning never suspected. Experience transforms knowledge into understanding.",
        "Golden hour approaches. The harsh becomes gentle, the certain becomes mysterious.",
        "In the slanted light, familiar things reveal their hidden dimensions.",
        "Afternoon teaches patience. The day's work is done; now comes integration.",
        "Shadows grow long, stories grow deep. This is the hour of contemplation.",
        "The afternoon mind sees connections invisible at noon.",
        "As light softens, wisdom deepens. The afternoon is consciousness maturing.",
        "Between action and rest lies the afternoon - a bridge of golden understanding.",
    ],
    "evening": [
        "As the sun sets, the inner sun rises. What was external becomes internal. The cycle prepares for renewal.",
        "Twilight is the great teacher of transitions. Here, we learn to let go with grace.",
        "The vespers hour: when day's experiences transform into night's wisdom.",
        "In purple light, the mundane becomes sacred. Evening is nature's daily transfiguration.",
        "As colors deepen, so does perception. The evening eye sees what daylight obscures.",
        "This is the hour of synthesis, when fragments of the day unite into meaning.",
        "Evening knows that endings are beginnings in disguise.",
        "The threshold between day and night is where transformation lives.",
    ],
    "night": [
        "In darkness, the eye learns to see. In silence, the ear learns to hear. In stillness, consciousness expands.",
        "Night is not the absence of light, but the presence of a different kind of knowing.",
        "Stars are holes in the veil. Through them, infinity whispers.",
        "The void is not empty but pregnant with all possibilities.",
        "In deep night, the small self dissolves. What remains is vast.",
        "Darkness is the canvas on which consciousness paints its truest visions.",
        "Night teaches that what cannot be seen may be the most real.",
        "In the deep field of night, awareness discovers its true magnitude.",
    ],
}

last_quote = {}


def get_time_phase():
    hour = datetime.datetime.now().hour
    if 5 <= hour < 7:
        return "dawn"
    elif 7 <= hour < 11:
        return "morning"
    elif 11 <= hour < 15:
        return "midday"
    elif 15 <= hour < 18:
        return "afternoon"
    elif 18 <= hour < 21:
        return "evening"
    else:
        return "night"


def get_random_quote(phase):
    available_quotes = QUOTES[phase]
    if phase in last_quote and len(available_quotes) > 1:
        available_quotes = [q for q in available_quotes if q != last_quote[phase]]

    selected = random.choice(available_quotes)
    last_quote[phase] = selected
    return selected


class Snapshot(BaseModel):
    unix_ms: int
    quote: str
    phase: str


@app.get("/api/snapshot")
async def snapshot() -> Snapshot:
    phase = get_time_phase()
    quote = get_random_quote(phase)
    return Snapshot(unix_ms=int(time.time() * 1000), quote=quote, phase=phase)


@app.get("/ping")
async def ping() -> str:
    return "ok"
