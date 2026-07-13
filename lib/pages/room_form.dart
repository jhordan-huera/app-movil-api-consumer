import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';
import '../widgets/three_dots_loader.dart';

class RoomForm extends StatefulWidget {
  final RoomModel? room;

  const RoomForm({super.key, this.room});

  @override
  State<RoomForm> createState() => _RoomFormState();
}

class _RoomFormState extends State<RoomForm> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _pisoController = TextEditingController();
  final _precioController = TextEditingController();
  final _capacidadController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _tipoSeleccionado = 'SIMPLE';
  String _estadoSeleccionado = 'DISPONIBLE';

  final List<String> _tipos = ['SIMPLE', 'DOBLE', 'FAMILIAR', 'SUITE'];
  final List<String> _estados = ['DISPONIBLE', 'OCUPADA', 'MANTENIMIENTO'];

  bool _cargando = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _numeroController.text = widget.room!.numero ?? '';
      _pisoController.text = widget.room!.piso?.toString() ?? '';
      _precioController.text = widget.room!.precioNoche ?? '';
      _capacidadController.text = widget.room!.capacidad?.toString() ?? '';
      _descripcionController.text = widget.room!.descripcion ?? '';
      
      if (_tipos.contains(widget.room!.tipo)) {
        _tipoSeleccionado = widget.room!.tipo!;
      }
      if (_estados.contains(widget.room!.estado)) {
        _estadoSeleccionado = widget.room!.estado!;
      }
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _pisoController.dispose();
    _precioController.dispose();
    _capacidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = '';
    });

    try {
      final roomData = RoomModel(
        idHabitacion: widget.room?.idHabitacion,
        numero: _numeroController.text,
        tipo: _tipoSeleccionado,
        piso: int.tryParse(_pisoController.text),
        precioNoche: _precioController.text,
        capacidad: int.tryParse(_capacidadController.text),
        descripcion: _descripcionController.text,
        estado: _estadoSeleccionado,
      );

      if (widget.room == null) {
        await RoomService.create(roomData);
      } else {
        await RoomService.update(widget.room!.idHabitacion!, roomData);
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
    final isEditing = widget.room != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Habitación' : 'Nueva Habitación'),
      ),
      body: _cargando
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
                      'Datos de la Habitación',
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
                          child: _buildTextField(
                            controller: _numeroController,
                            label: 'Número',
                            icon: Icons.tag_rounded,
                            keyboardType: TextInputType.text,
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _pisoController,
                            label: 'Piso',
                            icon: Icons.stairs_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildDropdownField(
                      label: 'Tipo de Habitación',
                      icon: Icons.bed_outlined,
                      value: _tipoSeleccionado,
                      items: _tipos,
                      onChanged: (val) => setState(() => _tipoSeleccionado = val!),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _descripcionController,
                      label: 'Descripción (Opcional)',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 32),
                    Text(
                      'Capacidad y Precio',
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
                          child: _buildTextField(
                            controller: _capacidadController,
                            label: 'Capacidad',
                            icon: Icons.person_outline,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _precioController,
                            label: 'Precio / Noche',
                            icon: Icons.attach_money_rounded,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildDropdownField(
                      label: 'Estado',
                      icon: Icons.info_outline_rounded,
                      value: _estadoSeleccionado,
                      items: _estados,
                      onChanged: (val) => setState(() => _estadoSeleccionado = val!),
                    ),

                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _guardar,
                      child: Text(isEditing ? 'Guardar Cambios' : 'Crear Habitación'),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon) : Padding(
          padding: const EdgeInsets.only(bottom: 48.0),
          child: Icon(icon),
        ),
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
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: items.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
