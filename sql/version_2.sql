//////////////////////////////////////////////////////
// CATÁLOGOS
//////////////////////////////////////////////////////

Table tipo_tramite {
  id          uuid      [pk]
  codigo      varchar(50) [not null, unique, note: 'Ej: LIC_COMERCIAL, PATENTE, RECLAMO']
  nombre      varchar(100) [not null]
  descripcion text
  activo      bool       [not null, default: true]

  created_at  timestamptz [default: `now()`]
  updated_at  timestamptz [default: `now()`]

  Note: 'Catálogo de tipos de trámite'
}

Table estado_tramite {
  id           uuid      [pk]
  codigo       varchar(30) [not null, unique, note: 'Ej: EN_PROCESO, CERRADO, CANCELADO']
  nombre       varchar(80) [not null]
  es_final     bool        [not null, default: false]
  es_cancelado bool        [not null, default: false]
  activo       bool        [not null, default: true]

  created_at   timestamptz [default: `now()`]
  updated_at   timestamptz [default: `now()`]

  Note: 'Estados posibles del trámite'
}

Table estado_etapa {
  id        uuid      [pk]
  codigo    varchar(30) [not null, unique, note: 'Ej: ABIERTA, EN_PROCESO, CERRADA']
  nombre    varchar(80) [not null]
  es_final  bool        [not null, default: false]
  activo    bool        [not null, default: true]

  created_at  timestamptz [default: `now()`]
  updated_at  timestamptz [default: `now()`]

  Note: 'Estados posibles de una etapa'
}

Table tipo_evento {
  id          uuid      [pk]
  codigo      varchar(50) [not null, unique, note: 'Ej: ARCHIVO_SUBIDO, RECHAZO, ENVIO_AREA']
  nombre      varchar(100) [not null]
  descripcion text
  activo      bool        [not null, default: true]

  created_at  timestamptz [default: `now()`]
  updated_at  timestamptz [default: `now()`]

  Note: 'Tipos de evento'
}

Table area {
  id        uuid      [pk]
  codigo    varchar(50) [not null, unique, note: 'Ej: RENTAS, BROMATO, OBRAS']
  nombre    varchar(100) [not null]
  email     varchar(255)
  activo    bool        [not null, default: true]

  created_at timestamptz [default: `now()`]
  updated_at timestamptz [default: `now()`]

  Note: 'Áreas responsables'
}

Table etapa_definicion {
  id               uuid      [pk]
  tipo_tramite_id  uuid      [not null, ref: > tipo_tramite.id]
  codigo           varchar(50) [not null]
  nombre           varchar(100) [not null]
  orden            int        [not null]
  area_id          uuid       [ref: > area.id]
  estado_inicial_id uuid      [ref: > estado_etapa.id]
  estado_final_id  uuid       [ref: > estado_etapa.id]
  activo           bool       [not null, default: true]

  created_at       timestamptz [default: `now()`]
  updated_at       timestamptz [default: `now()`]

  Note: 'Definición de etapas por tipo de trámite'
}

//////////////////////////////////////////////////////
// ENTIDADES DE NEGOCIO
//////////////////////////////////////////////////////

Table tramite {
  id                 uuid      [pk]
  tipo_tramite_id    uuid      [not null, ref: > tipo_tramite.id]
  estado_tramite_id  uuid      [not null, ref: > estado_tramite.id]
  titular_id         uuid      [not null]
  fecha_alta         timestamptz [not null]
  fecha_cierre       timestamptz

  created_at         timestamptz [default: `now()`]
  updated_at         timestamptz [default: `now()`]

  Note: 'Agregado principal: Trámite'
}

Table tramite_etapa {
  id                  uuid      [pk]
  tramite_id          uuid      [not null, ref: > tramite.id]
  etapa_definicion_id uuid      [ref: > etapa_definicion.id]
  nombre_etapa        varchar(100) [not null]
  estado_etapa_id     uuid      [not null, ref: > estado_etapa.id]
  orden               int
  area_id             uuid      [ref: > area.id]
  fecha_inicio        timestamptz [not null]
  fecha_fin           timestamptz

  created_at          timestamptz [default: `now()`]
  updated_at          timestamptz [default: `now()`]

  Note: 'Etapas concretas del trámite'
}

Table tramite_evento {
  id            uuid      [pk]
  etapa_id      uuid      [not null, ref: > tramite_etapa.id]
  tipo_evento_id uuid     [not null, ref: > tipo_evento.id]
  descripcion   text
  usuario_id    uuid      [not null]
  metadata      jsonb
  fecha         timestamptz [not null]

  created_at    timestamptz [default: `now()`]
  updated_at    timestamptz [default: `now()`]

  Note: 'Eventos que ocurren en cada etapa'
}

Table tramite_archivo {
  id               uuid         [pk]
  evento_id        uuid         [not null, ref: > tramite_evento.id]
  bucket           varchar(63)  [not null]
  object_key       varchar(512) [not null]
  nombre_original  varchar(255) [not null]
  content_type     varchar(100)
  size_bytes       bigint
  checksum         varchar(128)
  uploaded_by      uuid
  created_at       timestamptz [default: `now()`]

  Note: 'Archivos asociados a un evento'
}
