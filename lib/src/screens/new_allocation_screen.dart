import 'package:flutter/material.dart';

import '../models/app_models.dart';
// import '../state/app_controller.dart';
import '../state/app_scope.dart';
import '../utils/app_formatters.dart';
import '../widgets/common_widgets.dart';

class NewAllocationScreen extends StatefulWidget {
  const NewAllocationScreen({super.key, this.existing});

  final AllocationItem? existing;

  @override
  State<NewAllocationScreen> createState() => _NewAllocationScreenState();
}

class _NewAllocationScreenState extends State<NewAllocationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  String _group = 'Food';
  String _timeframe = 'Weekly';
  bool _recurring = false;
  bool _thresholdAlert = true;
  double _budget = 0;
  DateTime _date = DateTime.now();

  static const _groups = ['Food', 'Travel', 'Shop', 'Home', 'Other'];
  static const _timeframes = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _group = existing?.group ?? 'Food';
    _timeframe = existing?.timeframe ?? 'Weekly';
    _recurring = existing?.recurring ?? false;
    _thresholdAlert = existing?.thresholdAlert ?? true;
    _budget = existing?.budget ?? 0;
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
            BackHeader(title: isEditing ? 'Edit Allocation' : 'Allocation'),
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
                        onTap: _pickBudget,
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
                                    'Tap to set budget amount',
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
                                AppFormatters.compactMoney(_budget),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel('DETAILS'),
                            const SizedBox(height: 14),
                            AppTextField(
                              label: 'Allocation title',
                              controller: _titleController,
                              hint: 'e.g. Transport',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              initialValue: _group,
                              decoration: const InputDecoration(
                                labelText: 'Category group',
                              ),
                              items: _groups
                                  .map(
                                    (group) => DropdownMenuItem(
                                      value: group,
                                      child: Text(group),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _group = value);
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              initialValue: _timeframe,
                              decoration: const InputDecoration(
                                labelText: 'Timeframe',
                              ),
                              items: _timeframes
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _timeframe = value);
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                            DatePickerField(
                              label: 'Date',
                              value: AppFormatters.shortDate(_date),
                              onTap: _pickDate,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      WhiteCard(
                        child: Column(
                          children: [
                            SwitchListTile(
                              value: _recurring,
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Recurring allocation'),
                              subtitle: const Text(
                                'Keep this budget active across cycles',
                              ),
                              onChanged: (value) =>
                                  setState(() => _recurring = value),
                            ),
                            const Divider(),
                            SwitchListTile(
                              value: _thresholdAlert,
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Threshold alert'),
                              subtitle: const Text(
                                'Notify at 80% spending limit',
                              ),
                              onChanged: (value) =>
                                  setState(() => _thresholdAlert = value),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      WhiteCard(
                        child: AppTextField(
                          label: 'Notes',
                          controller: _notesController,
                          hint: 'What should this allocation cover?',
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
                  label: isEditing ? 'Update Allocation' : 'Save Up!',
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

  Future<void> _pickBudget() async {
    final result = await Navigator.of(context).push<double>(
      MaterialPageRoute<double>(
        builder: (_) => NumericPadScreen(
          title: 'Budget Amount',
          initialValue: _budget,
          actionLabel: 'Use Amount',
        ),
      ),
    );

    if (result != null) {
      setState(() => _budget = result);
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
    if (!_formKey.currentState!.validate()) return;
    if (_budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a budget amount')),
      );
      return;
    }

    final app = AppScope.of(context);
    final existing = widget.existing;
    final item = AllocationItem(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      group: _group,
      budget: _budget,
      spent: existing?.spent ?? 0,
      timeframe: _timeframe,
      date: _date,
      recurring: _recurring,
      thresholdAlert: _thresholdAlert,
      notes: _notesController.text.trim(),
      icon: _iconForGroup(_group),
    );

    app.addOrUpdateAllocation(item);
    Navigator.of(context).pop();
  }

  IconData _iconForGroup(String group) {
    switch (group) {
      case 'Food':
        return Icons.restaurant_outlined;
      case 'Travel':
        return Icons.directions_bus_outlined;
      case 'Shop':
        return Icons.shopping_basket_outlined;
      case 'Home':
        return Icons.home_outlined;
      default:
        return Icons.widgets_outlined;
    }
  }
}

class NumericPadScreen extends StatefulWidget {
  const NumericPadScreen({
    super.key,
    required this.title,
    required this.initialValue,
    required this.actionLabel,
  });

  final String title;
  final double initialValue;
  final String actionLabel;

  @override
  State<NumericPadScreen> createState() => _NumericPadScreenState();
}

class _NumericPadScreenState extends State<NumericPadScreen> {
  late String _text;

  @override
  void initState() {
    super.initState();
    _text = widget.initialValue == 0 ? '0' : widget.initialValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    const values = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0'];

    return Scaffold(
      body: PagePadding(
        child: Column(
          children: [
            BackHeader(title: widget.title),
            const SizedBox(height: 18),
            WhiteCard(
              child: Column(
                children: [
                  const SectionLabel('AMOUNT'),
                  const SizedBox(height: 10),
                  Text(
                    AppFormatters.money(_currentValue),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1148A5),
                    ),
                  ),
                  const SizedBox(height: 18),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 12,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.3,
                        ),
                    itemBuilder: (context, index) {
                      if (index == 11) {
                        return _KeypadButton(
                          icon: Icons.backspace_outlined,
                          onTap: _backspace,
                        );
                      }

                      final value = values[index];
                      return _KeypadButton(
                        label: value,
                        onTap: () => _append(value),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: widget.actionLabel,
                    onPressed: () => Navigator.of(context).pop(_currentValue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double get _currentValue => double.tryParse(_text) ?? 0;

  void _append(String value) {
    setState(() {
      if (value == '.' && _text.contains('.')) return;
      if (_text == '0' && value != '.') {
        _text = value;
      } else {
        _text += value;
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_text.length <= 1) {
        _text = '0';
      } else {
        _text = _text.substring(0, _text.length - 1);
      }
    });
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F7FB),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Center(
          child: icon != null
              ? Icon(icon, color: const Color(0xFF475467))
              : Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
