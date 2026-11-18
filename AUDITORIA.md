# Auditoría de RandomStudy

## Correcciones de consistencia aplicadas en esta revisión

- Se unificó la marca visible como **RandomStudy**; `RandomStudyDB` permanece como nombre técnico de la base de datos.
- Se alinearon los contratos del frontend con las rutas y DTOs actuales de FastAPI (`/perfil`, `/evaluaciones`, `/alertas`, etc.).
- Se corrigió el significado de `Alerta.leida`: ahora se presenta como leída/no leída, no como atendida/completada.
- Se corrigió el mapeo de tipos de alerta: recordatorio, vencimiento, rendimiento y sistema.
- Se agregó una pantalla de tareas conectada a `/tareas`, con alta, edición, prioridad, vencimiento, estados y eliminación.
- Se conectó la vista de horarios de clase con `/horarios` dentro de Planificación.
- Se incorporó el inicio de sesiones de estudio y se distingue el estado `en_progreso`.
- Se corrigió el perfil para tratar `ciclo` como texto y no convertirlo a un número inventado; el correo se muestra como no editable porque la API actual no permite modificarlo.
- Se retiró la simulación de preferencias de notificación que devolvía éxito sin persistencia.
- Se incorporó creación, finalización y eliminación de objetivos académicos.
- Se corrigió el promedio/calificación nula para no mostrarla como cero.
- Se eliminó la falsa comparación con un promedio anterior que siempre era idéntico al actual.
- El módulo de rendimiento ahora compara promedio actual y nota objetivo, sin inventar historial semanal.
- Se añadió edición y desactivación de cursos.
- Se reforzaron en backend las validaciones de pertenencia de curso/tarea al crear o actualizar tareas, sesiones, objetivos y alertas.
- Se validó en backend que la suma de ponderaciones de evaluaciones de un curso no supere el 100 %.
- Se actualizaron README y AGENTS.md para describir las rutas y arquitectura reales.

## Funcionalidades que siguen pendientes

- Recuperación de contraseña.
- Persistencia de preferencias de notificación.
- Generación y envío automático de alertas en segundo plano.
- Edición de horarios existentes desde la interfaz (por ahora se pueden registrar y eliminar).
- Edición y eliminación de periodos académicos; por ahora se puede crear un periodo activo y consultar el historial.
- Histórico real de rendimiento: requiere almacenar snapshots o resultados por periodo/fecha.
- Pruebas de integración completas con SQL Server real.

## Validación en este entorno

- `python -m compileall` sobre el backend: correcto.
- Se analizaron sintácticamente los 76 archivos TypeScript con el compilador TypeScript global: sin errores de sintaxis.
- Se revisó la estructura de las 20 plantillas HTML de Angular: sin etiquetas desbalanceadas.
- No se pudo ejecutar el build ni los tests de Angular: el entorno disponible tiene Node `22.16.0`, inferior al mínimo requerido por los paquetes Angular 22 fijados en el lockfile (`22.22.3`), y no fue posible instalar una versión compatible en este entorno.
- No se ejecutó el script SQL en una instancia real de SQL Server.

Antes de desplegar, ejecutar en tu equipo `npm run build`, `npm test -- --watch=false`, levantar FastAPI y probar cada flujo contra tu instancia `RandomStudyDB`.
