import '../../models/meeting.dart';
import 'local_mocks.dart';
import 'user_mocks.dart';

class MeetingMocks {
  static final List<Meeting> list = [
    Meeting(
      meeting_id: 1,
      name: 'Jogo de Vôlei no Parque',
      description:
          'Vamos fechar 5 pessoas para jogar vôlei de areia. Nível iniciante!',
      datetime: DateTime(2025, 9, 10, 16, 30),
      local: LocalMocks.list[0],
      users: [UserMocks.list[0], UserMocks.list[1]],
    ),
    Meeting(
      meeting_id: 2,
      name: 'Estudo de Flutter em Grupo',
      description: 'Foco em gerenciamento de estado com Provider e Riverpod.',
      datetime: DateTime(2025, 9, 12, 19, 0),
      local: LocalMocks.list[1],
      users: [UserMocks.list[2], UserMocks.list[3], UserMocks.list[0]],
    ),
    Meeting(
      meeting_id: 3,
      name: 'Happy Hour Pós-Estudo',
      description: 'Depois do estudo, um happy hour para relaxar!',
      datetime: DateTime(2025, 9, 12, 21, 0),
      local: LocalMocks.list[1],
      users: [],
    ),
  ];
}
