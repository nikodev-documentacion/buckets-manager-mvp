Table tramite {
  id              uuid        [pk]
  tipo            varchar(50) [not null]
  estado_actual   varchar(30) [not null]
  titular_id      uuid        [not null]
  fecha_alta      timestamptz [not null]
  fecha_cierre    timestamptz

  created_at      timestamptz [default: `now()`]
  updated_at      timestamptz [default: `now()`]

  Note: 'Agregado raíz: Trámite'
}

Table tramite_etapa {
  id               uuid        [pk]
  tramite_id       uuid        [not null, ref: > tramite.id]
  nombre_etapa     varchar(50) [not null]
  estado_etapa     varchar(30) [not null]
  orden            int         [note: 'Posición en el flujo (1,2,3...)']
  responsable_area varchar(80)
  fecha_inicio     timestamptz [not null]
  fecha_fin        timestamptz

  created_at       timestamptz [default: `now()`]
  updated_at       timestamptz [default: `now()`]

  Note: 'Etapas del trámite (stages)'
}

Table tramite_evento {
  id           uuid        [pk]
  etapa_id     uuid        [not null, ref: > tramite_etapa.id]
  tipo_evento  varchar(50) [not null]
  descripcion  text
  usuario_id   uuid        [not null]
  metadata     jsonb
  fecha        timestamptz [not null]

  created_at   timestamptz [default: `now()`]
  updated_at   timestamptz [default: `now()`]

  Note: 'Eventos dentro de una etapa'
}

Table tramite_archivo {
  id               uuid         [pk]
  evento_id        uuid         [not null, ref: > tramite_evento.id]
  bucket           varchar(63)  [not null, note: 'Nombre del bucket en MinIO']
  object_key       varchar(512) [not null, note: 'Key completa del objeto en MinIO']
  nombre_original  varchar(255) [not null, note: 'Nombre de archivo que subió el usuario']
  content_type     varchar(100)
  size_bytes       bigint
  checksum         varchar(128) [note: 'Opcional: hash (md5/sha256)']
  uploaded_by      uuid         [note: 'Usuario que subió el archivo']
  created_at       timestamptz  [default: `now()`]

  Note: 'Archivos en object storage asociados a eventos'
}
