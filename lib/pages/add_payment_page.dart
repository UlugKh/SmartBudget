import 'package:flutter/material.dart';
import '../models/payment.dart';

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({super.key});

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  Category _selectedCategory = Category.food;
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (result != null) {
      setState(() {
        _selectedDate = result;
      });
    }
  }

  void _save() {
    final rawAmount = _amountController.text.trim();
    final amount = double.tryParse(rawAmount);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final note = _noteController.text.trim();

    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: _selectedCategory,
      note: note.isEmpty ? '-' : note,
      date: _selectedDate,
      isIncome: _isIncome,
      isSaving: false,
    );

    Navigator.of(context).pop(payment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _selectedCategory as String,
              items: const [
                DropdownMenuItem(value: 'Food', child: Text('Food')),
                DropdownMenuItem(value: 'Transport', child: Text('Transport')),
                DropdownMenuItem(value: 'Shopping', child: Text('Shopping')),
                DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedCategory = value as Category;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${_selectedDate.day.toString().padLeft(2, '0')}.'
                        '${_selectedDate.month.toString().padLeft(2, '0')}.'
                        '${_selectedDate.year}',
                  ),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Is income'),
                Switch(
                  value: _isIncome,
                  onChanged: (value) {
                    setState(() {
                      _isIncome = value;
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
