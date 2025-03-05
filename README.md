# Wabizone

Wabizone es un proyecto que consta de un backend desarrollado con Spring Boot y un frontend desarrollado con Flutter.

## Estructura del Proyecto

```
Wabizone/
├── backend/    # Aplicación Spring Boot (Java)
└── frontend/   # Aplicación Flutter
```

## Backend (Spring Boot)

### Requisitos
- Java 11 o superior
- Maven

### Ejecución

```bash
cd backend
./mvnw spring-boot:run
```

El backend se ejecutará en `http://localhost:8080`.

## Frontend (Flutter)

### Requisitos
- Flutter SDK
- Dart

### Características
- Uso de la biblioteca **DIO** para peticiones HTTP
- Patrón Singleton para manejo centralizado de la conexión API
- Gestión automatizada de JSON y codificación UTF-8

### Ejecución

```bash
cd frontend
flutter pub get
flutter run
```

### Compilación para producción

```bash
cd frontend
flutter build web  # Para versión web
flutter build apk  # Para Android
flutter build ios  # Para iOS (requiere macOS)
```

## Configuración

- El backend utiliza configuraciones en `application.properties`
- La conexión entre frontend y backend está configurada mediante CORS
- Las URL base de las APIs están centralizadas en el cliente DIO

## Desarrolladores

[Añadir nombres de los desarrolladores]

## Licencia

[Especificar licencia] 