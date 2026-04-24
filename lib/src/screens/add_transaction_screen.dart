import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_scope.dart';
import '../utils/app_formatters.dart';
import '../widgets/common_widgets.dart';
import 'new_allocation_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, this.existing});

  final LedgerEntry? existing;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  int _selectedTab = 0;
  String _category = 'Transport';
  double _amount = 0;
  DateTime _date = DateTime.now();

  static const _tabs = ['Manual', 'Capture', 'Upload Data'];
  static const _categories = ['Transport', 'Food', 'Home', 'Shop', 'Other'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _selectedTab = _tabs.indexOf(existing?.inputMode ?? 'Manual');
    if (_selectedTab < 0) _selectedTab = 0;
    _category = existing?.category ?? 'Transport';
    _amount = existing?.amount.abs() ?? 0;
    _date = existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      body: PagePadding(
        child: Column(
          children: [
            BackHeader(title: 'Add Transaction'),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      WhiteCard(
                        child: Column(
                          children: [
                            Row(
                              children: List.generate(_tabs.length, (index) {
                                final selected = index == _selectedTab;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(_tabs[index]),
                                      selected: selected,
                                      onSelected: (_) =>
                                          setState(() => _selectedTab = index),
                                      showCheckmark: false,
                                      side: BorderSide.none,
                                      selectedColor: const Color(0xFFDDE8FF),
                                      backgroundColor: const Color(0xFFF5F7FB),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 18),
                            if (_selectedTab == 0) ...[
                              AppTextField(
                                label: 'Transaction title',
                                controller: _titleController,
                                hint: 'e.g. Flight to ABJ',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a transaction title';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                initialValue: _category,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                ),
                                items: _categories
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(item),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _category = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 14),
                              DatePickerField(
                                label: 'Date',
                                value: AppFormatters.shortDate(_date),
                                onTap: _pickDate,
                              ),
                            ] else ...[
                              EmptyStateCard(
                                title: '${_tabs[_selectedTab]} mode selected',
                                message:
                                    'The architecture screenshots say these capture modes exist. This screen now reacts to the selection, and you can extend each mode with scanner or uploader logic next.',
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      WhiteCard(
                        onTap: _pickAmount,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionLabel('AMOUNT'),
                                  SizedBox(height: 16),
                                  Text(
                                    'Tap to set expense amount',
                                    style: TextStyle(
                                      color: Color(0xFF667085),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1148A5),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'USD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                AppFormatters.compactMoney(_amount),
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1148A5),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      WhiteCard(
                        child: AppTextField(
                          label: 'Notes',
                          controller: _notesController,
                          hint: 'What was this for?',
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ActionBottomBar(
              children: [
                PrimaryButton(
                  label: isEditing ? 'Update Transaction' : 'Save Up!',
                  onPressed: _save,
                ),
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAmount() async {
    final result = await Navigator.of(context).push<double>(
      MaterialPageRoute<double>(
        builder: (_) => NumericPadScreen(
          title: 'Transaction Amount',
          initialValue: _amount,
          actionLabel: 'Use Amount',
        ),
      ),
    );

    if (result != null) {
      setState(() => _amount = result);
    }
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: _date,
    );

    if (!mounted) return;
    if (result != null) {
      setState(() => _date = result);
    }
  }

  void _save() {
    if (_selectedTab == 0 && !_formKey.currentState!.validate()) return;
    if (_amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please set an amount')));
      return;
    }

    final title = _titleController.text.trim().isEmpty
        ? '${_tabs[_selectedTab]} Transaction'
        : _titleController.text.trim();

    final item = LedgerEntry(
      id:
          widget.existing?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      category: _category,
      amount: -_amount.abs(),
      date: _date,
      notes: _notesController.text.trim(),
      inputMode: _tabs[_selectedTab],
    );

    AppScope.of(context).addOrUpdateLedgerEntry(item);
    Navigator.of(context).pop();
  }
}
