import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/reservation_model.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../services/reservation_service.dart';
import '../services/user_service.dart';
import '../services/room_service.dart';
import '../widgets/three_dots_loader.dart';

class ReservationForm extends StatefulWidget {
  final ReservationModel? reservation;

  const ReservationForm({super.key, this.reservation});

  @override
  State<ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _codigoController = TextEditingController();
  final _nochesController = TextEditingController();
  final _subtotalController = TextEditingController();
  final _impuestoController = TextEditingController();
  final _totalController = TextEditingController();

  DateTime? _fechaCheckin;
  DateTime? _fechaCheckout;
  
  String? _idHuespedSeleccionado;
  String? _idHabitacionSeleccionada;
  String _estadoSeleccionado = 'CONFIRMADA';

  final List<String> _estados = ['CONFIRMADA', 'CHECKIN', 'CHECKOUT', 'CANCELADA'];
  
  bool _cargando = false;
  bool _cargandoInicial = true;
  String _error = '';
  List<UserModel> _huespedes = [];
  List<RoomModel> _habitaciones = [];

  @override
  void initState() {
    super.initState();
    _cargarHuespedesYHabitaciones();
    
    if (widget.reservation != null) {
      _codigoController.text = widget.reservation!.codigo ?? '';
      _nochesController.text = widget.reservation!.numNoches?.toString() ?? '';
      _subtotalController.text = widget.reservation!.subtotal ?? '';
      _impuestoController.text = widget.reservation!.impuesto ?? '';
      _totalController.text = widget.reservation!.total ?? '';
      
      _idHuespedSeleccionado = widget.reservation!.idHuesped;
      _idHabitacionSeleccionada = widget.reservation!.idHabitacion;
      
      if (_estados.contains(widget.reservation!.estado?.toUpperCase())) {
        _estadoSeleccionado = widget.reservation!.estado!.toUpperCase();
      }

      if (widget.reservation!.fechaCheckin != null) {
        _fechaCheckin = DateTime.tryParse(widget.reservation!.fechaCheckin!);
      }
      if (widget.reservation!.fechaCheckout != null) {
        _fechaCheckout = DateTime.tryParse(widget.reservation!.fechaCheckout!);
      }
    } else {
      // Auto-generar código para nueva reserva
      final randomNum = Random().nextInt(10000).toString().padLeft(4, '0');
      _codigoController.text = 'RES-${DateTime.now().year}-$randomNum';
    }
  }

  Future<void> _cargarHuespedesYHabitaciones() async {
    try {
      final huespedesReq = UserService.getAll();
      final habitacionesReq = RoomService.getAll();
      Future<ReservationModel?> reservaReq = Future.value(null);
      
      if (widget.reservation != null && widget.reservation!.idReserva != null) {
        reservaReq = ReservationService.getById(widget.reservation!.idReserva!);
      }
      
      final results = await Future.wait([huespedesReq, habitacionesReq, reservaReq]);
      
      if (!mounted) return;

      setState(() {
        _huespedes = results[0] as List<UserModel>;
        final allRooms = results[1] as List<RoomModel>;
        final fullReserva = results[2] as ReservationModel?;
        
        if (fullReserva != null && fullReserva.idHabitacion != null) {
          _idHabitacionSeleccionada = fullReserva.idHabitacion;
        }

        // Filtrar habitaciones disponibles o la que ya tiene asignada esta reserva
        _habitaciones = allRooms.where((r) => 
          r.estado?.toUpperCase() == 'DISPONIBLE' || 
          r.idHabitacion == _idHabitacionSeleccionada
        ).toList();
        
        _cargandoInicial = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargandoInicial = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar datos auxiliares')),
      );
    }
  }

  void _calcularTotales() {
    if (_idHabitacionSeleccionada == null || _nochesController.text.isEmpty) return;
    
    final room = _habitaciones.cast<RoomModel?>().firstWhere(
      (r) => r?.idHabitacion == _idHabitacionSeleccionada, 
      orElse: () => null
    );
    
    if (room != null && room.precioNoche != null) {
      final precioNoche = double.tryParse(room.precioNoche!) ?? 0;
      final noches = int.tryParse(_nochesController.text) ?? 1;
      
      final subtotal = precioNoche * noches;
      final impuesto = subtotal * 0.12; // 12% IVA
      final total = subtotal + impuesto;
      
      _subtotalController.text = subtotal.toStringAsFixed(2);
      _impuestoController.text = impuesto.toStringAsFixed(2);
      _totalController.text = total.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nochesController.dispose();
    _subtotalController.dispose();
    _impuestoController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(bool isCheckin) async {
    final initialDate = isCheckin 
      ? (_fechaCheckin ?? DateTime.now()) 
      : (_fechaCheckout ?? (_fechaCheckin?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1))));
      
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isCheckin) {
          _fechaCheckin = picked;
          // Autocalcular checkout si está antes del checkin
          if (_fechaCheckout != null && _fechaCheckout!.isBefore(_fechaCheckin!)) {
            _fechaCheckout = _fechaCheckin!.add(const Duration(days: 1));
          }
        } else {
          _fechaCheckout = picked;
        }
        
        // Autocalcular noches
        if (_fechaCheckin != null && _fechaCheckout != null) {
          final difference = _fechaCheckout!.difference(_fechaCheckin!).inDays;
          _nochesController.text = difference > 0 ? difference.toString() : '1';
          _calcularTotales();
        }
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaCheckin == null || _fechaCheckout == null) {
      setState(() => _error = 'Por favor seleccione las fechas de Check-in y Check-out');
      return;
    }
    if (_idHuespedSeleccionado == null) {
      setState(() => _error = 'Por favor seleccione un huésped');
      return;
    }
    if (_idHabitacionSeleccionada == null) {
      setState(() => _error = 'Por favor seleccione una habitación');
      return;
    }

