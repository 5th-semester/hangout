import '../../models/coordinates.dart';
import '../../models/local.dart';

class LocalMocks {
  static final List<Local> list = [
    Local(
      local_id: 1,
      name: 'Parque Ambiental',
      description: 'Ponto de encontro perto do lago principal.',
      coordinates: Coordinates(latitude: -25.0945, longitude: -50.1633),
    ),
    Local(
      local_id: 2,
      name: 'Café Dev',
      description: 'Cafeteria com Wi-Fi e mesas grandes para estudo.',
      coordinates: Coordinates(latitude: -25.0850, longitude: -50.1580),
    ),
  ];
}
