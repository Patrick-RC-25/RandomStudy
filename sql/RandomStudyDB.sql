CREATE DATABASE RandomStudyDB;
GO
USE RandomStudyDB;
GO

/* Script completo proporcionado para CarlitoApp / RandomStudyDB */
/* Ejecutar en SSMS de una vez o por lotes según GO */

CREATE TABLE dbo.TipoEvaluacion
(
    idTipoEvaluacion  TINYINT IDENTITY(1,1) NOT NULL,
    nombre            NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_TipoEvaluacion PRIMARY KEY (idTipoEvaluacion),
    CONSTRAINT UQ_TipoEvaluacion_nombre UNIQUE (nombre)
);

CREATE TABLE dbo.TipoAlerta
(
    idTipoAlerta TINYINT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_TipoAlerta PRIMARY KEY (idTipoAlerta),
    CONSTRAINT UQ_TipoAlerta_nombre UNIQUE (nombre)
);

INSERT INTO dbo.TipoEvaluacion (nombre) VALUES
(N'Examen'), (N'Parcial'), (N'Práctica'), (N'Trabajo'), (N'Proyecto'), (N'Otros');

INSERT INTO dbo.TipoAlerta (nombre) VALUES
(N'recordatorio'), (N'vencimiento'), (N'rendimiento'), (N'sistema');
GO

CREATE TABLE dbo.Usuario
(
    idUsuario       INT IDENTITY(1,1) NOT NULL,
    email           VARCHAR(100) NOT NULL,
    contrasena      VARCHAR(255) NOT NULL,
    fechaRegistro   DATETIME2(0) NOT NULL
        CONSTRAINT DF_Usuario_fechaRegistro DEFAULT (SYSDATETIME()),
    fechaUltimoLogin DATETIME2(0) NULL,
    estado          BIT NOT NULL
        CONSTRAINT DF_Usuario_estado DEFAULT (1),
    CONSTRAINT PK_Usuario PRIMARY KEY (idUsuario),
    CONSTRAINT UQ_Usuario_email UNIQUE (email)
);
GO

