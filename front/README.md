# Front-end: Auditor de Contrataciones Públicas

Aplicación web en **React + TypeScript (Vite)**, compatible con el backend Flask de
la rama **`back-end`** del repo (y también con `main`).

**Panel izquierdo**

- **Solicitud:** cada petición crea un caso (`POST /casos`) y muestra su avance por
  las etapas del orquestador. Si se bloquea, muestra el motivo y permite desbloquear.
- **Casos:** lista de casos guardados en el backend, con filtro por estado. El detalle
  de cada caso tiene sus reportes, las **señales** con la decisión del auditor
  (relevante, descartada con comentario o pendiente), el uso del LLM, la **bitácora**
  y los botones para iniciar la revisión y cerrar el caso.
- **Agentes:** el indicador de la cabecera dice cuántas laptops con Ollama están
  disponibles y permite verificarlas.

**Panel derecho:** visor/editor del reporte (PDF, o Markdown convertido a PDF):
resaltar, subrayar, tachar, notas, cuadros de texto y reescribir texto. Las
anotaciones se guardan solas y el PDF anotado se puede descargar.

## Arranque

```powershell
.\dev.ps1                      # o: npm install; npm run dev  → http://localhost:5173
```

Sin configurar nada arranca en **modo simulación** (backend ficticio en el navegador,
con las mismas reglas que el real). Si una solicitud contiene «bloqueo», el caso se
bloquea para probar el desbloqueo.

## Usar el backend real

Con el backend Flask corriendo en `http://localhost:5000`:

```powershell
.\dev.ps1 backend
```

(Equivale a poner `VITE_USE_MOCK=false` en `.env.local`; ahí también puedes cambiar
`BACKEND_URL` si el backend está en otra dirección.)

El proxy de Vite manda `/api/*` a Flask quitando `/api`. Es necesario con la rama
`back-end`, que no tiene CORS. Qué endpoints usa cada pantalla y qué le falta al
backend: [docs/API_CONTRACT.md](docs/API_CONTRACT.md).

### Probar contra el backend sin Postgres

`scripts\backend_prueba.ps1` levanta el **Flask real** de la rama `back-end` con los
repositorios en memoria de sus pruebas y tres casos de ejemplo (uno con reporte
Markdown y señales, uno bloqueado y uno con PDF). Dos ventanas de PowerShell:

```powershell
# Ventana 1: backend (la primera vez exporta la rama y crea su entorno; tarda ~1 min)
powershell -ExecutionPolicy Bypass -File scripts\backend_prueba.ps1

# Ventana 2: front
.\dev.ps1 backend
```

El lanzador solo **lee** el repo (`git archive` de `upstream/back-end`); no cambia
ramas ni archivos. Usa `-Actualizar` para volver a exportar la rama si cambió, y
`-Repo <ruta>` si el repo no está en `Documents\GitHub`.

## Arquitectura

```
src/
├─ api/                         Lo único que sabe de HTTP (ver docs/API_CONTRACT.md)
├─ features/
│  ├─ chat/                     Solicitud: crear casos y seguir su avance
│  ├─ casos/                    Lista, detalle, señales y decisiones, bitácora
│  ├─ agentes/                  Indicador y verificación de agentes
│  ├─ auth/                     Inicio de sesión (solo si el backend lo tiene)
│  └─ pdf/                      Visor/editor (pdf.js + pdf-lib)
├─ lib/                         Maquetado de PDF, Markdown → PDF, formatos
└─ types/                       Caso, reporte, señal, agente, anotaciones…
```

## Uso del editor

| Herramienta | Tecla | Cómo se usa |
|---|---|---|
| Seleccionar | V | Selecciona texto → menú para resaltar/subrayar/tachar. Clic en una anotación para editarla. |
| Resaltar / Subrayar / Tachar | H / U / K | Selecciona texto con el ratón. |
| Nota | N | Clic en la página; se puede arrastrar. |
| Cuadro de texto | T | Clic en la página y escribe; se mueve con el punto azul y se ensancha por el borde. |
| Editar texto del PDF | E | Clic sobre una línea del PDF para reescribirla. |

`Supr` borra la anotación seleccionada, `Ctrl+Z` / `Ctrl+Y` deshacen y rehacen y
`Esc` vuelve a Seleccionar.

## Limitaciones

- La rama `back-end` no tiene orquestador: los casos nuevos se quedan en «Recibido».
- Las anotaciones viven en el navegador hasta que el backend tenga su endpoint.
- "Editar texto" tapa el fragmento original y escribe encima (Helvetica).
- Al exportar, solo caracteres latinos (acentos y ñ sí); emojis u otros alfabetos salen como `?`.
