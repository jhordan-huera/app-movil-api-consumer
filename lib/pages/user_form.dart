import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/three_dots_loader.dart';

class UserForm extends StatefulWidget {
  const UserForm({
    super.key,
    this.user,
  });

  final UserModel? user;

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _cedulaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _nacionalidadController = TextEditingController();
  
  bool _guardado = false;
  String _error = '';

  bool get _esEdicion => widget.user != null;
  
  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _cedulaController.text = widget.user!.cedula ?? '';
      _nombresController.text = widget.user!.nombres ?? '';
      _apellidosController.text = widget.user!.apellidos ?? '';
      _emailController.text = widget.user!.email ?? '';
      _telefonoController.text = widget.user!.telefono ?? '';
      _direccionController.text = widget.user!.direccion ?? '';
      _nacionalidadController.text = widget.user!.nacionalidad ?? '';
    } else {
      _nacionalidadController.text = 'Ecuador';
    }
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _nacionalidadController.dispose();
    super.dispose();
  }

  Future<void> _guardarDatos() async {
    final cedula = _cedulaController.text.trim();
    final nombres = _nombresController.text.trim();
    final apellidos = _apellidosController.text.trim();
    final email = _emailController.text.trim();
    final telefono = _telefonoController.text.trim();
    final direccion = _direccionController.text.trim();
    final nacionalidad = _nacionalidadController.text.trim();

    if (cedula.isEmpty || nombres.isEmpty || apellidos.isEmpty) {
      setState(() => _error = 'Cédula, nombres y apellidos son obligatorios');
      return;
    }

    setState(() {
      _guardado = true;
      _error = '';
    });

    try {
      final user = UserModel(
        idHuesped: widget.user?.idHuesped,
        cedula: cedula,
        nombres: nombres,
        apellidos: apellidos,
        email: email.isEmpty ? null : email,
        telefono: telefono.isEmpty ? null : telefono,
        direccion: direccion.isEmpty ? null : direccion,
        nacionalidad: nacionalidad.isEmpty ? 'Ecuador' : nacionalidad,
      );

      if (_esEdicion) {
        final id = widget.user?.idHuesped;
        if (id == null) {
          throw Exception('No se encontró el id del huésped para editar');
        }
        await UserService.update(id, user);
      } else {
        await UserService.create(user);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) setState(() => _guardado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar Huésped' : 'Agregar Huésped',
          style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Información Personal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cedulaController,
                decoration: const InputDecoration(
                  labelText: 'Cédula *',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nombresController,
                      decoration: const InputDecoration(
                        labelText: 'Nombres *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _apellidosController,
                      decoration: const InputDecoration(
                        labelText: 'Apellidos *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Datos de Contacto',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nacionalidadController,
                decoration: const InputDecoration(
                  labelText: 'Nacionalidad',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _guardarDatos(),
              ),
              const SizedBox(height: 32),
              if (_error.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error,
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              ElevatedButton.icon(
                onPressed: _guardado ? null : _guardarDatos,
                icon: _guardado 
                    ? const SizedBox(width: 30, height: 20, child: Center(child: ThreeDotsLoader(color: Colors.white)))
                    : const Icon(Icons.save_rounded),
                label: Text(_esEdicion ? 'Guardar cambios' : 'Registrar huésped'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}