CREATE TABLE dbo.PerfilUsuario
(
    idPerfil        INT IDENTITY(1,1) NOT NULL,
    idUsuario       INT NOT NULL,
    nombres         NVARCHAR(100) NOT NULL,
    apellidos       NVARCHAR(100) NOT NULL,
    universidad     NVARCHAR(150) NULL,
    carrera         NVARCHAR(150) NULL,
    ciclo           NVARCHAR(30) NULL,
    fotoUrl         NVARCHAR(300) NULL,
    fechaCreacion   DATETIME2(0) NOT NULL
        CONSTRAINT DF_PerfilUsuario_fechaCreacion DEFAULT (SYSDATETIME()),
    fechaModificacion DATETIME2(0) NULL,
    CONSTRAINT PK_PerfilUsuario PRIMARY KEY (idPerfil),
    CONSTRAINT UQ_PerfilUsuario_idUsuario UNIQUE (idUsuario),
    CONSTRAINT FK_PerfilUsuario_Usuario
        FOREIGN KEY (idUsuario) REFERENCES dbo.Usuario(idUsuario)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

CREATE TABLE dbo.PeriodoAcademico
(
    idPeriodo       INT IDENTITY(1,1) NOT NULL,
    idUsuario       INT NOT NULL,
    nombre          NVARCHAR(100) NOT NULL,
    fechaInicio     DATE NOT NULL,
    fechaFin        DATE NOT NULL,
    estado          VARCHAR(20) NOT NULL
        CONSTRAINT DF_PeriodoAcademico_estado DEFAULT ('activo'),
    fechaCreacion   DATETIME2(0) NOT NULL
        CONSTRAINT DF_PeriodoAcademico_fechaCreacion DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_PeriodoAcademico PRIMARY KEY (idPeriodo),
    CONSTRAINT FK_PeriodoAcademico_Usuario
        FOREIGN KEY (idUsuario) REFERENCES dbo.Usuario(idUsuario)
        ON DELETE CASCADE,
    CONSTRAINT UQ_PeriodoAcademico_Usuario_Nombre UNIQUE (idUsuario, nombre),
    CONSTRAINT CK_PeriodoAcademico_Fechas CHECK (fechaFin >= fechaInicio),
    CONSTRAINT CK_PeriodoAcademico_Estado
        CHECK (estado IN ('activo', 'finalizado', 'planificado'))
);
GO

CREATE TABLE dbo.Curso
(
    idCurso         INT IDENTITY(1,1) NOT NULL,
    idPeriodo       INT NOT NULL,
    nombre          NVARCHAR(120) NOT NULL,
    codigo          VARCHAR(30) NULL,
    docente         NVARCHAR(120) NULL,
    creditos        TINYINT NULL,
    color           VARCHAR(20) NULL,
    notaObjetivo    DECIMAL(5,2) NULL,
    estado          BIT NOT NULL
        CONSTRAINT DF_Curso_estado DEFAULT (1),
    fechaCreacion   DATETIME2(0) NOT NULL
        CONSTRAINT DF_Curso_fechaCreacion DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_Curso PRIMARY KEY (idCurso),
    CONSTRAINT FK_Curso_PeriodoAcademico
        FOREIGN KEY (idPeriodo) REFERENCES dbo.PeriodoAcademico(idPeriodo)
        ON DELETE CASCADE,
    CONSTRAINT CK_Curso_Creditos CHECK (creditos IS NULL OR creditos > 0),
    CONSTRAINT CK_Curso_NotaObjetivo
        CHECK (notaObjetivo IS NULL OR (notaObjetivo >= 0 AND notaObjetivo <= 20))
);
GO

CREATE TABLE dbo.HorarioCurso
(
    idHorario       INT IDENTITY(1,1) NOT NULL,
    idCurso         INT NOT NULL,
    diaSemana       TINYINT NOT NULL,
    horaInicio      TIME(0) NOT NULL,
    horaFin         TIME(0) NOT NULL,
    aula            NVARCHAR(50) NULL,
    CONSTRAINT PK_HorarioCurso PRIMARY KEY (idHorario),
    CONSTRAINT FK_HorarioCurso_Curso
        FOREIGN KEY (idCurso) REFERENCES dbo.Curso(idCurso)
        ON DELETE CASCADE,
    CONSTRAINT CK_HorarioCurso_Dia CHECK (diaSemana BETWEEN 1 AND 7),
    CONSTRAINT CK_HorarioCurso_Horas CHECK (horaFin > horaInicio)
);
GO

CREATE TABLE dbo.Evaluacion
(
    idEvaluacion    INT IDENTITY(1,1) NOT NULL,
    idCurso         INT NOT NULL,
    idTipoEvaluacion TINYINT NOT NULL,
    nombre          NVARCHAR(120) NOT NULL,
    ponderacion     DECIMAL(5,2) NOT NULL,
    notaMaxima      DECIMAL(5,2) NOT NULL
        CONSTRAINT DF_Evaluacion_notaMaxima DEFAULT (20),
    notaObtenida    DECIMAL(5,2) NULL,
    fechaEvaluacion DATE NULL,
    fechaCreacion   DATETIME2(0) NOT NULL
        CONSTRAINT DF_Evaluacion_fechaCreacion DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_Evaluacion PRIMARY KEY (idEvaluacion),
    CONSTRAINT FK_Evaluacion_Curso
        FOREIGN KEY (idCurso) REFERENCES dbo.Curso(idCurso)
        ON DELETE CASCADE,
    CONSTRAINT FK_Evaluacion_Tipo
        FOREIGN KEY (idTipoEvaluacion) REFERENCES dbo.TipoEvaluacion(idTipoEvaluacion),
    CONSTRAINT UQ_Evaluacion_Curso_Nombre UNIQUE (idCurso, nombre),
    CONSTRAINT CK_Evaluacion_Ponderacion CHECK (ponderacion >= 0 AND ponderacion <= 100),
    CONSTRAINT CK_Evaluacion_NotaMaxima CHECK (notaMaxima = 20),
    CONSTRAINT CK_Evaluacion_NotaObtenida
        CHECK (notaObtenida IS NULL OR (notaObtenida >= 0 AND notaObtenida <= 20))
);
GO

CREATE TABLE dbo.Tarea
(
    idTarea             INT IDENTITY(1,1) NOT NULL,
    idUsuario           INT NOT NULL,
    idCurso             INT NULL,
    titulo              NVARCHAR(150) NOT NULL,
    descripcion         NVARCHAR(500) NULL,
    fechaCreacion       DATETIME2(0) NOT NULL
        CONSTRAINT DF_Tarea_fechaCreacion DEFAULT (SYSDATETIME()),
    fechaVencimiento    DATETIME2(0) NULL,
    prioridad           VARCHAR(20) NOT NULL
        CONSTRAINT DF_Tarea_prioridad DEFAULT ('media'),
    estado              VARCHAR(20) NOT NULL
        CONSTRAINT DF_Tarea_estado DEFAULT ('pendiente'),
    fechaCompletada     DATETIME2(0) NULL,
    CONSTRAINT PK_Tarea PRIMARY KEY (idTarea),
    CONSTRAINT FK_Tarea_Usuario
        FOREIGN KEY (idUsuario) REFERENCES dbo.Usuario(idUsuario)
        ON DELETE CASCADE,
    CONSTRAINT FK_Tarea_Curso
        FOREIGN KEY (idCurso) REFERENCES dbo.Curso(idCurso)
        ON DELETE SET NULL,
    CONSTRAINT CK_Tarea_Prioridad CHECK (prioridad IN ('baja', 'media', 'alta')),
    CONSTRAINT CK_Tarea_Estado
        CHECK (estado IN ('pendiente', 'en_progreso', 'completada', 'cancelada'))
);
GO

CREATE TABLE dbo.SesionEstudio
(
    idSesion                INT IDENTITY(1,1) NOT NULL,
    idUsuario               INT NOT NULL,
    idCurso                 INT NULL,
    idTarea                 INT NULL,
    titulo                  NVARCHAR(120) NOT NULL,
    fechaInicioProgramada   DATETIME2(0) NOT NULL,
    fechaFinProgramada      DATETIME2(0) NOT NULL,
    fechaInicioReal         DATETIME2(0) NULL,
    fechaFinReal            DATETIME2(0) NULL,
    estado                  VARCHAR(20) NOT NULL
        CONSTRAINT DF_SesionEstudio_estado DEFAULT ('programada'),
    notas                   NVARCHAR(500) NULL,
    CONSTRAINT PK_SesionEstudio PRIMARY KEY (idSesion),
    CONSTRAINT FK_SesionEstudio_Usuario
        FOREIGN KEY (idUsuario) REFERENCES dbo.Usuario(idUsuario)
        ON DELETE CASCADE,
    CONSTRAINT FK_SesionEstudio_Curso
        FOREIGN KEY (idCurso) REFERENCES dbo.Curso(idCurso)
        ON DELETE SET NULL,
    CONSTRAINT FK_SesionEstudio_Tarea
        FOREIGN KEY (idTarea) REFERENCES dbo.Tarea(idTarea)
        ON DELETE SET NULL,
    CONSTRAINT CK_SesionEstudio_FechasProgramadas
        CHECK (fechaFinProgramada > fechaInicioProgramada),
    CONSTRAINT CK_SesionEstudio_Estado
        CHECK (estado IN ('programada', 'en_progreso', 'completada', 'cancelada'))
);
GO

CREATE TABLE dbo.ObjetivoAcademico
(
    idObjetivo      INT IDENTITY(1,1) NOT NULL,
    idUsuario       INT NOT NULL,
    idCurso         INT NULL,
    titulo          NVARCHAR(150) NOT NULL,
    descripcion     NVARCHAR(500) NULL,
    fechaInicio     DATE NOT NULL,
    fechaLimite     DATE NULL,
    progreso        DECIMAL(5,2) NOT NULL
        CONSTRAINT DF_ObjetivoAcademico_progreso DEFAULT (0),
    estado          VARCHAR(20) NOT NULL
        CONSTRAINT DF_ObjetivoAcademico_estado DEFAULT ('pendiente'),
    fechaCreacion   DATETIME2(0) NOT NULL
        CONSTRAINT DF_ObjetivoAcademico_fechaCreacion DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_ObjetivoAcademico PRIMARY KEY (idObjetivo),
    CONSTRAINT FK_ObjetivoAcademico_Usuario
        FOREIGN KEY (idUsuario) REFERENCES dbo.Usuario(idUsuario)
        ON DELETE CASCADE,
    CONSTRAINT FK_ObjetivoAcademico_Curso
        FOREIGN KEY (idCurso) REFERENCES dbo.Curso(idCurso)
        ON DELETE SET NULL,
    CONSTRAINT CK_ObjetivoAcademico_Progreso CHECK (progreso >= 0 AND progreso <= 100),
    CONSTRAINT CK_ObjetivoAcademico_Estado
        CHECK (estado IN ('pendiente', 'en_progreso', 'completado', 'cancelado'))
);
GO

CREATE TABLE dbo.Alerta
(
    idAlerta            INT IDENTITY(1,1) NOT NULL,
    idUsuario           INT NOT NULL,
    idCurso             INT NULL,
    idTarea             INT NULL,
    idTipoAlerta        TINYINT NOT NULL,
    titulo              NVARCHAR(120) NOT NULL,
    mensaje             NVARCHAR(500) NOT NULL,
    fechaProgramada     DATETIME2(0) NULL,
    fechaCreacion       DATETIME2(0) NOT NULL
        CONSTRAINT DF_Alerta_fechaCreacion DEFAULT (SYSDATETIME()),
    leida               BIT NOT NULL
        CONSTRAINT DF_Alerta_leida DEFAULT (0),
    CONSTRAINT PK_Alerta PRIMARY KEY (idAlerta),
    CONSTRAINT FK_Alerta_Usuario
        FOREIGN KEY (idUsuario) REFERENCES dbo.Usuario(idUsuario)
        ON DELETE CASCADE,
    CONSTRAINT FK_Alerta_Curso
        FOREIGN KEY (idCurso) REFERENCES dbo.Curso(idCurso)
        ON DELETE SET NULL,
    CONSTRAINT FK_Alerta_Tarea
        FOREIGN KEY (idTarea) REFERENCES dbo.Tarea(idTarea)
        ON DELETE SET NULL,
    CONSTRAINT FK_Alerta_Tipo
        FOREIGN KEY (idTipoAlerta) REFERENCES dbo.TipoAlerta(idTipoAlerta)
);
GO

CREATE OR ALTER VIEW dbo.vw_PromedioCurso
AS
SELECT
    c.idCurso,
    c.nombre AS curso,
    c.idPeriodo,
    CAST(
        SUM(
            (CAST(e.notaObtenida AS DECIMAL(10,4)) / NULLIF(CAST(e.notaMaxima AS DECIMAL(10,4)), 0))
            * e.ponderacion * 20
        ) / NULLIF(SUM(e.ponderacion), 0)
        AS DECIMAL(5,2)
    ) AS promedioActual,
    SUM(e.ponderacion) AS ponderacionEvaluada,
    COUNT(e.idEvaluacion) AS cantidadEvaluacionesCalificadas
FROM dbo.Curso AS c
LEFT JOIN dbo.Evaluacion AS e
    ON e.idCurso = c.idCurso
   AND e.notaObtenida IS NOT NULL
GROUP BY c.idCurso, c.nombre, c.idPeriodo;
GO
