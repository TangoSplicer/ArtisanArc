import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/personal_app_bar.dart';
import '../../../core/widgets/searchable_selection_field.dart';
import '../data/wholesale_model.dart';
import '../domain/wholesale_service.dart';

class WholesalePartnerEditorScreen extends StatefulWidget {
  const WholesalePartnerEditorScreen({super.key, this.partnerId});

  final String? partnerId;

  @override
  State<WholesalePartnerEditorScreen> createState() =>
      _WholesalePartnerEditorScreenState();
}

class _WholesalePartnerEditorScreenState
    extends State<WholesalePartnerEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final WholesaleService _service = GetIt.I<WholesaleService>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _commissionController = TextEditingController(text: '30');
  WholesalePartner? _existing;
  String _partnerType = 'wholesale';
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditing => widget.partnerId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_isEditing) {
      try {
        _existing = await _service.getPartnerById(widget.partnerId!);
        final partner = _existing;
        if (partner != null) {
          _nameController.text = partner.name;
          _contactController.text = partner.contactName;
          _emailController.text = partner.email;
          _phoneController.text = partner.phone;
          _addressController.text = partner.address;
          _commissionController.text =
              partner.commissionRatePercent.toStringAsFixed(1);
          _partnerType = partner.partnerType;
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not load partner: $error')),
          );
        }
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final commission = double.tryParse(_commissionController.text.trim());
    if (commission == null || commission < 0 || commission > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Partner share must be between 0% and 100%.')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await _service.savePartner(
        id: widget.partnerId,
        name: _nameController.text,
        contactName: _contactController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        partnerType: _partnerType,
        commissionRatePercent: commission,
        existing: _existing,
      );
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save partner: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: PersonalAppBar(
        title: Text(_isEditing ? 'Edit partner' : 'New partner'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Keep retailer and venue details locally. No account, cloud sync, or payment processing is used.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Shop or venue name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.storefront_outlined),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a shop or venue name'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  SearchableSelectionField<String>(
                    options: const ['wholesale', 'consignment'],
                    value: _partnerType,
                    labelText: 'Relationship type *',
                    hintText: 'Choose wholesale or consignment',
                    itemLabel: (value) => value == 'wholesale'
                        ? 'Wholesale — retailer buys stock'
                        : 'Consignment — venue sells on your behalf',
                    itemSubtitle: (value) => value == 'wholesale'
                        ? 'Record agreed wholesale prices and payment due dates.'
                        : 'Track stock placed, sell-through, returns, and partner share.',
                    searchTerms: (value) => [value],
                    onChanged: (value) =>
                        setState(() => _partnerType = value ?? 'wholesale'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _commissionController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Partner share / commission (%) *',
                      helperText:
                          'For wholesale this can record a negotiated partner share; for consignment it is the venue commission.',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent_outlined),
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(value?.trim() ?? '');
                      if (parsed == null || parsed < 0 || parsed > 100) {
                        return 'Enter a percentage from 0 to 100';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact name (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email or contact note (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Address or venue location (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'Saving…' : 'Save partner'),
                  ),
                ],
              ),
            ),
    );
  }
}
