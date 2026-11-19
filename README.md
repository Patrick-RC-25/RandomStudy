# RandomStudy

**RandomStudy** es una plataforma web de organización y seguimiento académico dirigida a estudiantes universitarios. Permite gestionar actividades académicas, organizar sesiones de estudio y realizar un seguimiento del rendimiento.

El proyecto utiliza Angular 22 para el frontend, FastAPI para el backend y Microsoft SQL Server como sistema gestor de base de datos.

## Tecnologías utilizadas

| Componente | Tecnología |
|---|---|
| Frontend | Angular 22 |
| Lenguaje frontend | TypeScript |
| Estilos | Bootstrap 5 y CSS |
| Iconografía | Bootstrap Icons |
| Backend | Python 3.12+ |
| Framework | FastAPI |
| Servidor | Uvicorn |
| Validación | Pydantic |
| Acceso a datos | pyodbc |
| Base de datos | SQL Server |
| Autenticación | JWT |
| Hash de contraseñas | Argon2 |
| Dependencias backend | uv |

## Estructura del proyecto

```text
RandomStudy/
│
├── AGENTS.md
├── README.md
│
├── frontend/
│   ├── AGENTS.md
│   └── ...
│
├── backend/
│   ├── AGENTS.md
│   ├── .env.example
│   └── ...
│
└── sql/
    └── RandomStudyDB.sql
```

## Requisitos previos

Antes de ejecutar el proyecto, instalar:

- Node.js 22.22.3 o superior dentro de la rama 22.
- npm.
- Python 3.12 o superior.
- uv.
- Microsoft SQL Server.
- SQL Server Management Studio (SSMS).
- Microsoft ODBC Driver 17 o 18 para SQL Server.

## 1. Configuración de la base de datos

1. Abrir SQL Server Management Studio.
2. Conectarse a la instancia de SQL Server.
3. Abrir el archivo `sql/RandomStudyDB.sql`.
4. Ejecutar el script.
5. Verificar que se haya creado la base de datos `RandomStudyDB`, sus tablas y la vista `dbo.vw_PromedioCurso`.

El script está preparado para crear el esquema, no para borrar o reemplazar una base de datos existente.

Si ya existen datos, realizar una copia de seguridad antes de aplicar cambios.

## 2. Configuración del backend

Ingresar a la carpeta:

```powershell
cd backend
```

Crear el archivo de variables de entorno:

```powershell
Copy-Item .env.example .env
```

Editar `.env` y configurar los datos correspondientes a la instancia de SQL Server, las credenciales de conexión y las claves necesarias para la autenticación.

Instalar las dependencias:

```powershell
uv sync
```

Iniciar el servidor:

```powershell
uv run uvicorn backend.main:app --reload --host 127.0.0.1 --port 8000
```

### Direcciones del backend

| Servicio | Dirección |
|---|---|
| API | http://127.0.0.1:8000 |
| Swagger UI | http://127.0.0.1:8000/docs |
| Health check | http://127.0.0.1:8000/health |

El endpoint `/health` permite comprobar el estado del servicio y la conexión con la base de datos.

## 3. Configuración del frontend

Abrir una segunda terminal e ingresar a:

```powershell
cd frontend
```

Instalar las dependencias:

```powershell
npm install
```

Iniciar la aplicación:

```powershell
npm start
```

La aplicación estará disponible en:

http://localhost:4200

### Configuración de la API

La dirección del backend se encuentra configurada en:

```text
frontend/src/environments/
├── environment.development.ts
└── environment.ts
```

Comprobar que la URL configurada coincida con la dirección donde se está ejecutando FastAPI.

El proyecto tiene actualmente `ssr: false`, por lo que la ejecución de la aplicación no activa Server-Side Rendering.

## 4. Funcionalidades implementadas

### Autenticación y perfil

- Registro de usuarios.
- Inicio y cierre de sesión mediante JWT.
- Consulta y actualización del perfil académico.

### Organización académica

- Gestión de periodos académicos.
- Registro y administración de cursos.
- Configuración de metas de nota.
- Registro y administración de evaluaciones.
- Consulta de calificaciones y promedios ponderados.
- Gestión de horarios de clase.

### Gestión del estudio

- Registro y administración de tareas.
- Configuración de prioridades y vencimientos.
- Seguimiento de estados de las tareas.
- Programación de sesiones de estudio.
- Inicio, finalización y cancelación de sesiones.
- Registro y seguimiento de objetivos académicos.

