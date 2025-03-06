# Wabizone

Wabizone es un proyecto de e-commerce que consta de un backend desarrollado con Spring Boot y un frontend desarrollado con Flutter. La aplicación permite la gestión de productos, usuarios, carritos de compra y pedidos a través de una interfaz moderna y responsive.

## Estructura del Proyecto

```
Wabizone/
├── backend/    # Aplicación Spring Boot (Java)
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/wabizone/ecommerce/
│   │   │   │   ├── api/            # Controladores REST
│   │   │   │   ├── config/         # Configuraciones
│   │   │   │   ├── models/         # Entidades de datos
│   │   │   │   ├── repository/     # Repositorios JPA y MongoDB
│   │   │   │   └── services/       # Servicios de negocio
│   │   │   └── resources/          # Archivos de configuración
│   │   └── test/                   # Pruebas unitarias e integración
│   └── pom.xml                     # Dependencias Maven
└── frontend/   # Aplicación Flutter
    ├── lib/
    │   ├── models/                 # Modelos de datos
    │   ├── providers/              # Gestores de estado
    │   ├── repositories/           # Repositorios de datos
    │   ├── screens/                # Interfaces de usuario
    │   ├── services/               # Servicios y API
    │   ├── utils/                  # Utilidades
    │   └── widgets/                # Componentes reutilizables
    ├── assets/                     # Recursos estáticos
    └── pubspec.yaml                # Dependencias Flutter
```

## Backend (Spring Boot)

### Tecnologías Utilizadas
- Java 17
- Spring Boot 3.4.3
- Spring Data JPA
- Spring Data MongoDB
- MySQL
- MongoDB
- Lombok
- Maven

### Características
- Arquitectura REST API
- Persistencia dual con MySQL y MongoDB
- Gestión de usuarios y autenticación
- Gestión de productos
- Gestión de carritos de compra
- Procesamiento de pedidos
- Configuración CORS para integración con frontend

### Requisitos
- Java 17 o superior
- Maven
- MySQL Server
- MongoDB Server

### Configuración

El backend utiliza configuraciones en `application.properties`:

```properties
spring.application.name=wabizone-ecommerce
spring.datasource.url=jdbc:mysql://localhost:3306
spring.datasource.username=root
spring.datasource.password=rootroot
spring.jpa.hibernate.ddl-auto=update
spring.data.mongodb.uri=mongodb://localhost:27017/ecommerce
server.port=8081
```

### Ejecución

```bash
cd backend
./mvnw spring-boot:run
```

El backend se ejecutará en `http://localhost:8081`.

### Endpoints API

La API REST expone los siguientes endpoints principales:

- `/api/v1/users` - Gestión de usuarios
- `/api/v1/products` - Gestión de productos
- `/api/v1/cart` - Gestión del carrito de compras
- `/api/v1/pedidos` - Gestión de pedidos

## Frontend (Flutter)

### Tecnologías Utilizadas
- Flutter SDK
- Dart
- Provider (gestión de estado)
- Dio (cliente HTTP)
- Shared Preferences (almacenamiento local)

### Características
- Uso de la biblioteca **DIO** para peticiones HTTP
- Patrón Singleton para manejo centralizado de la conexión API
- Gestión automatizada de JSON y codificación UTF-8
- Arquitectura de repositorio para acceso a datos
- Inyección de dependencias mediante Service Locator
- Gestión de estado con Provider
- Interfaces adaptativas para múltiples dispositivos
- Pantallas para:
  - Inicio de sesión y registro
  - Catálogo de productos
  - Carrito de compras
  - Proceso de checkout
  - Gestión de pedidos
  - Perfil de usuario
  - Panel de administración

### Requisitos
- Flutter SDK
- Dart

### Instalación de Dependencias

```bash
cd frontend
flutter pub get
```

### Ejecución

```bash
cd frontend
flutter run
```

### Compilación para producción

```bash
cd frontend
flutter build web  # Para versión web
flutter build apk  # Para Android
flutter build ios  # Para iOS (requiere macOS)
```

## Integración Frontend-Backend

- La conexión entre frontend y backend está configurada mediante CORS
- Las URL base de las APIs están centralizadas en el cliente DIO
- Configuración por defecto: `http://localhost:8081/api/v1`

```dart
// Configuración del cliente DIO en frontend/lib/services/dio_client.dart
static const String baseUrl = 'http://localhost:8081/api/v1';
```

## Flujo de Datos

1. El frontend realiza peticiones HTTP a través del cliente DIO
2. Los repositorios en Flutter transforman los datos entre el formato de API y los modelos locales
3. Los providers gestionan el estado de la aplicación y notifican a la UI de cambios
4. El backend procesa las peticiones a través de controladores REST
5. Los servicios en el backend implementan la lógica de negocio
6. Los repositorios JPA/MongoDB gestionan la persistencia de datos

## Seguridad

- Interceptores DIO para manejo de tokens y seguridad
- Ocultación de contraseñas en logs
- Validación de datos en backend y frontend

## Desarrolladores

- Equipo Wabizone

## Licencia

Todos los derechos reservados © 2024 Wabizone