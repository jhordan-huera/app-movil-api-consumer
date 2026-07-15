import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_model.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import '../widgets/three_dots_loader.dart';
import 'user_form.dart';
import 'reservation_detail.dart';

class UserDetail extends StatefulWidget {
  final UserModel user;

  const UserDetail({super.key, required this.user});

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  late UserModel _user;
  bool _cargandoHistorial = true;
  String _error = '';
  List<ReservationModel> _historial = [];

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _cargandoHistorial = true;
      _error = '';
    });
    try {
      final todas = await ReservationService.getAll();
      setState(() {
        _historial = todas.where((r) => r.idHuesped == _user.idHuesped).toList();
        // Ordenar de más reciente a más antigua
        _historial.sort((a, b) {
          final dateA = DateTime.tryParse(a.fechaReserva ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b.fechaReserva ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });
        _cargandoHistorial = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo cargar el historial: $e';
        _cargandoHistorial = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Huésped'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar Huésped',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserForm(user: _user)),
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_user.nombres} ${_user.apellidos}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'CI: ${_user.cedula}',
                      style: TextStyle(
                        color: colorScheme.secondary.withAlpha(200),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), // Smoother radius
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información de Contacto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoTile(Icons.email_outlined, 'Correo', _user.email, colorScheme),
                    _buildInfoTile(Icons.phone_outlined, 'Teléfono', _user.telefono, colorScheme),
                    _buildInfoTile(Icons.map_outlined, 'Dirección', _user.direccion, colorScheme),
                    _buildInfoTile(Icons.flag_outlined, 'Nacionalidad', _user.nacionalidad, colorScheme),

                    const SizedBox(height: 32),
                    const Text(
                      'Historial de Reservas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHistorialList(theme, colorScheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, curve: Curves.easeOut);
  }

  Widget _buildInfoTile(IconData icon, String label, String? value, ColorScheme colorScheme) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialList(ThemeData theme, ColorScheme colorScheme) {
    if (_cargandoHistorial) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: ThreeDotsLoader(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error),
            const SizedBox(width: 12),
            Expanded(child: Text(_error, style: TextStyle(color: colorScheme.error))),
          ],
        ),
      );
    }

    if (_historial.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off, size: 48, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            const Text(
              'No hay reservas registradas',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _historial.length,
      itemBuilder: (context, index) {
        final reserva = _historial[index];
        final bool isConfirmada = reserva.estado?.toUpperCase() == 'CONFIRMADA';
        final bool isCheckin = reserva.estado?.toUpperCase() == 'CHECKIN';
        final bool isCheckout = reserva.estado?.toUpperCase() == 'CHECKOUT';
        
        Color estadoColor = Colors.grey;
        if (isConfirmada) estadoColor = Colors.green;
        if (isCheckin) estadoColor = colorScheme.primary;
        if (isCheckout) estadoColor = Colors.purple;

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
                MaterialPageRoute(builder: (context) => ReservationDetail(reservation: reserva)),
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
                          'Reserva #${reserva.codigo ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(reserva.fechaCheckin),
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
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
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Desconocido';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }
}
