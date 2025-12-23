import 'package:flutter/material.dart';

class WRFilterScreen extends StatefulWidget {
  final int tenantId;

  const WRFilterScreen({
    Key? key,
    required this.tenantId,
  }) : super(key: key);

  @override
  State<WRFilterScreen> createState() => _WRFilterScreenState();
}

class _WRFilterScreenState extends State<WRFilterScreen> {
  final TextEditingController _vendorController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productCodeController = TextEditingController();
  final TextEditingController _janCodeController = TextEditingController();
  final TextEditingController _arrivalNumberController = TextEditingController();

  void _handleApplyFilter() {
    final filters = <String, dynamic>{
      'tenantId': widget.tenantId,
    };

    if (_vendorController.text.isNotEmpty) {
      filters['vendorId'] = _vendorController.text;
    }
    if (_productNameController.text.isNotEmpty) {
      filters['productName'] = _productNameController.text;
    }
    if (_productCodeController.text.isNotEmpty) {
      filters['productCode'] = _productCodeController.text;
    }
    if (_janCodeController.text.isNotEmpty) {
      filters['janCode'] = _janCodeController.text;
    }
    if (_arrivalNumberController.text.isNotEmpty) {
      filters['arrivalNumber'] = _arrivalNumberController.text;
    }

    // Navigate back to list with filters
    Navigator.pushReplacementNamed(
      context,
      '/warehouse-receipt/list',
      arguments: filters,
    );
  }

  void _handleClear() {
    setState(() {
      _vendorController.clear();
      _productNameController.clear();
      _productCodeController.clear();
      _janCodeController.clear();
      _arrivalNumberController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('詳細検索'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'フィルター条件を入力してください',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Vendor/Supplier
            TextField(
              controller: _vendorController,
              decoration: const InputDecoration(
                labelText: '仕入先コード',
                hintText: '仕入先コードを入力',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),

            // Product Name
            TextField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: '商品名',
                hintText: '商品名を入力',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
              ),
            ),
            const SizedBox(height: 16),

            // Product Code
            TextField(
              controller: _productCodeController,
              decoration: const InputDecoration(
                labelText: '商品コード',
                hintText: '商品コードを入力',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
            const SizedBox(height: 16),

            // JAN Code
            TextField(
              controller: _janCodeController,
              decoration: const InputDecoration(
                labelText: 'JANコード',
                hintText: 'JANコードを入力',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.barcode_reader),
              ),
            ),
            const SizedBox(height: 16),

            // Arrival Number
            TextField(
              controller: _arrivalNumberController,
              decoration: const InputDecoration(
                labelText: '入荷予定番号',
                hintText: '入荷予定番号を入力',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '戻る',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleClear,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'クリア',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleApplyFilter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '適用',
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
    _vendorController.dispose();
    _productNameController.dispose();
    _productCodeController.dispose();
    _janCodeController.dispose();
    _arrivalNumberController.dispose();
    super.dispose();
  }
}

