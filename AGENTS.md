# AGENTS.md — RandomStudy (raíz)

Plataforma académica: Angular 22 (`frontend_SistemaWeb-main/`) + FastAPI/SQL Server sin ORM (`backend_SistemaWeb-main/`) + esquema en `sql/`.

## Antes de nada

- Los nombres reales de carpeta llevan sufijo: `backend_SistemaWeb-main/` y `frontend_SistemaWeb-main/`. El README raíz y los AGENTS de módulo a veces escriben `backend/` y `frontend/`; no renombres ni dupliques carpetas para "alinear" la documentación.
- Cada carpeta es un proyecto independiente (uv y npm). No hay workspace raíz, CI, linter ni tests de backend. Esta copia no es un checkout git.
- Lee el AGENTS del módulo antes de editar: `backend_SistemaWeb-main/AGENTS.md` y `frontend_SistemaWeb-main/AGENTS.md`. Ahí están las trampas específicas; este archivo solo cubre lo transversal.

## Puesta en marcha (en este orden)

1. SQL Server: ejecutar `sql/RandomStudyDB.sql` en SSMS. Crea `RandomStudyDB`, las tablas y `dbo.vw_PromedioCurso`. No es idempotente: falla si la base ya existe y no borra datos.
2. Backend, desde `backend_SistemaWeb-main/`:

   ```powershell
   Copy-Item .env.example .env   # completar DB_*, DB_DRIVER y JWT_SECRET_KEY
   uv sync
   uv run uvicorn backend.main:app --reload --host 127.0.0.1 --port 8000
   ```

3. Frontend, desde `frontend_SistemaWeb-main/`:

   ```powershell
   npm install
   npm start
   ```

- Frontend en `http://localhost:4200`; API en `http://localhost:8000`, Swagger en `/docs`.
- El script solo siembra `TipoEvaluacion` y `TipoAlerta`: no hay usuarios. Regístrate en `/registro` o con `POST /auth/register`; el registro crea usuario + perfil + periodo activo.
- La URL del backend se cambia en **ambos** `src/environments/environment.ts` y `environment.development.ts` (`apiUrl`).
- Requisitos: Python 3.12+ (`.python-version` fija 3.13), `uv`, SQL Server + ODBC Driver 18 (o define `DB_DRIVER`), y Node/npm según `engines` de `package.json` (22.22.3+, 24.15+ o 26+). Usa npm: hay `package-lock.json`.

## Verificación

- Backend: no hay pytest/ruff/mypy ni scripts. Smoke test: `uv run python -c "import backend.main"`. Con SQL Server arriba, `GET /health` (503 si falla la DB) y `/docs`.
- Frontend: `npm run build`; `npm test -- --watch=false`. El runner es Vitest (jsdom), no Karma.
- Acotar pruebas: `npm test -- --watch=false --filter "AlertsService"` o `--include=app/core/api/mappers.spec.ts`. Bajo `src/app/` solo hay specs en `app.spec.ts`, `core/api/mappers.spec.ts` y `features/alerts/services/alerts.service.spec.ts`.
- No hay script de lint/formato; `.prettierrc` existe pero no está conectado a npm.

## Contrato entre módulos

- Backend: Pydantic y JSON en snake_case español (`id_curso`, `nota_obtenida`); columnas SQL en camelCase (`idCurso`, `notaObtenida`), mapeadas a mano. Solo SQL Server/T-SQL, placeholders `?`, sin ORM.
- Frontend: por feature conviven `interfaces/<x>-api.interface.ts` (forma cruda de la API), `interfaces/<model>.interface.ts` (presentación camelCase) y `mappers/<x>.mapper.ts`. Al cambiar un endpoint actualiza esquema/router del backend, interfaz `*-api`, mapper y el spec de mappers; no uses DTOs de API en templates.
- Auth: token JWT en `localStorage` (`randomstudy.session`) y cabecera `Bearer` puesta por `core/interceptors/auth.interceptor.ts`. CORS del backend solo acepta `localhost:4200` y `127.0.0.1:4200`.
- Semántica de nulos: `nota_obtenida: null` = evaluación sin calificar (no 0); `promedio_actual: null` = sin calificaciones. Rendimiento no tiene historial semanal: no inventes series ni métricas.

## Trampas que cuestan tiempo

- Backend: cada router/servicio/repositorio/esquema existe una sola vez y sin sufijo; ya no hay gemelos `*_api.py`, `*_service.py`, `*_schema.py` ni `*_repository.py`.
- Backend: importa como `backend.*`, nunca `src.backend.*`. El entrypoint real es `uvicorn backend.main:app`. Las variables de `.env` se leen al importar: reinicia tras cambiarlas.
- Frontend: `angular.json` tiene `ssr: false` aunque existan `main.server.ts`, `server.ts` y el script `serve:ssr:frontend`; no asumas salida SSR. Formularios solo con Angular Signal Forms (`@angular/forms/signals`), nunca `FormGroup`/`ngModel`.