### Seguimiento académico

- Dashboard con resumen de información académica.
- Consulta de alertas.
- Marcado de alertas como leídas.
- Eliminación de alertas.
- Consulta del rendimiento académico.
- Comparación del promedio actual con la nota objetivo.

## 5. Endpoints principales

La API proporciona los siguientes recursos:

| Recurso | Endpoints principales |
|---|---|
| Autenticación | `/auth/register`, `/auth/login`, `/auth/me`, `/auth/logout` |
| Perfil | `GET/PUT /perfil` |
| Periodos | `GET/POST /periodos` |
| Cursos | `GET/POST /cursos`, `GET/PUT/DELETE /cursos/{id}` |
| Evaluaciones | `GET /evaluaciones/curso/{id}`, `POST /evaluaciones`, `PUT/DELETE /evaluaciones/{id}` |
| Horarios | `GET/POST /horarios`, `GET /horarios/curso/{id}`, `PUT/DELETE /horarios/{id}` |
| Tareas | `GET/POST /tareas`, `PUT/DELETE /tareas/{id}` |
| Sesiones | `/sesiones` y acciones `iniciar`, `finalizar`, `cancelar` |
| Objetivos | `GET/POST /objetivos`, `PUT/DELETE /objetivos/{id}` |
| Alertas | `GET/POST /alertas`, `PATCH /alertas/{id}/leida`, `DELETE /alertas/{id}` |
| Dashboard | `GET /dashboard/resumen` |
| Rendimiento | `GET /rendimiento` |

Para consultar los parámetros, métodos HTTP, esquemas de entrada y respuestas de cada endpoint, acceder a Swagger UI:

http://127.0.0.1:8000/docs

## 6. Consideraciones técnicas

### Base de datos

El backend utiliza `pyodbc` para conectarse a SQL Server y ejecutar consultas SQL parametrizadas. No utiliza un ORM.

### Seguridad

Las contraseñas se procesan mediante Argon2 y la autenticación utiliza JWT. Las credenciales y claves sensibles se configuran mediante variables de entorno.

### Integridad de la información

Los valores nulos se conservan según su significado. Por ejemplo, una evaluación sin calificación no se interpreta como una nota igual a cero.

### Rendimiento académico

El análisis se realiza con los datos disponibles en la base de datos. Actualmente no se dispone de un historial semanal de promedios, por lo que no se generan gráficos de evolución temporal con información ficticia.

### Alertas

Las alertas se almacenan y administran mediante la API. El envío automático programado requiere implementar un proceso de tareas en segundo plano.

### Preferencias de notificación

No existe actualmente persistencia para las preferencias de notificación.

## 7. Limitaciones actuales

- No se ha implementado la recuperación de contraseña.
- No se guardan preferencias de notificación.
- El envío automático y programado de alertas requiere un proceso adicional en segundo plano.
- No se dispone de un historial temporal de promedios académicos.
- El análisis de rendimiento se limita a los datos actuales proporcionados por la API.

## 8. Verificación del proyecto

### Frontend

Desde `frontend/`:

```powershell
npm run build
npm test -- --watch=false
```

### Backend

Desde `backend/`:

```powershell
uv sync
```

Ejecutar las pruebas automatizadas disponibles en el proyecto.

Comprobar también el funcionamiento de los endpoints mediante Swagger UI y verificar la conexión con SQL Server.

## 9. Seguridad y recomendaciones

- No compartir el archivo `.env`.
- No publicar contraseñas ni claves JWT.
- No subir credenciales al repositorio.
- Realizar copias de seguridad antes de modificar la base de datos.
- Mantener actualizadas las dependencias.
- Verificar las operaciones de escritura y sus transacciones.

## 10. Documentación para desarrollo

El proyecto cuenta con archivos `AGENTS.md` que contienen las instrucciones y convenciones para trabajar en cada módulo:

- `AGENTS.md`: instrucciones generales del proyecto.
- `frontend/AGENTS.md`: convenciones y reglas del frontend.
- `backend/AGENTS.md`: convenciones y reglas del backend.

## 11. Correcciones técnicas

- Las inserciones de tareas, alertas y sesiones utilizan `OUTPUT INSERTED` para recuperar el registro creado dentro de la misma conexión y transacción.
- Esto evita consultar el registro desde una segunda conexión antes del `COMMIT`, situación que podía generar bloqueos o esperas durante las operaciones.