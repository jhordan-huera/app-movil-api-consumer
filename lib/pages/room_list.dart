import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';
import '../widgets/three_dots_loader.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'room_form.dart';
import 'room_detail.dart';

class RoomList extends StatefulWidget {
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  String _error = '';
  bool _cargando = false;
  List<RoomModel> _rooms = [];
  String _filtroActual = 'TODAS'; // TODAS, DISPONIBLES, OCUPADAS, MANTENIMIENTO

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
                      : Column(
                          children: [
                            _buildFilterChips(theme, colorScheme),
                            Expanded(
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: _rooms.length,
                                itemBuilder: (context, index) {
                                  final room = _rooms[index];
                                  if (_filtroActual == 'DISPONIBLES' && room.estado?.toUpperCase() != 'DISPONIBLE') {
                                    return const SizedBox.shrink();
                                  }
                                  if (_filtroActual == 'OCUPADAS' && room.estado?.toUpperCase() != 'OCUPADA') {
                                    return const SizedBox.shrink();
                                  }
                                  if (_filtroActual == 'MANTENIMIENTO' && room.estado?.toUpperCase() != 'MANTENIMIENTO') {
                                    return const SizedBox.shrink();
                                  }
                                  return _buildRoomCard(room, theme, colorScheme)
                                      .animate()
                                      .slideY(begin: 0.1, delay: (index * 50).ms, duration: 400.ms, curve: Curves.easeOut)
                                      .fade(duration: 400.ms);
                                },
                              ),
                            ),
                          ],
                        ),
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton.extended(
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

  Widget _buildFilterChips(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChipOption('Todas', 'TODAS', theme, colorScheme),
          const SizedBox(width: 8),
          _buildChipOption('Disponibles', 'DISPONIBLES', theme, colorScheme, icon: Icons.check_circle_outline),
          const SizedBox(width: 8),
          _buildChipOption('Ocupadas', 'OCUPADAS', theme, colorScheme, icon: Icons.person_outline_rounded),
          const SizedBox(width: 8),
          _buildChipOption('Mantenimiento', 'MANTENIMIENTO', theme, colorScheme, icon: Icons.build_outlined),
        ],
      ),
    );
  }

  Widget _buildChipOption(String label, String value, ThemeData theme, ColorScheme colorScheme, {IconData? icon}) {
    final isSelected = _filtroActual == value;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: isSelected ? Colors.white : colorScheme.primary),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _filtroActual = value);
        }
      },
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : colorScheme.primary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      side: BorderSide(color: isSelected ? Colors.transparent : colorScheme.primary.withValues(alpha: 0.2)),
    );
  }

  Widget _buildRoomCard(RoomModel room, ThemeData theme, ColorScheme colorScheme) {
    final String estadoStr = room.estado?.toUpperCase() ?? '';
    final bool isAvailable = estadoStr == 'DISPONIBLE';
    final bool isMaintenance = estadoStr == 'MANTENIMIENTO';
    
    Color statusColor;
    Color statusBg;
    
    if (isAvailable) {
      statusColor = Colors.green.shade700;
      statusBg = Colors.green.shade50;
    } else if (isMaintenance) {
      statusColor = Colors.orange.shade700;
      statusBg = Colors.orange.shade50;
    } else {
      statusColor = Colors.red.shade700;
      statusBg = Colors.red.shade50;
    }

    return Opacity(
      opacity: isAvailable ? 1.0 : (isMaintenance ? 0.85 : 0.65),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isAvailable 
            ? BorderSide(color: Colors.green.shade400, width: 1.5)
            : (isMaintenance ? BorderSide(color: Colors.orange.shade300, width: 1.5) : BorderSide.none),
        ),
        elevation: isAvailable ? 4 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RoomDetail(room: room)),
            );
            if (result == true) {
              _cargarDatos();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.tipo ?? 'Desconocido',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${room.precioNoche} / noche',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _buildChip(Icons.person_outline, 'Capacidad: ${room.capacidad ?? 0}'),
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
    )));
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
