import 'package:flutter/material.dart';
import '../models/room_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import 'room_form.dart';
import 'reservation_detail.dart';
import '../widgets/three_dots_loader.dart';

class RoomDetail extends StatefulWidget {
  final RoomModel room;

  const RoomDetail({super.key, required this.room});

  @override
  State<RoomDetail> createState() => _RoomDetailState();
}

class _RoomDetailState extends State<RoomDetail> {
  late RoomModel _room;
  List<ReservationModel> _history = [];
  bool _isLoadingHistory = true;
  String _historyError = '';

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final allReservations = await ReservationService.getAll();
      if (mounted) {
        setState(() {
          _history = allReservations.where((r) => r.idHabitacion == _room.idHabitacion).toList();
          _history.sort((a, b) {
            final dateA = DateTime.tryParse(a.fechaReserva ?? '') ?? DateTime(0);
            final dateB = DateTime.tryParse(b.fechaReserva ?? '') ?? DateTime(0);
            return dateB.compareTo(dateA); // Descendente
          });
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _historyError = 'Error al cargar historial';
          _isLoadingHistory = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final String estadoStr = _room.estado?.toUpperCase() ?? '';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Habitación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar habitación',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RoomForm(room: _room)),
              );
              if (result == true) {
                if (!context.mounted) return;
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              color: colorScheme.primary,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _room.numero ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          estadoStr,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _room.tipo ?? 'Tipo desconocido',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_room.precioNoche} por noche',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), // Smoother radius
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_room.descripcion != null && _room.descripcion!.isNotEmpty) ...[
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _room.descripcion!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    
                    const Text(
                      'Características',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureItem(
                            icon: Icons.person_outline,
                            label: 'Capacidad',
                            value: '${_room.capacidad ?? 0} pax',
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFeatureItem(
                            icon: Icons.stairs_outlined,
                            label: 'Piso',
                            value: '${_room.piso ?? 0}',
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Historial de Ocupación',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingHistory)
                      const Center(child: Padding(padding: EdgeInsets.all(16.0), child: ThreeDotsLoader()))
                    else if (_historyError.isNotEmpty)
                      Center(child: Text(_historyError, style: const TextStyle(color: Colors.red)))
                    else if (_history.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No hay historial para esta habitación', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final reserva = _history[index];
                          final bool isConfirmada = reserva.estado?.toUpperCase() == 'CONFIRMADA';
                          final bool isCheckin = reserva.estado?.toUpperCase() == 'CHECKIN';
                          final bool isCheckout = reserva.estado?.toUpperCase() == 'CHECKOUT';
                          
                          Color estadoColor = Colors.grey;
                          if (isConfirmada) estadoColor = Colors.green;
                          if (isCheckin) estadoColor = colorScheme.primary;
                          if (isCheckout) estadoColor = Colors.purple;

                          final checkinStr = _formatShortDate(reserva.fechaCheckin);
                          final checkoutStr = _formatShortDate(reserva.fechaCheckout);

                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ReservationDetail(
                                    reservation: reserva,
                                    roomName: 'Hab. ${_room.numero} - ${_room.tipo}',
                                  )),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: estadoColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.bookmark, color: estadoColor),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            reserva.huespedNombre ?? 'Huésped N/A',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$checkinStr a $checkoutStr',
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: estadoColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        reserva.estado ?? 'N/A',
                                        style: TextStyle(
                                          color: estadoColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Detalles Técnicos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_circle_outline, color: colorScheme.secondary),
                      ),
                      title: const Text('Fecha de registro', style: TextStyle(fontSize: 14)),
                      subtitle: Text(
                        _formatDate(_room.createdAt),
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.update, color: colorScheme.secondary),
                      ),
                      title: const Text('Última actualización', style: TextStyle(fontSize: 14)),
                      subtitle: Text(
                        _formatDate(_room.updatedAt),
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, curve: Curves.easeOut);
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Desconocido';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }

  String _formatShortDate(String? isoDate) {
    if (isoDate == null) return 'N/A';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMM', 'es').format(date);
    } catch (e) {
      return isoDate;
    }
  }
}
