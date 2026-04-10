CREATE SCHEMA IF NOT EXISTS "public";

-- Areas responsables
CREATE TABLE "area" (
    "id" uuid,
    -- Ej: RENTAS, BROMATO, OBRAS
    "codigo" varchar(50) NOT NULL UNIQUE,
    "nombre" varchar(100) NOT NULL,
    "email" varchar(255),
    "activo" bool NOT NULL DEFAULT true,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "pk_area_id" PRIMARY KEY ("id")
);
COMMENT ON TABLE "area" IS 'Areas responsables';
COMMENT ON COLUMN "area"."codigo" IS 'Ej: RENTAS, BROMATO, OBRAS';

-- Estados posibles del tramite
CREATE TABLE "estado_tramite" (
    "id" uuid,
    -- Ej: EN_PROCESO, CERRADO, CANCELADO
    "codigo" varchar(30) NOT NULL UNIQUE,
    "nombre" varchar(80) NOT NULL,
    "es_final" bool NOT NULL DEFAULT false,
    "es_cancelado" bool NOT NULL DEFAULT false,
    "activo" bool NOT NULL DEFAULT true,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "pk_estado_tramite_id" PRIMARY KEY ("id")
);
COMMENT ON TABLE "estado_tramite" IS 'Estados posibles del tramite';
COMMENT ON COLUMN "estado_tramite"."codigo" IS 'Ej: EN_PROCESO, CERRADO, CANCELADO';

-- Catalogo de tipos de tramite
CREATE TABLE "tipo_tramite" (
    "id" uuid,
    -- Ej: LIC_COMERCIAL, PATENTE, RECLAMO
    "codigo" varchar(50) NOT NULL UNIQUE,
    "nombre" varchar(100) NOT NULL,
    "descripcion" text,
    "activo" bool NOT NULL DEFAULT true,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "pk_tipo_tramite_id" PRIMARY KEY ("id")
);
COMMENT ON TABLE "tipo_tramite" IS 'Catalogo de tipos de tramite';
COMMENT ON COLUMN "tipo_tramite"."codigo" IS 'Ej: LIC_COMERCIAL, PATENTE, RECLAMO';

-- Tipos de evento
CREATE TABLE "tipo_evento" (
    "id" uuid,
    -- Ej: ARCHIVO_SUBIDO, RECHAZO, ENVIO_AREA
    "codigo" varchar(50) NOT NULL UNIQUE,
    "nombre" varchar(100) NOT NULL,
    "descripcion" text,
    "activo" bool NOT NULL DEFAULT true,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "pk_tipo_evento_id" PRIMARY KEY ("id")
);
COMMENT ON TABLE "tipo_evento" IS 'Tipos de evento';
COMMENT ON COLUMN "tipo_evento"."codigo" IS 'Ej: ARCHIVO_SUBIDO, RECHAZO, ENVIO_AREA';

-- Nodo generico de trazabilidad de tramites
CREATE TABLE "expediente" (
    "id" uuid,
    -- ID externo del dominio
    "entidad_id" uuid,
    "identificador" varchar,
    -- Referencia logica: COMERCIO, TCI, COMPRA, etc
    "entidad_ref" varchar(50) NOT NULL,
    "estado" expediente_estado NOT NULL DEFAULT 'ABIERTO',
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "pk_expediente_id" PRIMARY KEY ("id")
);
COMMENT ON TABLE "expediente" IS 'Nodo generico de trazabilidad de tramites';
COMMENT ON COLUMN "expediente"."entidad_id" IS 'ID externo del dominio';
COMMENT ON COLUMN "expediente"."entidad_ref" IS 'Referencia logica: COMERCIO, TCI, COMPRA, etc';

-- Etapas concretas del tramite
CREATE TABLE "tramite_etapa" (
    "id" uuid,
    "tramite_id" uuid NOT NULL,
    "etapa_definicion_id" uuid,
    "nombre_etapa" varchar(100) NOT NULL,
    "estado_etapa_id" uuid NOT NULL,
    "orden" int,
    "area_id" uuid,
    "fecha_inicio" timestamptz NOT NULL,
    "fecha_fin" timestamptz,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "pk_tramite_etapa_id" PRIMARY KEY ("id")
);
COMMENT ON TABLE "tramite_etapa" IS 'Etapas concretas del tramite';

-- Agregado principal: Tramite
CREATE TABLE "tramite" (
    "id" uuid,
    "expediente_id" uuid NOT NULL,
    "tipo_tramite_id" uuid NOT NULL,
    "estado_tramite_id" uuid NOT NULL,
    "responsable_id" uuid NOT NULL,
    "fecha_alta" timestamptz NOT NULL,
    "fecha_cierre" timestamptz,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "pk_tramite_id" PRIMARY KEY ("id")
);
COMMENT ON TABLE "tramite" IS 'Agregado principal: Tramite';

-- Eventos que ocurren en cada etapa
CREATE TABLE "tramite_evento" (
    "id" uuid,
    "etapa_id" uuid NOT NULL,
    "tipo_evento_id" uuid NOT NULL,
    "descripcion" text,
    "usuario_id" uuid NOT NULL,
    "metadata" jsonb,
    "fecha" timestamptz NOT NULL,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "area_id" uuid,
    CONSTRAINT "pk_tramite_evento_id" PRIMARY KEY ("id")
);
COMMENT ON TABLE "tramite_evento" IS 'Eventos que ocurren en cada etapa';

