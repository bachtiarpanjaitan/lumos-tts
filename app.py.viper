from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.responses import FileResponse
from piper.voice import PiperVoice
import wave
import uuid
import os
import uvicorn
from io import BytesIO
from fastapi.responses import StreamingResponse
from dotenv import load_dotenv
load_dotenv()

app = FastAPI()

MODEL_PATH =  os.getenv(
   "MODEL_PATH",
   "models/id_ID-news_tts-medium.onnx"
)
voice = PiperVoice.load(MODEL_PATH)
class TTSRequest(BaseModel):
    text: str

# @app.post("/tts")
# async def tts(request: TTSRequest):

#     os.makedirs("output", exist_ok=True)

#     filename = f"output/{uuid.uuid4()}.wav"

#     with wave.open(filename, "wb") as wav_file:
#         voice.synthesize_wav(
#             request.text,
#             wav_file
#         )

#     return FileResponse(
#         path=filename,
#         media_type="audio/wav",
#         filename="speech.wav"
#     )

@app.post("/tts")
async def tts(request: TTSRequest):

    buffer = BytesIO()

    with wave.open(buffer, "wb") as wav_file:
        voice.synthesize_wav(
            request.text,
            wav_file
        )

    buffer.seek(0)

    return StreamingResponse(
        buffer,
        media_type="audio/wav"
    )

if __name__ == "__main__":
    uvicorn.run(
        "app:app",
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", "8000")),
        reload=True
    )
