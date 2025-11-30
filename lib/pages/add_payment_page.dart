import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';
import '../providers/payment_provider.dart';

/// Screen for adding a new payment (expense) and
/// showing existing payments from the database (via PaymentProvider).
class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({super.key});

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  /// Controller for the "note" / description text field
  final _noteController = TextEditingController();

  /// Controller for the "amount" text field
  final _amountController = TextEditingController();

  /// Currently selected date for the payment (defaults to today)
  DateTime? _selectedDate = DateTime.now();

  /// Currently selected category, defaults to "food"
  Category _selectedCategory = Category.food;

  /// Whether the payment is an income
  bool _isIncome = false;

  /// ID of the payment currently being edited (null if adding new)
  String? _editingId;

  @override
  void dispose() {
    // Clean up controllers to avoid memory leaks
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Opens a date picker and stores the chosen date in [_selectedDate]
  void _presentDatePicker() async {
    final now = DateTime.now();
    // Allow picking dates from up to 1 year ago until today
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    // Update state with chosen date
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  /// Validates input, builds a [Payment] object and passes it to [PaymentProvider].
  /// This will also save to SQLite via PaymentDao inside the provider.
  Future<void> _submitPaymentData() async {
    // Try to parse amount as double
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;

    // Basic validation: note not empty, amount positive, date chosen
    if (_noteController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      // Show an error dialog if anything is invalid
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text(
            'Please make sure a valid note, amount, date and category were entered.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }

    // Build a Payment model instance from the form data
    final payment = Payment(
      // Use existing ID if editing, otherwise generate new one
      id: _editingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: enteredAmount,
      category: _selectedCategory,
      note: _noteController.text.trim(),
      date: _selectedDate!,
      isIncome: _isIncome,
      isSaving: false,
    );

    final provider = Provider.of<PaymentProvider>(context, listen: false);

    if (_editingId != null) {
      await provider.updatePayment(payment);
    } else {
      await provider.addPayment(payment);
    }

    // Important: we DO NOT pop the page.
    // This page is used as a bottom-nav tab, not as a pushed route,
    // so popping here would close the whole root route.
    //
    // Instead, we:
    //  - reset the form fields
    //  - show a SnackBar confirmation
    _resetForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_editingId != null ? 'Payment updated' : 'Payment saved'),
      ),
    );
  }

  void _resetForm() {
    _noteController.clear();
    _amountController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedCategory = Category.food;
      _isIncome = false;
      _editingId = null;
    });
  }

  void _startEditing(Payment payment) {
    setState(() {
      _editingId = payment.id;
      _noteController.text = payment.note;
      _amountController.text = payment.amount.toString();
      _selectedDate = payment.date;
      _selectedCategory = payment.category;
      _isIncome = payment.isIncome;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Payment')),
      // Consumer listens to PaymentProvider so that when the provider
      // loads data from DB or adds new payments, this widget rebuilds.
      body: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          final payments = provider.payments; // all payments in memory
          final isLoading =
              provider.isLoading; // whether initial load is still running

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- FORM SECTION ---

                // Note / description input
                TextField(
                  controller: _noteController,
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text('Note')),
                ),

                // Amount + Date row
                Row(
                  children: [
                    // Amount input
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          prefixText: '\$ ',
                          label: Text('Amount'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Date picker display + button
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'No Date Selected'
                                : DateFormat.yMd().format(_selectedDate!),
                          ),
                          IconButton(
                            onPressed: _presentDatePicker,
                            icon: const Icon(Icons.calendar_month),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Is Income Checkbox
                CheckboxListTile(
                  title: const Text("Is Income?"),
                  value: _isIncome,
                  onChanged: (val) {
                    setState(() {
                      _isIncome = val ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 16),

                // Category dropdown + buttons
                Row(
                  children: [
                    // Dropdown for Category enum values
                    DropdownButton<Category>(
                      value: _selectedCategory,
                      items: Category.values
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category.name.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const Spacer(),
                    // Cancel button:
                    // - If page was pushed with Navigator.push, pop it.
                    // - If it's just a tab, clear the form instead.
                    TextButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          // In case this page is opened as a route
                          Navigator.of(context).pop();
                        } else {
                          // In bottom-tab context: just clear the form
                          _resetForm();
                        }
                      },
                      child: const Text('Cancel'),
                    ),
                    // Save button → calls _submitPaymentData
                    ElevatedButton(
                      onPressed: _submitPaymentData,
                      child: Text(
                        _editingId != null ? 'Update ' : 'Save Payment',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- EXISTING PAYMENTS LIST (from DB via provider) ---
                const Text(
                  'Existing Payments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                // Show loading spinner while provider is fetching from DB
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                // If loaded and empty: show simple message
                else if (payments.isEmpty)
                  const Text('No payments yet.')
                // Otherwise, show a list of existing payments
                else
                  ListView.separated(
                    // Because we are inside a SingleChildScrollView,
                    // we disable ListView's own scrolling and let it
                    // size itself to its contents.
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: payments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      // Show newest first by reversing the list order
                      final p = payments[index];

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            // Left: note + category + date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.note,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${p.category.name} · ${DateFormat.yMd().format(p.date)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Right: amount
                            Text(
                              p.isIncome
                                  ? '+\$${p.amount.toStringAsFixed(2)}'
                                  : '-\$${p.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: p.isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                            // Three-dot menu for Edit/Delete
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _startEditing(p);
                                } else if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Payment'),
                                      content: const Text(
                                        'Are you sure you want to delete this payment?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            provider.deletePayment(p.id);
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Edit'),
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        title: Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