-- Estados posibles de una etapa
CREATE TABLE "estado_etapa" (
    "id" uuid,
    -- Ej: ABIERTA, EN_PROCESO, CERRADA
    "codigo" varchar(30) NOT NULL UNIQUE,
    "nombre" varchar(80) NOT NULL,
    "es_final" bool NOT NULL DEFAULT false,
    "activo" bool NOT NULL DEFAULT true,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "pk_estado_etapa_id" PRIMARY KEY ("id")
);
COMMENT ON TABLE "estado_etapa" IS 'Estados posibles de una etapa';
COMMENT ON COLUMN "estado_etapa"."codigo" IS 'Ej: ABIERTA, EN_PROCESO, CERRADA';

-- Archivos asociados a un evento
CREATE TABLE "tramite_archivo" (
    "id" uuid,
    "evento_id" uuid NOT NULL,
    "bucket" varchar(63) NOT NULL,
    "object_key" varchar(512) NOT NULL,
    "nombre_original" varchar(255) NOT NULL,
    "content_type" varchar(100),
    "size_bytes" bigint,
    "checksum" varchar(128),
    "uploaded_by" uuid,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "pk_tramite_archivo_id" PRIMARY KEY ("id")
);
COMMENT ON TABLE "tramite_archivo" IS 'Archivos asociados a un evento';

-- Nodo generico de trazabilidad de tramites
CREATE TABLE "expediente_referente" (
    "id" uuid,
    -- Referencia logica: COMERCIO, TCI, COMPRA, etc
    "expediente_ref" uuid NOT NULL,
    "referente_id" uuid NOT NULL,
    "rol" varchar,
    "activo" boolean,
    "fecha_desde" date,
    "fecha_hasta" date,
    "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamptz DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "pk_expediente_id" PRIMARY KEY ("id", "expediente_ref")
);
COMMENT ON TABLE "expediente_referente" IS 'Nodo generico de trazabilidad de tramites';
COMMENT ON COLUMN "expediente_referente"."expediente_ref" IS 'Referencia logica: COMERCIO, TCI, COMPRA, etc';

CREATE TABLE "public"."proceso_definicion" (
    "id" uuid NOT NULL,
    "tipo_tramite_id" uuid,
    "nombre" varchar,
    "activo" boolean,
    "created_at" timestamp,
    CONSTRAINT "pk_table_12_id" PRIMARY KEY ("id")
);

CREATE TABLE "public"."proceso_etapa_definicion" (
    "id" uuid NOT NULL,
    "proceso_id" uuid,
    "orden" int,
    "area_id" uuid,
    "paralela" boolean,
    "created_at" timestamp,
    CONSTRAINT "pk_table_13_id" PRIMARY KEY ("id")
);

-- Foreign key constraints
-- Schema: public
ALTER TABLE "tramite_etapa" ADD CONSTRAINT "fk_tramite_etapa_area_id_area_id" FOREIGN KEY("area_id") REFERENCES "area"("id");
ALTER TABLE "tramite_etapa" ADD CONSTRAINT "fk_tramite_etapa_estado_etapa_id_estado_etapa_id" FOREIGN KEY("estado_etapa_id") REFERENCES "estado_etapa"("id");
ALTER TABLE "tramite" ADD CONSTRAINT "fk_tramite_estado_tramite_id_estado_tramite_id" FOREIGN KEY("estado_tramite_id") REFERENCES "estado_tramite"("id");
ALTER TABLE "tramite" ADD CONSTRAINT "fk_tramite_expediente_id_expediente_id" FOREIGN KEY("expediente_id") REFERENCES "expediente"("id");
ALTER TABLE "tramite_evento" ADD CONSTRAINT "fk_tramite_evento_tipo_evento_id_tipo_evento_id" FOREIGN KEY("tipo_evento_id") REFERENCES "tipo_evento"("id");
ALTER TABLE "tipo_tramite" ADD CONSTRAINT "fk_tipo_tramite_id_tramite_tipo_tramite_id" FOREIGN KEY("id") REFERENCES "tramite"("tipo_tramite_id");
ALTER TABLE "tramite_evento" ADD CONSTRAINT "fk_tramite_evento_etapa_id_tramite_etapa_id" FOREIGN KEY("etapa_id") REFERENCES "tramite_etapa"("id");
ALTER TABLE "tramite_archivo" ADD CONSTRAINT "fk_tramite_archivo_evento_id_tramite_evento_id" FOREIGN KEY("evento_id") REFERENCES "tramite_evento"("id");
ALTER TABLE "tramite_etapa" ADD CONSTRAINT "fk_tramite_etapa_tramite_id_tramite_id" FOREIGN KEY("tramite_id") REFERENCES "tramite"("id");
ALTER TABLE "expediente_referente" ADD CONSTRAINT "fk_expediente_referente_expediente_ref_expediente_id" FOREIGN KEY("expediente_ref") REFERENCES "expediente"("id");
ALTER TABLE "tramite_evento" ADD CONSTRAINT "fk_tramite_evento_area_id_area_id" FOREIGN KEY("area_id") REFERENCES "area"("id");
ALTER TABLE "tipo_tramite" ADD CONSTRAINT "fk_tipo_tramite_id_proceso_definicion_id" FOREIGN KEY("id") REFERENCES "public"."proceso_definicion"("id");
ALTER TABLE "public"."proceso_etapa_definicion" ADD CONSTRAINT "fk_proceso_etapa_definicion_id_proceso_definicion_id" FOREIGN KEY("id") REFERENCES "public"."proceso_definicion"("id");
ALTER TABLE "public"."proceso_etapa_definicion" ADD CONSTRAINT "fk_proceso_etapa_definicion_area_id_area_id" FOREIGN KEY("area_id") REFERENCES "area"("id");