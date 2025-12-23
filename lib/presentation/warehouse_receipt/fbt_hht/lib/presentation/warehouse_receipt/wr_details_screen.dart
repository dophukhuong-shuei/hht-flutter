import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/warehouse_receipt/receipt_order.dart';
import '../../data/models/warehouse_receipt/receipt_line.dart';
import '../providers/warehouse_receipt_provider.dart';

class WRDetailsScreen extends StatefulWidget {
  final ReceiptOrder receipt;
  final int tenantId;

  const WRDetailsScreen({
    Key? key,
    required this.receipt,
    required this.tenantId,
  }) : super(key: key);

  @override
  State<WRDetailsScreen> createState() => _WRDetailsScreenState();
}

class _WRDetailsScreenState extends State<WRDetailsScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _orderQtyController = TextEditingController();
  final TextEditingController _actualQtyController = TextEditingController();
  final TextEditingController _lotNoController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _binController = TextEditingController();

  final FocusNode _barcodeFocus = FocusNode();
  final FocusNode _actualQtyFocus = FocusNode();
  final FocusNode _lotNoFocus = FocusNode();
  final FocusNode _expirationDateFocus = FocusNode();

  int _currentIndex = 0;
  int _selectedStatus = 1; // 1: OK, 2: NG, 3: Shortage
  ReceiptLine? _currentLine;
  List<ReceiptLine> _lines = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLines();
    });
  }

  Future<void> _loadLines() async {
    final provider = context.read<WarehouseReceiptProvider>();
    setState(() {
      _lines = provider.currentReceiptLines;
      if (_lines.isNotEmpty) {
        _currentLine = _lines[_currentIndex];
        _updateFormFields();
      }
    });
    _barcodeFocus.requestFocus();
  }

  void _updateFormFields() {
    if (_currentLine != null) {
      _productNameController.text = _currentLine!.productName ?? '';
      _orderQtyController.text = _currentLine!.orderQty.toString();
      _actualQtyController.text = _currentLine!.transQty?.toString() ?? '0';
      _lotNoController.text = _currentLine!.lotNo ?? '';
      _expirationDateController.text = _currentLine!.expirationDate ?? '';
      _binController.text = _currentLine!.bin ?? '';
      _selectedStatus = _currentLine!.status;
    }
  }

  Future<void> _handleBarcodeSubmit(String barcode) async {
    if (barcode.isEmpty) return;

    // TODO: Implement barcode lookup logic
    // Check if barcode matches current product or search for product
    _barcodeController.clear();
    _actualQtyFocus.requestFocus();
  }

  Future<void> _selectExpirationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _expirationDateController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _handlePrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentLine = _lines[_currentIndex];
        _updateFormFields();
      });
      _barcodeFocus.requestFocus();
    }
  }

  void _handleNext() {
    if (_currentIndex < _lines.length - 1) {
      setState(() {
        _currentIndex++;
        _currentLine = _lines[_currentIndex];
        _updateFormFields();
      });
      _barcodeFocus.requestFocus();
    }
  }

  Future<void> _handleSave() async {
    if (_currentLine == null) return;

    // Validate required fields
    if (_actualQtyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('実際数量を入力してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Save to offline storage
    // Update the current line with entered data
    final updatedLine = _currentLine!.copyWith(
      transQty: double.tryParse(_actualQtyController.text),
      lotNo: _lotNoController.text,
      expirationDate: _expirationDateController.text,
      bin: _binController.text,
      status: _selectedStatus,
    );

    // Save to offline storage
    // await _saveToOfflineStorage(updatedLine);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('保存しました'),
        backgroundColor: Colors.green,
      ),
    );

    // Move to next line if available
    if (_currentIndex < _lines.length - 1) {
      _handleNext();
    }
  }

  Future<void> _handleComplete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('入荷を完了しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('いいえ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('はい'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: Complete and navigate back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('入荷詳細 - ${widget.receipt.receiptNo}'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _lines.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress indicator
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_currentIndex + 1} / ${_lines.length}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed:
                                    _currentIndex > 0 ? _handlePrevious : null,
                                icon: const Icon(Icons.arrow_back),
                                color: _currentIndex > 0
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              IconButton(
                                onPressed: _currentIndex < _lines.length - 1
                                    ? _handleNext
                                    : null,
                                icon: const Icon(Icons.arrow_forward),
                                color: _currentIndex < _lines.length - 1
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Barcode input
                  TextField(
                    controller: _barcodeController,
                    focusNode: _barcodeFocus,
                    decoration: const InputDecoration(
                      labelText: 'バーコードスキャン',
                      hintText: 'バーコードをスキャン',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code_scanner),
                    ),
                    onSubmitted: _handleBarcodeSubmit,
                  ),
                  const SizedBox(height: 16),

                  // Product name (read-only)
                  TextField(
                    controller: _productNameController,
                    decoration: const InputDecoration(
                      labelText: '商品名',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),

                  // Order quantity (read-only)
                  TextField(
                    controller: _orderQtyController,
                    decoration: const InputDecoration(
                      labelText: '注文数量',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_cart),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),

                  // Actual quantity
                  TextField(
                    controller: _actualQtyController,
                    focusNode: _actualQtyFocus,
                    decoration: const InputDecoration(
                      labelText: '実際数量 *',
                      hintText: '実際数量を入力',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Expiration date
                  TextField(
                    controller: _expirationDateController,
                    focusNode: _expirationDateFocus,
                    decoration: InputDecoration(
                      labelText: '賞味期限',
                      hintText: 'YYYY-MM-DD',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: _selectExpirationDate,
                      ),
                    ),
                    readOnly: true,
                    onTap: _selectExpirationDate,
                  ),
                  const SizedBox(height: 16),

                  // Lot number
                  TextField(
                    controller: _lotNoController,
                    focusNode: _lotNoFocus,
                    decoration: const InputDecoration(
                      labelText: 'ロット番号',
                      hintText: 'ロット番号を入力',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bin/Location
                  TextField(
                    controller: _binController,
                    decoration: const InputDecoration(
                      labelText: 'ビン/ロケーション',
                      hintText: 'ビンを入力',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ステータス',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('OK'),
                                selected: _selectedStatus == 1,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedStatus = 1);
                                  }
                                },
                                selectedColor: Colors.green,
                              ),
                              ChoiceChip(
                                label: const Text('NG'),
                                selected: _selectedStatus == 2,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedStatus = 2);
                                  }
                                },
                                selectedColor: Colors.red,
                              ),
                              ChoiceChip(
                                label: const Text('不足'),
                                selected: _selectedStatus == 3,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedStatus = 3);
                                  }
                                },
                                selectedColor: Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            '保存',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleComplete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            '完了',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _productNameController.dispose();
    _orderQtyController.dispose();
    _actualQtyController.dispose();
    _lotNoController.dispose();
    _expirationDateController.dispose();
    _binController.dispose();
    _barcodeFocus.dispose();
    _actualQtyFocus.dispose();
    _lotNoFocus.dispose();
    _expirationDateFocus.dispose();
    super.dispose();
  }
}

