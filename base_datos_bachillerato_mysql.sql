-- ============================================================
-- BASE DE DATOS ACADÉMICA - BACHILLERATO
-- Versión MySQL 8.0+
-- Diseñada para poder agregar/modificar información posteriormente
-- ============================================================

CREATE DATABASE IF NOT EXISTS bachillerato
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bachillerato;

-- ============================================================
-- 1. ROLES
-- ============================================================
CREATE TABLE roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(200),
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

INSERT INTO roles (id_rol, nombre, descripcion) VALUES
(1, 'Superusuario', 'Acceso completo al sistema'),
(2, 'Administrador', 'Administración académica y usuarios'),
(3, 'Docente', 'Gestión de grupos, evaluaciones y calificaciones'),
(4, 'Alumno', 'Consulta de materias y calificaciones');

-- ============================================================
-- 2. CARRERAS
-- ============================================================
CREATE TABLE carreras (
    id_carrera INT AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

INSERT INTO carreras (id_carrera, clave, nombre) VALUES
(1, 'ISC', 'Ingeniería en Sistemas Computacionales'),
(2, 'CONT', 'Contaduría y Finanzas'),
(3, 'ADM', 'Administración de PyMEs');

-- ============================================================
-- 3. ESPECIALIDADES
-- ============================================================
CREATE TABLE especialidades (
    id_especialidad INT AUTO_INCREMENT PRIMARY KEY,
    id_carrera INT NOT NULL,
    clave VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE KEY uq_especialidad_carrera_nombre (id_carrera, nombre),
    CONSTRAINT fk_especialidad_carrera
        FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera)
) ENGINE=InnoDB;

INSERT INTO especialidades (id_especialidad, id_carrera, clave, nombre) VALUES
(1, 1, 'ISC-2010-224', 'Ciencia de Datos');

-- ============================================================
-- 4. PERIODOS ESCOLARES
-- ============================================================
CREATE TABLE periodos_escolares (
    id_periodo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    fecha_inicio DATE,
    fecha_fin DATE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (fecha_fin IS NULL OR fecha_inicio IS NULL OR fecha_fin >= fecha_inicio)
) ENGINE=InnoDB;

INSERT INTO periodos_escolares
(id_periodo, nombre, fecha_inicio, fecha_fin, activo)
VALUES
(1, '2026-2027', '2026-08-01', '2027-07-31', TRUE);

-- ============================================================
-- 5. MATERIAS
-- id_especialidad NULL = tronco común
-- ============================================================
CREATE TABLE materias (
    id_materia INT AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    creditos DECIMAL(4,1) NOT NULL DEFAULT 0,
    semestre INT NOT NULL,
    id_especialidad INT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (creditos >= 0),
    CHECK (semestre BETWEEN 1 AND 12),
    CONSTRAINT fk_materia_especialidad
        FOREIGN KEY (id_especialidad)
        REFERENCES especialidades(id_especialidad)
        ON DELETE SET NULL
) ENGINE=InnoDB;

INSERT INTO materias (clave, nombre, creditos, semestre, id_especialidad) VALUES
('ACF0903', 'ÁLGEBRA LINEAL', 5, 1, NULL),
('ACF0901', 'CÁLCULO DIFERENCIAL', 5, 1, NULL),
('AEC1008', 'CONTABILIDAD FINANCIERA', 4, 1, NULL),
('SCD1008', 'FUNDAMENTOS DE PROGRAMACIÓN', 5, 1, NULL),
('AEF1041', 'MATEMÁTICAS DISCRETAS', 5, 1, NULL),
('AEF1052', 'PROBABILIDAD Y ESTADÍSTICA', 5, 1, NULL),
('SCH1024', 'TALLER DE ADMINISTRACIÓN', 4, 1, NULL),
('ACF0902', 'CÁLCULO INTEGRAL', 5, 2, NULL),
('ACD0908', 'DESARROLLO SUSTENTABLE', 5, 2, NULL),
('SCF1006', 'FÍSICA GENERAL', 5, 2, NULL),
('SCC1013', 'INVESTIGACIÓN DE OPERACIONES', 4, 2, NULL),
('RED-001', 'REDES DE COMPUTADORA', 5, 5, 1),
('WEB-001', 'PROGRAMACIÓN WEB', 5, 5, 1),
('PLF-001', 'PROGRAMACIÓN LÓGICA Y FUNCIONAL', 4, 5, 1),
('MIN-001', 'MINERÍA DE DATOS', 5, 5, 1),
('TD-001', 'TOMA DE DECISIONES', 4, 5, 1),
('TUT-V', 'TUTORÍAS V', 0, 5, 1);

