import '../repositories/usuario_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/pedido_repository.dart';
import 'dio_client.dart';
import 'carrito_service.dart';

/// Clase para la inyección de dependencias y gestión centralizada de instancias
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  // Clientes y servicios
  late final DioClient _dioClient;
  late final CarritoService carritoService;

  // Repositorios
  late final IUsuarioRepository usuarioRepository;
  late final IProductoRepository productoRepository;
  late final IPedidoRepository pedidoRepository;

  // Constructor factory que devuelve la instancia singleton
  factory ServiceLocator() {
    return _instance;
  }

  // Constructor privado para inicialización
  ServiceLocator._internal() {
    _initializeDependencies();
  }

  // Inicializar todas las dependencias
  void _initializeDependencies() {
    // Inicializar cliente DIO
    _dioClient = DioClient();

    // Inicializar servicios
    carritoService = CarritoService();

    // Inicializar repositorios
    usuarioRepository = ApiUsuarioRepository(_dioClient);
    productoRepository = ApiProductoRepository(_dioClient);
    pedidoRepository = ApiPedidoRepository(_dioClient);
  }
}
