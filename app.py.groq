import os
from pathlib import Path
from dotenv import load_dotenv
from groq import Groq
from fastapi.responses import StreamingResponse
from fastapi import FastAPI
from pydantic import BaseModel
import uvicorn

load_dotenv()
app = FastAPI()
client = Groq(api_key=os.getenv("GROQ_API_KEY"))


class TTSRequest(BaseModel):
    text: str
    model: str = "canopylabs/orpheus-v1-english"
    voice: str = "autumn"


@app.post("/tts")
async def tts_stream(req: TTSRequest):
    response = client.audio.speech.create(
        model=req.model,
        voice=req.voice,
        response_format="wav",
        input=req.text,
    )

    def gen():
        for chunk in response.iter_bytes(8192):
            yield chunk

    return StreamingResponse(gen(), media_type="audio/wav")


if __name__ == "__main__":
    uvicorn.run(
        "app:app",
        host=os.getenv("HOST", "127.0.0.1"),
        port=int(os.getenv("PORT", "8001")),
        reload=True,
    )
