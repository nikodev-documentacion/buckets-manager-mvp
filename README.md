# buckets-man

FastAPI microservice que actúa como proxy/gateway para MinIO (object storage).

## Cómo funciona

**Config** — carga vars de entorno (`.env`) y un cliente MinIO singleton desde `src/minio_client.py`.

**Endpoints:**

- `GET /files/{object_name}` — descarga un archivo de MinIO y lo devuelve como proxy
- `POST /upload` — recibe un archivo y lo sube a MinIO
- `POST /upload-multiple` — igual pero con varios archivos a la vez
- `POST /files/presigned-upload` — genera una URL firmada para que el cliente suba directo a MinIO (sin pasar por el backend)
- `POST /files/presigned-upload-multiple` — lo mismo para múltiples archivos
- `GET /files/{object_name}/presigned-download` — URL firmada para descarga directa desde MinIO
- `GET /debug` — lista el contenido del bucket y muestra la config

## Requisitos

- Python 3.12+
- Instancia de MinIO accesible

## Instalación

```bash
pip install -e .
```

Configurar variables de entorno en `.env`:

```env
MINIO_ENDPOINT=your-minio-host
MINIO_ACCESS_KEY=your-access-key
MINIO_SECRET_KEY=your-secret-key
MINIO_SECURE=true
MINIO_BUCKET=your-bucket
```

## Ejecución

```bash
uvicorn src.app:app --reload
```

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| `GET` | `/files/{object_name}` | Descarga un archivo desde el bucket (proxy) |
| `POST` | `/upload` | Sube un archivo al bucket (proxy) |
| `POST` | `/upload-multiple` | Sube múltiples archivos al bucket (proxy) |
| `POST` | `/files/presigned-upload` | Genera una URL pre-firmada para subida directa (`PUT`) |
| `POST` | `/files/presigned-upload-multiple` | Genera múltiples URLs pre-firmadas para subida directa |
| `GET` | `/files/{object_name}/presigned-download` | Genera una URL pre-firmada para descarga directa (`GET`) |
| `GET` | `/debug` | Muestra configuración y lista los archivos del bucket |

### Subida directa (presigned)

Las URLs pre-firmadas permiten que el cliente suba o descargue archivos **directamente a MinIO** sin pasar por el backend.

**Subida simple** — `POST /files/presigned-upload`
```
?object_name=foto.png&expires_in=600
```

**Subida múltiple** — `POST /files/presigned-upload-multiple`
```json
{
  "object_names": ["foto.png", "doc.pdf"],
  "expires_in": 600
}
```

La expiración por defecto es de **600 segundos (10 minutos)**.

## Ventaja principal

El diseño con URLs pre-firmadas evita que los archivos pasen por el backend: el cliente sube o descarga **directo a MinIO**, lo que elimina el cuello de botella del servidor, reduce latencia y no consume memoria ni ancho de banda del proceso Python. El backend solo interviene para autenticar y emitir la URL; el trabajo pesado lo hace MinIO directamente.