-- ============================================================
-- 6. USUARIOS
-- ============================================================
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    correo_institucional VARCHAR(150) NOT NULL UNIQUE,
    nombre_usuario VARCHAR(80) UNIQUE,
    contrasena_hash TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
) ENGINE=InnoDB;

-- ============================================================
-- 7. ALUMNOS
-- ============================================================
CREATE TABLE alumnos (
    id_alumno INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    numero_control VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL,
    apellido_paterno VARCHAR(80) NOT NULL,
    apellido_materno VARCHAR(80),
    curp VARCHAR(18) UNIQUE,
    nss VARCHAR(20),
    fecha_nacimiento DATE,
    genero VARCHAR(30),
    id_carrera INT,
    id_especialidad INT,
    semestre_actual INT,
    promedio_general DECIMAL(5,2),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (semestre_actual IS NULL OR semestre_actual BETWEEN 1 AND 12),
    CHECK (promedio_general IS NULL OR promedio_general BETWEEN 0 AND 100),
    CONSTRAINT fk_alumno_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_alumno_carrera
        FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera),
    CONSTRAINT fk_alumno_especialidad
        FOREIGN KEY (id_especialidad) REFERENCES especialidades(id_especialidad)
) ENGINE=InnoDB;

-- ============================================================
-- 8. DOCENTES
-- ============================================================
CREATE TABLE docentes (
    id_docente INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT UNIQUE,
    numero_empleado VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL,
    apellido_paterno VARCHAR(80) NOT NULL,
    apellido_materno VARCHAR(80),
    correo_institucional VARCHAR(150) NOT NULL UNIQUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_docente_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- 9. GRUPOS
-- ============================================================
CREATE TABLE grupos (
    id_grupo INT AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(30) NOT NULL,
    nombre VARCHAR(100),
    id_periodo INT NOT NULL,
    id_carrera INT,
    id_especialidad INT,
    semestre INT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE KEY uq_grupo_periodo (clave, id_periodo),
    CHECK (semestre BETWEEN 1 AND 12),
    CONSTRAINT fk_grupo_periodo
        FOREIGN KEY (id_periodo) REFERENCES periodos_escolares(id_periodo),
    CONSTRAINT fk_grupo_carrera
        FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera),
    CONSTRAINT fk_grupo_especialidad
        FOREIGN KEY (id_especialidad) REFERENCES especialidades(id_especialidad)
) ENGINE=InnoDB;

INSERT INTO grupos
(clave, nombre, id_periodo, id_carrera, id_especialidad, semestre)
VALUES
('05A', 'Grupo 05A - Ciencia de Datos', 1, 1, 1, 5);

