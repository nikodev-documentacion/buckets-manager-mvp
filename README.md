# buckets-man

API REST para gestión de archivos sobre MinIO. Permite subir, descargar y generar URLs pre-firmadas para acceso directo al bucket.

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
