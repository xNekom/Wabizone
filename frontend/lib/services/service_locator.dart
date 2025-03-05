import '../repositories/usuario_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/pedido_repository.dart';
import 'dio_client.dart';
import 'carrito_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  late final DioClient _dioClient;
  late final CarritoService carritoService;

  late final IUsuarioRepository usuarioRepository;
  late final IProductoRepository productoRepository;
  late final IPedidoRepository pedidoRepository;

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal() {
    _initializeDependencies();
  }

  void _initializeDependencies() {
    _dioClient = DioClient();
    carritoService = CarritoService();

    usuarioRepository = ApiUsuarioRepository(_dioClient);
    productoRepository = ApiProductoRepository(_dioClient);
    pedidoRepository = ApiPedidoRepository(_dioClient);
  }
}
