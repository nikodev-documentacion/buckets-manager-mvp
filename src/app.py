from fastapi import FastAPI, Response, HTTPException, UploadFile, File
from src.minio_client import client
from dotenv import load_dotenv
import os
from io import BytesIO
from datetime import timedelta


load_dotenv()

app = FastAPI()

BUCKET = os.getenv("MINIO_BUCKET")

@app.get("/files/{object_name}")
def get_file(object_name: str):
    try:
        obj = client.get_object(BUCKET, object_name)
        data = obj.read()
        obj.close()
        obj.release_conn()
    except Exception as e:
        print(f"Error fetching {object_name} from bucket {BUCKET}: {str(e)}")
        raise HTTPException(status_code=404, detail=f"File not found: {str(e)}")

    return Response(
        content=data,
        media_type="application/octet-stream",
        headers={
            "Content-Disposition": f"inline; filename={object_name}"
        }
    )

@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    try:
        file_data = await file.read()
        file_stream = BytesIO(file_data)
        file_stream.seek(0)

        client.put_object(
            bucket_name=BUCKET,
            object_name=file.filename,
            data=file_stream,
            length=len(file_data),
            content_type=file.content_type
        )

        return {
            "filename": file.filename,
            "size_bytes": len(file_data),
            "content_type": file.content_type,
            "status": "uploaded"
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/files/presigned-upload")
def get_presigned_upload_url(object_name: str, expires_in: int = 600):
    """
    Devuelve una URL pre-firmada para subir un archivo DIRECTO a MinIO
    sin pasar por el backend como proxy.
    expires_in está en segundos (por defecto 10 minutos).
    """
    try:
        url = client.presigned_put_object(
            bucket_name=BUCKET,
            object_name=object_name,
            expires=timedelta(seconds=expires_in),
        )
        return {
            "url": url,
            "method": "PUT",
            "expires_in": expires_in,
            "bucket": BUCKET,
            "object_name": object_name,
        }
    except Exception as e:
        print(f"Error generating upload URL: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/files/{object_name}/presigned-download")
def get_presigned_download_url(object_name: str, expires_in: int = 600):
    """
    Devuelve una URL pre-firmada para descargar un archivo directo desde MinIO.
    """
    try:
        url = client.presigned_get_object(
            bucket_name=BUCKET,
            object_name=object_name,
            expires=timedelta(seconds=expires_in),
        )
        return {
            "url": url,
            "method": "GET",
            "expires_in": expires_in,
            "bucket": BUCKET,
            "object_name": object_name,
        }
    except Exception as e:
        print(f"Error generating download URL: {e}")
        raise HTTPException(status_code=500, detail=str(e))






@app.get("/debug")
def debug():
    """Debug endpoint to check configuration and list files in bucket"""
    try:
        objects = client.list_objects(BUCKET)
        file_list = [obj.object_name for obj in objects]
        return {
            "bucket": BUCKET,
            "endpoint": os.getenv("MINIO_ENDPOINT"),
            "files": file_list,
            "count": len(file_list)
        }
    except Exception as e:
        return {
            "error": str(e),
            "bucket": BUCKET,
            "endpoint": os.getenv("MINIO_ENDPOINT")
        }