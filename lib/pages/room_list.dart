import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';
import '../widgets/three_dots_loader.dart';
import 'room_form.dart';

class RoomList extends StatefulWidget {
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  String _error = '';
  bool _cargando = false;
  List<RoomModel> _rooms = [];

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = '';
    });
    try {
      final rooms = await RoomService.getAll();
      setState(() {
        _rooms = rooms;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _eliminarHabitacion(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar habitación'),
        content: const Text('¿Estás seguro de que deseas eliminar esta habitación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _cargando = true);
      try {
        await RoomService.delete(id);
        _cargarDatos();
      } catch (e) {
        setState(() {
          _cargando = false;
          _error = 'No se pudo eliminar la habitación';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Habitaciones',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar lista',
            onPressed: _cargarDatos,
          )
        ],
      ),
      body: _cargando
          ? const Center(child: ThreeDotsLoader())
          : _error.isNotEmpty
              ? _buildErrorState(theme, colorScheme)
              : RefreshIndicator(
                  onRefresh: _cargarDatos,
                  child: _rooms.isEmpty
                      ? _buildEmptyState(theme, colorScheme)
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _rooms.length,
                          itemBuilder: (context, index) {
                            return _buildRoomCard(_rooms[index], theme, colorScheme);
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_rooms',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RoomForm()),
          );
          if (result == true) {
            _cargarDatos();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Habitación'),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Ocurrió un error',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargarDatos,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bed_outlined, size: 80, color: colorScheme.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'No hay habitaciones',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomCard(RoomModel room, ThemeData theme, ColorScheme colorScheme) {
    final bool isAvailable = room.estado?.toUpperCase() == 'DISPONIBLE';
    final Color statusColor = isAvailable ? Colors.green.shade600 : colorScheme.error;
    final Color statusBg = isAvailable ? Colors.green.shade50 : colorScheme.errorContainer;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          room.numero ?? '?',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.tipo ?? 'Desconocido',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${room.precioNoche} / noche',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    room.estado ?? 'N/A',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            if (room.descripcion != null && room.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                room.descripcion!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildChip(Icons.person_outline, 'Capacidad: ${room.capacidad ?? 0}'),
                      const SizedBox(width: 12),
                      _buildChip(Icons.stairs_outlined, 'Piso ${room.piso ?? 0}'),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: colorScheme.primary,
                      tooltip: 'Editar',
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RoomForm(room: room)),
                        );
                        if (result == true) {
                          _cargarDatos();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: colorScheme.error,
                      tooltip: 'Eliminar',
                      onPressed: () => _eliminarHabitacion(room.idHabitacion!),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
