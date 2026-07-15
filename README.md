# Informe de Funcionamiento: Sistema de Gestión Hotelera
**Autor:** Jhordan Huera
**Materia:** Aplicaciones Móviles - 7mo Semestre

## Resumen Ejecutivo
Este documento detalla el funcionamiento y las mejoras implementadas en la **Aplicación Móvil (Frontend en Flutter)** para el sistema de gestión de reservas de hotel. El objetivo principal de estos cambios fue mejorar drásticamente la experiencia de usuario (UX) mediante validaciones, indicadores visuales, diseño responsivo y la prevención de errores comunes al momento de realizar reservaciones.

---

## 1. Configuración y Conexión
La aplicación móvil está configurada para consumir los servicios del backend local.
* **URL de la API en uso:** `https://hotel-api-silk.vercel.app/api`
* Esta URL base es utilizada por todos los servicios (`RoomService`, `ReservationService`, `UserService`) para sincronizar la información de huéspedes, habitaciones y reservas en tiempo real.

---

## 2. Gestión de Habitaciones
La interfaz de habitaciones fue completamente renovada para ofrecer claridad visual inmediata al recepcionista.

### A. Indicadores Visuales y Filtros Interactivos
* Se integró un sistema de "Chips" (botones de filtrado) en la pantalla de habitaciones, permitiendo clasificar el inventario rápidamente en: **Todas**, **Disponibles**, **Ocupadas** y **Mantenimiento**.
* **Diseño Dinámico de Tarjetas (Cards):**
  * **Verde (Disponible):** Opacidad 100%, con borde verde y sombra elevada (lista para uso).
  * **Rojo (Ocupada):** Opacidad reducida, tarjeta más plana indicando que está en uso.
  * **Naranja (Mantenimiento):** Iconografía y estilo naranja para advertir que está fuera de servicio.

> **Nota:** Pantalla de la lista de habitaciones mostrando los filtros y los diferentes colores de las tarjetas.

![Captura: Lista de Habitaciones y Filtros](<!-- REEMPLAZA ESTO CON LA RUTA O NOMBRE DE TU IMAGEN -->)

### B. Pantalla de Detalles de Habitación
Al hacer clic en cualquier tarjeta de habitación, se navega a una vista de detalles.
* Muestra el número, tipo y estado de la habitación de forma inmersiva usando los colores temáticos de la aplicación (Azul Marino y Dorado).
* Lista características, descripción, capacidad, piso y el historial de actualización en la base de datos.
* Incluye un acceso rápido (ícono de lápiz) para editar su estado directamente desde los detalles sin perder contexto.

> **Nota:** Pantalla de Detalles de Habitación.

![Captura: Detalles de Habitación](<!-- REEMPLAZA ESTO CON LA RUTA O NOMBRE DE TU IMAGEN -->)

---

## 3. Optimización en Reservas y Navegación
Se implementaron soluciones lógicas para garantizar que la información mostrada siempre sea precisa y evitar cruces de datos.

* **Prevención de Doble Reserva:** En el formulario de nueva reserva, el desplegable de selección de habitación filtra automáticamente las habitaciones que están en estado 'DISPONIBLE'. Esto impide categóricamente que el usuario pueda asignar una habitación que actualmente se encuentra en uso o en mantenimiento.
* **Sincronización de Datos (Recarga Automática):** Se modificó la arquitectura de navegación de la barra inferior. Ahora, la aplicación realiza una petición a la API y obtiene datos frescos cada vez que el usuario cambia de pestaña, garantizando que los estados de las habitaciones estén sincronizados en tiempo real con las reservas recién creadas o modificadas.

> **Nota:** Formulario de Nueva Reserva mostrando el desplegable de habitaciones que solo incluye las que están "Disponibles".

![Captura: Formulario de Reservas y Sincronización](<!-- REEMPLAZA ESTO CON LA RUTA O NOMBRE DE TU IMAGEN -->)
