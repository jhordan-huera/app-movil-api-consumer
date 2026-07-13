import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import '../widgets/three_dots_loader.dart';
import 'reservation_form.dart';

class ReservationList extends StatefulWidget {
  const ReservationList({super.key});

  @override
  State<ReservationList> createState() => _ReservationListState();
}

class _ReservationListState extends State<ReservationList> {
  String _error = '';
  bool _cargando = false;
  List<ReservationModel> _reservations = [];

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = '';
    });
    try {
      final reservations = await ReservationService.getAll();
      setState(() {
        _reservations = reservations;
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

  Future<void> _eliminarReserva(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reserva'),
        content: const Text('¿Estás seguro de que deseas eliminar esta reserva?'),
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
        await ReservationService.delete(id);
        _cargarDatos();
      } catch (e) {
        setState(() {
          _cargando = false;
          _error = 'No se pudo eliminar la reserva';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reservas',
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
                  child: _reservations.isEmpty
                      ? _buildEmptyState(theme, colorScheme)
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _reservations.length,
                          itemBuilder: (context, index) {
                            return _buildReservationCard(_reservations[index], theme, colorScheme);
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_reservations',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReservationForm()),
          );
          if (result == true) {
            _cargarDatos();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Reserva'),
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
              Icon(Icons.event_busy_outlined, size: 80, color: colorScheme.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'No hay reservas',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReservationCard(ReservationModel reservation, ThemeData theme, ColorScheme colorScheme) {
    Color statusColor;
    Color statusBg;
    
    switch (reservation.estado?.toUpperCase()) {
      case 'CONFIRMADA':
        statusColor = Colors.blue.shade700;
        statusBg = Colors.blue.shade50;
        break;
      case 'CHECKIN':
        statusColor = Colors.green.shade700;
        statusBg = Colors.green.shade50;
        break;
      case 'CHECKOUT':
        statusColor = Colors.purple.shade700;
        statusBg = Colors.purple.shade50;
        break;
      case 'CANCELADA':
        statusColor = colorScheme.error;
        statusBg = colorScheme.errorContainer;
        break;
      default:
        statusColor = Colors.grey.shade700;
        statusBg = Colors.grey.shade100;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reservation.codigo ?? '#UNKNOWN',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    reservation.estado ?? 'N/A',
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
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(Icons.person_rounded, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.huespedNombre ?? 'Huésped desconocido',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'C.I: ${reservation.huespedCedula ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${reservation.total ?? '0.00'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${reservation.numNoches ?? 0} noches',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDateColumn('Check-in', _formatDate(reservation.fechaCheckin), Icons.flight_land_rounded),
                      const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFFCBD5E1)),
                      _buildDateColumn('Check-out', _formatDate(reservation.fechaCheckout), Icons.flight_takeoff_rounded),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: colorScheme.primary,
                      tooltip: 'Editar',
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReservationForm(reservation: reservation)),
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
                      onPressed: () => _eliminarReserva(reservation.idReserva!),
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

  Widget _buildDateColumn(String label, String date, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              date,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
