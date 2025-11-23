import '../repositories/local_repository.dart';
import '../models/local.dart';
import '../models/coordinates.dart';

class LocalService {
  final LocalRepository repository;

  LocalService({required this.repository});

  Future<Local?> getLocalById(String id) => repository.getLocalById(id);

  Future<List<Local>> getClosestLocals({
    required Coordinates userCoordinates,
    int limit = 5,
  }) => repository.getClosestLocals(
    userCoordinates: userCoordinates,
    limit: limit,
  );

  Future<Local> createLocal({
    required String name,
    required String description,
    required Coordinates coordinates,
  }) => repository.createLocal(
    name: name,
    description: description,
    coordinates: coordinates,
  );
}
