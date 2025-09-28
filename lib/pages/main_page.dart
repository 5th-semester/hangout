import 'package:flutter/material.dart';
import 'create_meeting_page.dart';
import 'user_settings.dart';
import 'home_page.dart';
import 'user_page.dart';
import 'my_events_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    MyEventsPage(),
    UserPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToCreateMeeting() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateMeetingPage()));
  }

  Widget? _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 0: // start
        return FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateMeetingPage(),
              ),
            );
          },
          tooltip: 'Criar Evento',
          child: const Icon(Icons.add),
        );
      case 2: // profile
        return FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const UserSettings()),
            );
          },
          tooltip: 'Minhas informações',
          child: const Icon(Icons.settings),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),

      floatingActionButton: _buildFloatingActionButton(),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Meus Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