-- ============================================================
-- 10. ASIGNACIÓN DE MATERIAS A GRUPOS
-- ============================================================
CREATE TABLE grupo_materias (
    id_grupo_materia INT AUTO_INCREMENT PRIMARY KEY,
    id_grupo INT NOT NULL,
    id_materia INT NOT NULL,
    id_docente INT NULL,
    horario VARCHAR(150),
    aula VARCHAR(50),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE KEY uq_grupo_materia (id_grupo, id_materia),
    CONSTRAINT fk_gm_grupo
        FOREIGN KEY (id_grupo) REFERENCES grupos(id_grupo)
        ON DELETE CASCADE,
    CONSTRAINT fk_gm_materia
        FOREIGN KEY (id_materia) REFERENCES materias(id_materia),
    CONSTRAINT fk_gm_docente
        FOREIGN KEY (id_docente) REFERENCES docentes(id_docente)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- 11. INSCRIPCIONES
-- ============================================================
CREATE TABLE inscripciones (
    id_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
    id_alumno INT NOT NULL,
    id_grupo INT NOT NULL,
    fecha_inscripcion DATE DEFAULT (CURRENT_DATE),
    estado VARCHAR(30) NOT NULL DEFAULT 'ACTIVA',
    UNIQUE KEY uq_alumno_grupo (id_alumno, id_grupo),
    CHECK (estado IN ('ACTIVA', 'BAJA', 'FINALIZADA')),
    CONSTRAINT fk_inscripcion_alumno
        FOREIGN KEY (id_alumno) REFERENCES alumnos(id_alumno)
        ON DELETE CASCADE,
    CONSTRAINT fk_inscripcion_grupo
        FOREIGN KEY (id_grupo) REFERENCES grupos(id_grupo)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 12. CRITERIOS DE EVALUACIÓN
-- ============================================================
CREATE TABLE criterios_evaluacion (
    id_criterio INT AUTO_INCREMENT PRIMARY KEY,
    id_grupo_materia INT NOT NULL,
    numero_evaluacion INT NOT NULL,
    unidades VARCHAR(100),
    fecha_limite DATE,
    porcentaje_examen DECIMAL(5,2) NOT NULL DEFAULT 0,
    porcentaje_actividades DECIMAL(5,2) NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE KEY uq_evaluacion_grupo_materia
        (id_grupo_materia, numero_evaluacion),
    CHECK (numero_evaluacion > 0),
    CHECK (porcentaje_examen >= 0 AND porcentaje_actividades >= 0),
    CHECK (porcentaje_examen + porcentaje_actividades = 100),
    CONSTRAINT fk_criterio_gm
        FOREIGN KEY (id_grupo_materia)
        REFERENCES grupo_materias(id_grupo_materia)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 13. CALIFICACIONES POR EVALUACIÓN
-- ============================================================
CREATE TABLE calificaciones (
    id_calificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_inscripcion INT NOT NULL,
    id_criterio INT NOT NULL,
    calificacion_examen DECIMAL(5,2),
    calificacion_actividades DECIMAL(5,2),
    calificacion_final DECIMAL(5,2),
    estatus VARCHAR(30) NOT NULL DEFAULT 'ORDINARIO',
    observaciones VARCHAR(255),
    UNIQUE KEY uq_calificacion_inscripcion_criterio
        (id_inscripcion, id_criterio),
    CHECK (calificacion_examen IS NULL OR
           calificacion_examen BETWEEN 0 AND 100),
    CHECK (calificacion_actividades IS NULL OR
           calificacion_actividades BETWEEN 0 AND 100),
    CHECK (calificacion_final IS NULL OR
           calificacion_final BETWEEN 0 AND 100),
    CHECK (estatus IN ('ORDINARIO', 'N.R.', 'N.A.', 'EXTRAORDINARIO')),
    CONSTRAINT fk_calificacion_inscripcion
        FOREIGN KEY (id_inscripcion)
        REFERENCES inscripciones(id_inscripcion)
        ON DELETE CASCADE,
    CONSTRAINT fk_calificacion_criterio
        FOREIGN KEY (id_criterio)
        REFERENCES criterios_evaluacion(id_criterio)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 14. DETALLE DE CALIFICACIONES POR UNIDAD
-- ============================================================
CREATE TABLE calificaciones_detalle (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_calificacion INT NOT NULL,
    unidad INT NOT NULL,
    examen_obtenido DECIMAL(5,2),
    examen_maximo DECIMAL(5,2),
    actividades_obtenido DECIMAL(5,2),
    actividades_maximo DECIMAL(5,2),
    total DECIMAL(5,2),
    estatus VARCHAR(30) NOT NULL DEFAULT 'ORDINARIO',
    observaciones VARCHAR(255),
    UNIQUE KEY uq_calificacion_unidad (id_calificacion, unidad),
    CHECK (unidad > 0),
    CHECK (examen_obtenido IS NULL OR examen_obtenido >= 0),
    CHECK (examen_maximo IS NULL OR examen_maximo >= 0),
    CHECK (actividades_obtenido IS NULL OR actividades_obtenido >= 0),
    CHECK (actividades_maximo IS NULL OR actividades_maximo >= 0),
    CHECK (total IS NULL OR total BETWEEN 0 AND 100),
    CHECK (estatus IN ('ORDINARIO', 'N.R.', 'N.A.', 'EXTRAORDINARIO')),
    CONSTRAINT fk_detalle_calificacion
        FOREIGN KEY (id_calificacion)
        REFERENCES calificaciones(id_calificacion)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 15. DATOS DE PRUEBA
-- ============================================================

-- Usuario de Ximena
INSERT INTO usuarios
(id_usuario, id_rol, correo_institucional, nombre_usuario)
VALUES
(1, 4, '237003460@itsx.edu.mx', '237003460');

-- Alumna Ximena
INSERT INTO alumnos (
    id_alumno, id_usuario, numero_control, nombre,
    apellido_paterno, apellido_materno, curp, nss,
    fecha_nacimiento, genero, id_carrera, id_especialidad,
    semestre_actual, promedio_general
)
VALUES (
    1, 1, '237003460', 'XIMENA', 'HIDALGO', 'LOZANO',
    'HILX031208MTSDZMA2', '02210306920',
    '2003-12-08', 'Femenino', 1, 1, 8, 82.55
);

-- Usuario de docente
INSERT INTO usuarios
(id_usuario, id_rol, correo_institucional, nombre_usuario)
VALUES
(2, 3, 'manuel.ralero@itsx.edu.mx', 'DOC-1092');

-- Docente
INSERT INTO docentes (
    id_docente, id_usuario, numero_empleado, nombre,
    apellido_paterno, apellido_materno, correo_institucional
)
VALUES (
    1, 2, 'DOC-1092', 'MANUEL',
    'RALERO DE LA MORA', 'PRISCILIANO',
    'manuel.ralero@itsx.edu.mx'
);

-- ============================================================
-- 16. ASIGNAR REDES DE COMPUTADORA AL GRUPO 05A
-- ============================================================
INSERT INTO grupo_materias (
    id_grupo_materia, id_grupo, id_materia, id_docente
)
SELECT
    1,
    g.id_grupo,
    m.id_materia,
    1
FROM grupos g
CROSS JOIN materias m
WHERE g.clave = '05A'
  AND m.clave = 'RED-001';

-- ============================================================
-- 17. INSCRIBIR A XIMENA
-- ============================================================
INSERT INTO inscripciones
(id_inscripcion, id_alumno, id_grupo, estado)
VALUES
(1, 1, 1, 'ACTIVA');

-- ============================================================
-- 18. CRITERIOS DE EVALUACIÓN
-- ============================================================
INSERT INTO criterios_evaluacion (
    id_criterio, id_grupo_materia, numero_evaluacion,
    unidades, fecha_limite, porcentaje_examen,
    porcentaje_actividades
)
VALUES
(1, 1, 1, 'Unidades 1 y 2', '2026-09-27', 30, 70),
(2, 1, 2, 'Unidades 3 y 4', '2026-10-25', 30, 70),
(3, 1, 3, 'Unidad 5', '2026-12-06', 30, 70);

-- ============================================================
-- 19. CALIFICACIÓN DE XIMENA
-- ============================================================
INSERT INTO calificaciones (
    id_calificacion, id_inscripcion, id_criterio,
    calificacion_examen, calificacion_actividades,
    calificacion_final, estatus
)
VALUES
(1, 1, 1, 30, 52, 82, 'ORDINARIO');

-- ============================================================
-- 20. DETALLE DE UNIDADES
-- ============================================================
INSERT INTO calificaciones_detalle (
    id_calificacion, unidad, examen_obtenido,
    examen_maximo, actividades_obtenido,
    actividades_maximo, total, estatus
)
VALUES
(1, 1, 30, 30, 52, 70, 82, 'ORDINARIO'),
(1, 2, NULL, NULL, NULL, NULL, NULL, 'N.R.'),
(1, 3, NULL, NULL, NULL, NULL, NULL, 'N.R.');

-- ============================================================
-- 21. VISTAS PARA EL FUTURO FRONTEND/BACKEND
-- ============================================================

CREATE OR REPLACE VIEW vista_alumnos AS
SELECT
    a.id_alumno,
    a.numero_control,
    CONCAT_WS(' ', a.nombre, a.apellido_paterno, a.apellido_materno)
        AS nombre_completo,
    u.correo_institucional,
    c.nombre AS carrera,
    e.nombre AS especialidad,
    a.semestre_actual,
    a.promedio_general,
    a.activo
FROM alumnos a
JOIN usuarios u ON u.id_usuario = a.id_usuario
LEFT JOIN carreras c ON c.id_carrera = a.id_carrera
LEFT JOIN especialidades e ON e.id_especialidad = a.id_especialidad;

CREATE OR REPLACE VIEW vista_docentes AS
SELECT
    d.id_docente,
    d.numero_empleado,
    CONCAT_WS(' ', d.nombre, d.apellido_paterno, d.apellido_materno)
        AS nombre_completo,
    d.correo_institucional,
    d.activo
FROM docentes d;

CREATE OR REPLACE VIEW vista_materias_grupos AS
SELECT
    gm.id_grupo_materia,
    g.clave AS grupo,
    p.nombre AS periodo,
    m.clave AS clave_materia,
    m.nombre AS materia,
    m.creditos,
    m.semestre,
    d.numero_empleado,
    CASE
        WHEN d.id_docente IS NULL THEN NULL
        ELSE CONCAT_WS(' ', d.nombre, d.apellido_paterno, d.apellido_materno)
    END AS docente
FROM grupo_materias gm
JOIN grupos g ON g.id_grupo = gm.id_grupo
JOIN periodos_escolares p ON p.id_periodo = g.id_periodo
JOIN materias m ON m.id_materia = gm.id_materia
LEFT JOIN docentes d ON d.id_docente = gm.id_docente;

CREATE OR REPLACE VIEW vista_calificaciones_alumnos AS
SELECT
    a.numero_control,
    CONCAT_WS(' ', a.nombre, a.apellido_paterno, a.apellido_materno)
        AS alumno,
    g.clave AS grupo,
    m.nombre AS materia,
    ce.numero_evaluacion,
    ce.unidades,
    ce.fecha_limite,
    cal.calificacion_examen,
    cal.calificacion_actividades,
    cal.calificacion_final,
    cal.estatus
FROM calificaciones cal
JOIN inscripciones i ON i.id_inscripcion = cal.id_inscripcion
JOIN alumnos a ON a.id_alumno = i.id_alumno
JOIN criterios_evaluacion ce ON ce.id_criterio = cal.id_criterio
JOIN grupo_materias gm ON gm.id_grupo_materia = ce.id_grupo_materia
JOIN grupos g ON g.id_grupo = gm.id_grupo
JOIN materias m ON m.id_materia = gm.id_materia;

-- ============================================================
-- 22. EJEMPLOS PARA FUTURAS MODIFICACIONES
-- ============================================================

-- Agregar alumno:
-- INSERT INTO usuarios (id_rol, correo_institucional, nombre_usuario)
-- VALUES (4, 'nuevo@itsx.edu.mx', 'NUEVO_CONTROL');

-- Agregar materia:
-- INSERT INTO materias
-- (clave, nombre, creditos, semestre, id_especialidad)
-- VALUES ('NUEVA-001', 'NUEVA MATERIA', 5, 6, 1);

-- Agregar especialidad:
-- INSERT INTO especialidades (id_carrera, clave, nombre)
-- VALUES (1, 'NUEVA-ESP', 'Nueva especialidad');

-- Modificar promedio:
-- UPDATE alumnos
-- SET promedio_general = 90.00
-- WHERE numero_control = '237003460';

-- Consultar alumnos:
-- SELECT * FROM vista_alumnos;

-- Consultar materias y docentes:
-- SELECT * FROM vista_materias_grupos;

-- Consultar calificaciones:
-- SELECT * FROM vista_calificaciones_alumnos;

-- ============================================================
-- FIN
-- ============================================================
