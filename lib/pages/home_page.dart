import 'package:flutter/material.dart';
import 'user_list.dart';
import 'room_list.dart';
import 'reservation_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    UserList(),
    RoomList(),
    ReservationList(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.people_alt_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.people_alt_rounded),
              ),
              label: 'Huéspedes',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.bed_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.bed_rounded),
              ),
              label: 'Habitaciones',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.event_note_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.event_note_rounded),
              ),
              label: 'Reservas',
            ),
          ],
        ),
      ),
    );
  }
}
