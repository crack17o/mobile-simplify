import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/agent_api_service.dart';
import 'package:mobile_simplify/screens/agent/agent_create_customer_screen.dart';
import 'package:mobile_simplify/screens/agent/agent_client_detail_screen.dart';

/// Liste des clients + recherche par phone. CTA Créer client.
class AgentClientsScreen extends StatefulWidget {
  final AppUser user;

  const AgentClientsScreen({super.key, required this.user});

  @override
  State<AgentClientsScreen> createState() => _AgentClientsScreenState();
}

class _AgentClientsScreenState extends State<AgentClientsScreen> {
  late final AgentApiService _api;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _customers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _api = AgentApiService(accessToken: widget.user.token, useMock: true);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _api.getCustomers(phone: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(), search: null);
    if (mounted) setState(() {
      _customers = list;
      _loading = false;
    });
  }

  void _onSearch(String _) => _load();

  static String _fmtPhone(dynamic v) {
    if (v == null) return '-';
    final s = v.toString();
    if (s.length >= 9) return '+243 ${s.substring(s.length - 9, s.length - 6)} ${s.substring(s.length - 6, s.length - 3)} ${s.substring(s.length - 3)}';
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                onChanged: _onSearch,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Rechercher par téléphone',
                  hintText: '+243 812 345 678',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.primary)),
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: AppTheme.sidebarForeground),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AgentCreateCustomerScreen(user: widget.user)),
                  ).then((_) => _load()),
                  icon: const Icon(Icons.person_add_rounded, size: 22),
                  label: const Text('Créer un client'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _customers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text('Aucun client', style: TextStyle(color: Colors.white54, fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _customers.length,
                        itemBuilder: (context, i) {
                          final c = _customers[i];
                          final phone = (c['phone_number'] ?? c['phone'] ?? '').toString();
                          final name = '${c['first_name'] ?? ''} ${c['last_name'] ?? ''}'.trim();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AgentClientDetailScreen(user: widget.user, phone: phone, customerName: name)),
                                ),
                                borderRadius: BorderRadius.circular(AppTheme.radius),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardDark,
                                    borderRadius: BorderRadius.circular(AppTheme.radius),
                                    border: Border.all(color: AppTheme.cardDarkElevated),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppTheme.primary.withOpacity(0.2),
                                        child: Icon(Icons.person_rounded, color: AppTheme.primary),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name.isEmpty ? 'Client' : name, style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600, fontSize: 16)),
                                            Text(_fmtPhone(phone), style: TextStyle(color: Colors.white54, fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right_rounded, color: Colors.white54),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
