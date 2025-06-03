import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:testfront/core/models/VignetteCreationDto.dart';
import 'package:testfront/core/models/vignette_dto.dart';
import 'package:testfront/core/providers/VignetteProvider.dart';

class VignetteScreen extends StatefulWidget {
  final int vehiculeId;

  const VignetteScreen({Key? key, required this.vehiculeId}) : super(key: key);

  @override
  _VignetteScreenState createState() => _VignetteScreenState();
}

class _VignetteScreenState extends State<VignetteScreen> {
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVignettes();
  }

  Future<void> _loadVignettes() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await Provider.of<VignetteProvider>(
        context,
        listen: false,
      ).fetchVignettesByVehiculeId(widget.vehiculeId);
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors du chargement: ${e.toString()}';
      });
      _showErrorSnackbar(errorMessage!);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat('dd/MM/yyyy').format(date) : '';

  String _getPaiementStatus(VignetteDto v) {
    final now = DateTime.now();

    if (v.Annee < now.year) return 'Expiré';
    if (v.Annee > now.year) return 'Futur';

    if (v.isValid && v.DatePaiement != null) {
      return v.DatePaiement!.isAfter(v.DateLimitePaiement!)
          ? 'Payé (en retard)'
          : 'Payé (à temps)';
    }

    return now.isAfter(v.DateLimitePaiement!)
        ? 'Non payé (en retard)'
        : 'À payer avant ${_formatDate(v.DateLimitePaiement!)}';
  }

  double _calculateFinalAmount(VignetteDto v) {
    if (v.DatePaiement == null) return v.Montant;
    return v.DatePaiement!.isAfter(v.DateLimitePaiement!)
        ? v.Montant * 1.10
        : v.Montant;
  }

  VignetteDto _generateFutureVignette() {
    final nextYear = DateTime.now().year + 1;
    return VignetteDto(
      VignetteId: 0,
      Annee: nextYear,
      DatePaiement: DateTime.now(),
      DateLimitePaiement: DateTime(nextYear, 3, 31),
      Montant: 0,
      VehiculeId: widget.vehiculeId,
      isValid: false,
    );
  }

  Widget _buildVignetteCard(VignetteDto vignette) {
    final status = _getPaiementStatus(vignette);
    final amount = _calculateFinalAmount(vignette);
    final isLate = status.contains('retard');
    final isFuture = status == 'Futur';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vignette ${vignette.Annee}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isLate
                            ? Colors.red.withOpacity(0.2)
                            : isFuture
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLate
                            ? Icons.warning
                            : isFuture
                            ? Icons.timer
                            : Icons.check_circle,
                        size: 16,
                        color:
                            isLate
                                ? Colors.red
                                : isFuture
                                ? Colors.blue
                                : Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isLate
                                  ? Colors.red
                                  : isFuture
                                  ? Colors.blue
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (vignette.DatePaiement != null)
              _buildInfoRow(
                'Date paiement',
                _formatDate(vignette.DatePaiement),
              ),
            _buildInfoRow(
              'Date limite',
              _formatDate(vignette.DateLimitePaiement!),
            ),
            _buildInfoRow(
              'Montant',
              '${vignette.Montant.toStringAsFixed(3)} Dt',
            ),
            _buildInfoRow('Montant final', '${amount.toStringAsFixed(3)} Dt'),
            if (isLate)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Majoration de 10% appliquée',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (isFuture)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Paiement à effectuer avant ${_formatDate(vignette.DateLimitePaiement!)}',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (vignette.VignetteId != 0)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditVignetteDialog(context, vignette),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteVignette(context, vignette),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVignettes,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vignettes du véhicule'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A5298),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVignettes,
          ),
        ],
      ),
      body: Consumer<VignetteProvider>(
        builder: (context, provider, _) {
          final vignettes = [...provider.vignettes];
          final hasFutureVignette = vignettes.any(
            (v) => v.Annee > DateTime.now().year,
          );

          if (!hasFutureVignette) {
            vignettes.add(_generateFutureVignette());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Rechercher une vignette',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.add,
                        size: 22,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Ajouter",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onPressed: () => _showAddVignetteDialog(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        backgroundColor: const Color(0xFF2A5298),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    vignettes.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                          onRefresh: _loadVignettes,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: vignettes.length,
                            itemBuilder:
                                (ctx, i) => _buildVignetteCard(vignettes[i]),
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final nextYear = DateTime.now().year + 1;
    final dateLimite = DateTime(nextYear, 3, 31);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Aucune vignette enregistrée',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            'Pensez à payer la vignette $nextYear avant le ${_formatDate(dateLimite)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddVignetteDialog(context),
            child: const Text('Ajouter une vignette'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  void _showAddVignetteDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _montantController = TextEditingController();
    final _anneeController = TextEditingController(
      text: DateTime.now().year.toString(),
    );
    DateTime? _selectedDate;

    double _calculateAmount() {
      if (_selectedDate == null || _montantController.text.isEmpty) return 0;
      final montant = double.tryParse(_montantController.text) ?? 0;
      final dateLimite = DateTime(int.parse(_anneeController.text), 3, 31);
      return _selectedDate!.isAfter(dateLimite) ? montant * 1.10 : montant;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nouvelle vignette'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _anneeController,
                        decoration: const InputDecoration(labelText: 'Année'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champs requis';
                          }
                          final year = int.tryParse(value);
                          if (year == null || year <= 0) {
                            return 'Année invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date de paiement',
                          ),
                          child: Text(
                            _selectedDate != null
                                ? _formatDate(_selectedDate!)
                                : 'Sélectionner une date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _montantController,
                        decoration: const InputDecoration(
                          labelText: 'Montant (Dt)',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champs requis';
                          }
                          final amount = double.tryParse(
                            value.replaceAll(',', '.'),
                          );
                          if (amount == null || amount <= 0) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Montant final: ${_calculateAmount().toStringAsFixed(3)} Dt',
                        style: TextStyle(
                          color:
                              _selectedDate != null &&
                                      _selectedDate!.isAfter(
                                        DateTime(
                                          int.parse(_anneeController.text),
                                          3,
                                          31,
                                        ),
                                      )
                                  ? Colors.red
                                  : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedDate != null) {
                      final newVignette = VignetteCreationDto(
                        VehiculeId: widget.vehiculeId,
                        Annee: int.parse(_anneeController.text),
                        Montant: double.parse(
                          _montantController.text.replaceAll(',', '.'),
                        ),
                        DatePaiement: _selectedDate!,
                      );

                      Provider.of<VignetteProvider>(
                        context,
                        listen: false,
                      ).createVignette(newVignette).then((_) {
                        Navigator.pop(context);
                        _loadVignettes();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vignette ajoutée avec succès'),
                          ),
                        );
                      });
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditVignetteDialog(BuildContext context, VignetteDto vignette) {
    final _formKey = GlobalKey<FormState>();
    final _montantController = TextEditingController(
      text: vignette.Montant.toString(),
    );
    final _anneeController = TextEditingController(
      text: vignette.Annee.toString(),
    );
    DateTime? _selectedDate = vignette.DatePaiement;

    double _calculateAmount() {
      if (_selectedDate == null || _montantController.text.isEmpty) return 0;
      final montant = double.tryParse(_montantController.text) ?? 0;
      return _selectedDate!.isAfter(vignette.DateLimitePaiement!)
          ? montant * 1.10
          : montant;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Modifier la vignette'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _anneeController,
                        decoration: const InputDecoration(labelText: 'Année'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champs requis';
                          }
                          final year = int.tryParse(value);
                          if (year == null || year <= 0) {
                            return 'Année invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date de paiement',
                          ),
                          child: Text(
                            _selectedDate != null
                                ? _formatDate(_selectedDate!)
                                : 'Sélectionner une date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _montantController,
                        decoration: const InputDecoration(
                          labelText: 'Montant (DH)',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Champs requis';
                          }
                          final amount = double.tryParse(
                            value.replaceAll(',', '.'),
                          );
                          if (amount == null || amount <= 0) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Montant final: ${_calculateAmount().toStringAsFixed(3)} Dt',
                        style: TextStyle(
                          color:
                              _selectedDate != null &&
                                      _selectedDate!.isAfter(
                                        vignette.DateLimitePaiement!,
                                      )
                                  ? Colors.red
                                  : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité à implémenter'),
                        ),
                      );
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteVignette(BuildContext context, VignetteDto vignette) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
              'Voulez-vous vraiment supprimer la vignette pour l\'année ${vignette.Annee} ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Provider.of<VignetteProvider>(
                      context,
                      listen: false,
                    ).deleteVignette(vignette.VignetteId);
                    _loadVignettes();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vignette supprimée avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
  }
}