    setState(() {
      _cargando = true;
      _error = '';
    });

    try {
      final room = _habitaciones.cast<RoomModel?>().firstWhere(
        (r) => r?.idHabitacion == _idHabitacionSeleccionada, 
        orElse: () => null
      );

      final resData = ReservationModel(
        idReserva: widget.reservation?.idReserva,
        codigo: _codigoController.text.isEmpty ? 'NUEVA' : _codigoController.text,
        fechaReserva: widget.reservation?.fechaReserva ?? DateTime.now().toIso8601String(),
        fechaCheckin: _fechaCheckin!.toIso8601String(),
        fechaCheckout: _fechaCheckout!.toIso8601String(),
        numNoches: int.tryParse(_nochesController.text),
        subtotal: _subtotalController.text,
        impuesto: _impuestoController.text,
        total: _totalController.text,
        estado: _estadoSeleccionado,
        idHuesped: _idHuespedSeleccionado,
        idHabitacion: _idHabitacionSeleccionada,
        detalles: room != null ? [
          {
            "id_habitacion": room.idHabitacion,
            "precio_noche": double.tryParse(room.precioNoche ?? '0') ?? 0.0,
          }
        ] : null,
      );

      if (widget.reservation == null) {
        await ReservationService.create(resData);
      } else {
        await ReservationService.update(widget.reservation!.idReserva!, resData);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.reservation != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Reserva' : 'Nueva Reserva'),
      ),
      body: _cargandoInicial 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ThreeDotsLoader(),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando datos...',
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : _cargando
          ? const Center(child: ThreeDotsLoader())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error,
                                style: TextStyle(color: theme.colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Text(
                      'Huésped y Estado',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _huespedes.any((h) => h.idHuesped == _idHuespedSeleccionado) ? _idHuespedSeleccionado : null,
                      decoration: const InputDecoration(
                        labelText: 'Huésped Titular',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: _huespedes.map((UserModel h) {
                        return DropdownMenuItem(
                          value: h.idHuesped,
                          child: Text(
                            '${h.nombres} ${h.apellidos}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _idHuespedSeleccionado = val),
                      validator: (v) => v == null ? 'Seleccione un huésped' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _habitaciones.any((r) => r.idHabitacion == _idHabitacionSeleccionada) ? _idHabitacionSeleccionada : null,
                      decoration: const InputDecoration(
                        labelText: 'Habitación Asignada',
                        prefixIcon: Icon(Icons.bed_outlined),
                      ),
                      items: _habitaciones.map((RoomModel r) {
                        return DropdownMenuItem(
                          value: r.idHabitacion,
                          child: Text(
                            'Habitación ${r.numero} - ${r.tipo} (\$${r.precioNoche}/noche)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _idHabitacionSeleccionada = val);
                        _calcularTotales();
                      },
                      validator: (v) => v == null ? 'Seleccione una habitación' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildDropdownField(
                      label: 'Estado',
                      icon: Icons.info_outline_rounded,
                      value: _estadoSeleccionado,
                      items: _estados,
                      onChanged: (val) => setState(() => _estadoSeleccionado = val!),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _codigoController,
                      label: 'Código de Reserva',
                      icon: Icons.numbers_rounded,
                      keyboardType: TextInputType.text,
                      readOnly: true,
                    ),

                    const SizedBox(height: 32),
                    Text(
                      'Fechas de Estancia',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _seleccionarFecha(true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Check-in',
                                prefixIcon: Icon(Icons.flight_land_rounded),
                              ),
                              child: Text(
                                _fechaCheckin != null ? DateFormat('dd/MM/yyyy').format(_fechaCheckin!) : 'Seleccionar',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _seleccionarFecha(false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Check-out',
                                prefixIcon: Icon(Icons.flight_takeoff_rounded),
                              ),
                              child: Text(
                                _fechaCheckout != null ? DateFormat('dd/MM/yyyy').format(_fechaCheckout!) : 'Seleccionar',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    Text(
                      'Costos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildTextField(
                            controller: _nochesController,
                            label: 'Noches',
                            icon: Icons.nightlight_outlined,
                            keyboardType: TextInputType.number,
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _subtotalController,
                            label: 'Subtotal (\$)',
                            icon: Icons.attach_money_rounded,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            readOnly: true,
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _impuestoController,
                            label: 'Impuestos (\$)',
                            icon: Icons.receipt_long_rounded,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            readOnly: true,
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _totalController,
                            label: 'Total (\$)',
                            icon: Icons.price_check_rounded,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            readOnly: true,
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _guardar,
                      child: Text(isEditing ? 'Guardar Cambios' : 'Crear Reserva'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: items.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
