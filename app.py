from pydantic import functional_serializers
import os
from pathlib import Path
from dotenv import load_dotenv
import requests
from fastapi.responses import StreamingResponse
from fastapi import FastAPI
from pydantic import BaseModel
import uvicorn

load_dotenv()
app = FastAPI()


TTS_MODEL = os.getenv("TTS_MODEL", "gemini/gemini-3.1-flash-tts-preview/Aoede")


class TTSRequest(BaseModel):
    text: str
    model: str = TTS_MODEL


@app.post("/tts")
async def tts_stream(req: TTSRequest):
    response = requests.post(
        os.getenv("TTS_API"),
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {os.getenv('TTS_API_KEY')}",
        },
        json={
            "model": req.model,
            "input": req.text,
            "language": "Indonesian",
        },
        stream=True,
    )

    def gen():
        for chunk in response.iter_content(chunk_size=8192):
            yield chunk

    return StreamingResponse(gen(), media_type="audio/mpeg")


if __name__ == "__main__":
    uvicorn.run(
        "app:app",
        host=os.getenv("HOST", "127.0.0.1"),
        port=int(os.getenv("PORT", "8001")),
        reload=False,
    )
