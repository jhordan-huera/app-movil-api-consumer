import 'package:flutter/material.dart';
import '../models/reservation_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/reservation_service.dart';
import '../services/room_service.dart';
import '../services/user_service.dart';

class ReservationDetail extends StatefulWidget {
  final ReservationModel reservation;
  final String roomName;

  const ReservationDetail({super.key, required this.reservation, this.roomName = 'N/A'});

  @override
  State<ReservationDetail> createState() => _ReservationDetailState();
}

class _ReservationDetailState extends State<ReservationDetail> {
  late ReservationModel _reservation;
  bool _isLoading = false;
  String _resolvedRoomName = 'N/A';
  String _resolvedGuestName = 'N/A';
  String _resolvedGuestCedula = 'N/A';

  @override
  void initState() {
    super.initState();
    _reservation = widget.reservation;
    _resolvedRoomName = widget.roomName;
    _resolvedGuestName = _reservation.huespedNombre ?? 'N/A';
    _resolvedGuestCedula = _reservation.huespedCedula ?? 'N/A';

    if (_resolvedRoomName == 'N/A' && _reservation.idHabitacion != null) {
      _fetchRoomDetails();
    }
    
    if ((_resolvedGuestName == 'N/A' || _resolvedGuestName.isEmpty) && _reservation.idHuesped != null) {
      _fetchGuestDetails();
    }
  }

  Future<void> _fetchGuestDetails() async {
    try {
      final guest = await UserService.getById(_reservation.idHuesped!);
      if (mounted) {
        setState(() {
          _resolvedGuestName = '${guest.nombres ?? ''} ${guest.apellidos ?? ''}'.trim();
          if (_resolvedGuestName.isEmpty) _resolvedGuestName = 'N/A';
          _resolvedGuestCedula = guest.cedula ?? 'N/A';
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _fetchRoomDetails() async {
    try {
      final room = await RoomService.getById(_reservation.idHabitacion!);
      if (mounted) {
        setState(() {
          _resolvedRoomName = 'Hab. ${room.numero} - ${room.tipo}';
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _updateEstado(String nuevoEstado) async {
    setState(() => _isLoading = true);
    try {
      final updatedJson = _reservation.toJson();
      updatedJson['estado'] = nuevoEstado;
      final newReservation = ReservationModel.fromJson(updatedJson);
      
      // We assume idReserva is available, but if not we can use id directly if the API supports it.
      // Looking at reservation_service, the update method uses the id parameter. Let's use idReserva.
      final id = _reservation.idReserva ?? _reservation.codigo!;
      final result = await ReservationService.update(id, newReservation);
      
      setState(() {
        _reservation = result;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado actualizado correctamente')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final reservation = _reservation;

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Detalles de la Reserva'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CÓDIGO DE RESERVA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                reservation.codigo ?? '#UNKNOWN',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: _updateEstado,
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'PENDIENTE', child: Text('PENDIENTE')),
                          const PopupMenuItem(value: 'CONFIRMADA', child: Text('CONFIRMADA')),
                          const PopupMenuItem(value: 'CHECKIN', child: Text('CHECKIN')),
                          const PopupMenuItem(value: 'CHECKOUT', child: Text('CHECKOUT')),
                          const PopupMenuItem(value: 'CANCELADA', child: Text('CANCELADA')),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: _isLoading
                              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: statusColor))
                              : Row(
                                  children: [
                                    Text(
                                      reservation.estado ?? 'N/A',
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.edit_outlined, size: 14, color: statusColor),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Color(0xFFF1F5F9)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Check-in',
                          _formatDate(reservation.fechaCheckin),
                          Icons.flight_land_rounded,
                          colorScheme,
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: const Color(0xFFE2E8F0),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Check-out',
                          _formatDate(reservation.fechaCheckout),
                          Icons.flight_takeoff_rounded,
                          colorScheme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Huesped Info
            _buildSection(
              title: 'Información del Huésped',
              icon: Icons.person_outline_rounded,
              colorScheme: colorScheme,
              child: Column(
                children: [
                  _buildDetailRow('Nombre completo', _resolvedGuestName),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildDetailRow('Cédula de identidad', _resolvedGuestCedula),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detalles Adicionales
            _buildSection(
              title: 'Detalles de la Reserva',
              icon: Icons.info_outline_rounded,
              colorScheme: colorScheme,
              child: Column(
                children: [
                  _buildDetailRow('Número de Noches', '${reservation.numNoches ?? 0} noches'),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  if (reservation.observaciones != null && reservation.observaciones!.isNotEmpty)
                    _buildDetailRow('Observaciones', reservation.observaciones!),
                  if (reservation.observaciones != null && reservation.observaciones!.isNotEmpty)
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildDetailRow('Habitación Asignada', _resolvedRoomName),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pricing
            _buildSection(
              title: 'Resumen de Pago',
              icon: Icons.receipt_long_outlined,
              colorScheme: colorScheme,
              child: Column(
                children: [
                  _buildDetailRow('Subtotal', '\$${reservation.subtotal ?? '0.00'}'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Impuestos', '\$${reservation.impuesto ?? '0.00'}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a Pagar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '\$${reservation.total ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, curve: Curves.easeOut);
  }

  Widget _buildSection({required String title, required IconData icon, required ColorScheme colorScheme, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
