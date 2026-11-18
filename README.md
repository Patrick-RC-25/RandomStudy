# RandomStudy

Plataforma de organización y seguimiento académico para estudiantes universitarios. El proyecto utiliza Angular 22 en el frontend, FastAPI en el backend y SQL Server (`RandomStudyDB`) como base de datos. El backend accede a SQL Server con `pyodbc` y consultas parametrizadas; no utiliza ORM.

## Estructura

```text
CarlitoApp/
├── frontend/       # Angular 22 + Bootstrap 5
├── backend/        # FastAPI + pyodbc + JWT + Argon2
└── sql/
    └── RandomStudyDB.sql
```

## 1. Base de datos

1. Abre SQL Server Management Studio.
2. Ejecuta `sql/RandomStudyDB.sql`.
3. Verifica que se haya creado `RandomStudyDB`, sus tablas y la vista `dbo.vw_PromedioCurso`.

El script está preparado para crear el esquema, no para borrar o reemplazar una base existente. Si ya tienes datos, realiza una copia de seguridad antes de aplicar cualquier cambio.

## 2. Backend

Requisitos: Python 3.12 o superior, SQL Server, ODBC Driver 17/18 y `uv`.

```powershell
cd backend
Copy-Item .env.example .env
# Edita .env con los datos reales de tu instancia SQL Server.
uv sync
uv run uvicorn backend.main:app --reload --host 127.0.0.1 --port 8000
```

- Documentación API: http://127.0.0.1:8000/docs
- Estado de API y conexión DB: http://127.0.0.1:8000/health

No publiques el archivo `.env` ni compartas contraseñas o claves JWT.

## 3. Frontend

Requisitos: Node.js `22.22.3` o superior dentro de la rama 22 (o una versión compatible indicada por Angular 22) y npm.

```powershell
cd frontend
npm install
npm start
```

Aplicación: http://localhost:4200

La URL del backend se configura en `frontend/src/environments/environment.development.ts` y `environment.ts`. El `angular.json` actual tiene `ssr: false`; los archivos de configuración de servidor permanecen en el proyecto, pero la compilación actual no activa SSR.

## Funcionalidades conectadas

- Registro, inicio y cierre de sesión con JWT.
- Perfil académico.
- Periodos académicos (se crea uno inicial al registrar la cuenta).
- Cursos y horarios de clase.
- Evaluaciones, calificaciones y promedio ponderado por curso.
- Tareas: registro, edición, prioridad, vencimiento y estados.
- Sesiones de estudio: programación, inicio, finalización y cancelación.
- Objetivos académicos: registro, seguimiento, finalización y eliminación.
- Alertas: registro, lectura y eliminación por API.
- Dashboard y análisis de rendimiento basados en los datos disponibles.

## Endpoints principales

| Recurso       | Rutas                                                                                 |
| ------------- | ------------------------------------------------------------------------------------- | --------- | --------- |
| Autenticación | `/auth/register`, `/auth/login`, `/auth/me`, `/auth/logout`                           |
| Perfil        | `GET/PUT /perfil`                                                                     |
| Periodos      | `GET/POST /periodos`                                                                  |
| Cursos        | `GET/POST /cursos`, `GET/PUT/DELETE /cursos/{id}`                                     |
| Evaluaciones  | `GET /evaluaciones/curso/{id}`, `POST /evaluaciones`, `PUT/DELETE /evaluaciones/{id}` |
| Horarios      | `GET/POST /horarios`, `GET /horarios/curso/{id}`, `PUT/DELETE /horarios/{id}`         |
| Tareas        | `GET/POST /tareas`, `PUT/DELETE /tareas/{id}`                                         |
| Sesiones      | `GET/POST /sesiones`, `PUT/DELETE /sesiones/{id}`, `PATCH /sesiones/{id}/iniciar      | finalizar | cancelar` |
| Objetivos     | `GET/POST /objetivos`, `PUT/DELETE /objetivos/{id}`                                   |
| Alertas       | `GET/POST /alertas`, `PATCH /alertas/{id}/leida`, `DELETE /alertas/{id}`              |
| Dashboard     | `GET /dashboard/resumen`                                                              |
| Rendimiento   | `GET /rendimiento`                                                                    |

## Consideraciones pendientes

- No se ha implementado recuperación de contraseña.
- Las preferencias de notificación no se guardan porque todavía no existe un recurso y persistencia para ellas.
- Las alertas se almacenan y se muestran; el envío automático programado requiere un proceso de tareas en segundo plano.
- El análisis histórico semanal no se muestra porque el esquema actual no conserva una serie temporal de promedios. El módulo compara promedios actuales con notas objetivo.
- El frontend no ha sido probado contra tu instancia real de SQL Server desde este entorno. Ejecuta las pruebas locales siguiendo los pasos anteriores.

## Correcciones de guardado

- Los INSERT de tareas, alertas y sesiones devuelven el registro creado mediante `OUTPUT INSERTED` en la misma conexión/transacción. Esto evita consultar el registro desde una segunda conexión antes del `COMMIT`, lo que podía dejar la petición bloqueada.
