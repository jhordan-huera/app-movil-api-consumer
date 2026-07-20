import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/three_dots_loader.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'user_form.dart';
import 'user_detail.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  String _error = '';
  bool _cargando = false;
  List<UserModel> _users = [];

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = '';
    });
    try {
      final data = await UserService.getAll();
      if (mounted) setState(() => _users = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _abrirFormulario({UserModel? user}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserForm(user: user)),
    );
    _cargarDatos();
  }

  Future<void> _borrar({UserModel? user}) async {
    final confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar borrado'),
        content: Text('¿Está seguro de borrar al huésped ${user?.nombres} ${user?.apellidos}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmar == false) {
      return;
    }
    try {
      setState(() => _cargando = true);
      await UserService.delete(user!.idHuesped!);
      _cargarDatos();
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargando = false;
          _error = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Huéspedes',
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110.0), // Increased to avoid overlap with floating bottom nav
        child: FloatingActionButton.extended(
          heroTag: 'fab_users',
          onPressed: () => _abrirFormulario(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Nuevo Huésped', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
      body: _cargando
          ? const Center(child: ThreeDotsLoader())
          : _error.isNotEmpty
              ? Center(
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
                )
              : RefreshIndicator(
                  onRefresh: _cargarDatos,
                  child: _users.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.group_off_outlined, size: 80, color: colorScheme.primary.withValues(alpha: 0.3)),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay huéspedes',
                                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.primary),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Agrega un nuevo huésped tocando el botón inferior.',
                                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth >= 600) {
                              return GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 180), // Extra bottom padding for FAB and Nav
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 400,
                                  mainAxisExtent: 170, // Altura aproximada de la tarjeta
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 0,
                                ),
                                itemCount: _users.length,
                                itemBuilder: (context, index) => _buildUserCard(_users[index], index, colorScheme),
                              );
                            }
                            return ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 180), // Extra bottom padding for FAB and Nav
                              itemCount: _users.length,
                              itemBuilder: (context, index) => _buildUserCard(_users[index], index, colorScheme),
                            );
                          },
                        ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, int index, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserDetail(user: user)),
          );
          if (result == true) {
            _cargarDatos();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_rounded, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.nombres} ${user.apellidos}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.badge_outlined, user.cedula ?? ''),
                    if (user.email != null && user.email!.isNotEmpty)
                      _buildInfoRow(Icons.email_outlined, user.email!),
                    if (user.telefono != null && user.telefono!.isNotEmpty)
                      _buildInfoRow(Icons.phone_outlined, user.telefono!),
                    if (user.nacionalidad != null && user.nacionalidad!.isNotEmpty)
                      _buildInfoRow(Icons.flag_outlined, user.nacionalidad!),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () => _abrirFormulario(user: user),
                    icon: Icon(Icons.edit_rounded, color: colorScheme.primary),
                    tooltip: 'Editar',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  IconButton(
                    onPressed: () => _borrar(user: user),
                    icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
                    tooltip: 'Borrar',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 0.1, delay: (index * 50).ms, duration: 400.ms, curve: Curves.easeOut).fade(duration: 400.ms);
  }
}
