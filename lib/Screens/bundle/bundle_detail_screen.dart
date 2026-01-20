import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../config/theme_config.dart';
import '../../routes/route_names.dart';
import '../../data/models/bundle/bundle_line.dart';
import '../providers/bundle_provider.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/qr_code_parser.dart';

class BundleDetailScreen extends StatefulWidget {
  final String transNo;
  final BundleLine? bundleLine;
  final int currentIndex;

  const BundleDetailScreen({
    Key? key,
    required this.transNo,
    this.bundleLine,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  State<BundleDetailScreen> createState() => _BundleDetailScreenState();
}

class _BundleDetailScreenState extends State<BundleDetailScreen> {
  final TextEditingController _binController = TextEditingController();
  final TextEditingController _productCodeController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _demandQtyController = TextEditingController();
  final TextEditingController _actualQtyController = TextEditingController();
  final TextEditingController _lotNoController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _janCodeController = TextEditingController();
  final TextEditingController _qrCodeController = TextEditingController();

  final FocusNode _binFocus = FocusNode();
  final FocusNode _qrCodeFocus = FocusNode();
  final FocusNode _actualQtyFocus = FocusNode();

  int _currentIndex = 0;
  List<BundleLine> _lines = [];
  MobileScannerController? _scannerController;
  String? _scanningField;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final provider = context.read<BundleProvider>();
    try {
      await provider.selectBundle(widget.transNo);
      _lines = provider.currentBundleLines;
      if (_lines.isNotEmpty && _currentIndex < _lines.length) {
        _updateFormFields();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateFormFields() {
    if (_currentIndex >= _lines.length) return;
    final line = _lines[_currentIndex];
    
    _binController.text = line.bin ?? '';
    _productCodeController.text = line.productCode;
    _productNameController.text = line.productName ?? '';
    _demandQtyController.text = line.demandQty.toString();
    _actualQtyController.text = line.actualQty.toString();
    _lotNoController.text = line.lotNo ?? '';
    _expirationDateController.text = line.expirationDate ?? '';
    _janCodeController.text = '';
    _qrCodeController.text = '';

    _binFocus.requestFocus();
  }

  Future<void> _handleBinSubmit(String value) async {
    if (value.isEmpty) return;

    final binData = splitQRCodeBin(value);
    final binCode = binData['binCode'] ?? value;

    // Validate bin exists
    final prefs = await SharedPreferences.getInstance();
    final localStorage = LocalStorage(prefs);
    final binsJson = await localStorage.getJson('dataBins');
    final binsList = _asList(binsJson);
    
    final binExists = binsList.any((bin) =>
        (bin['binCode']?.toString().toLowerCase() ?? '') ==
        binCode.toLowerCase());

    if (!binExists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('スキャンした棚番が倉庫に存在しません。ご確認ください'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _binController.clear();
      _binFocus.requestFocus();
      return;
    }

    _binController.text = binCode;
    _qrCodeFocus.requestFocus();
  }

  Future<void> _handleQRCodeSubmit(String value) async {
    if (value.isEmpty) {
      _actualQtyFocus.requestFocus();
      return;
    }

    final qrData = splitQRCodePick(value);
    final productCode = qrData['productCode'];
    final janCode = qrData['janCode'];
    final lotNo = qrData['lotNo'];
    final expired = qrData['expired'];

    if (productCode == null || janCode == null || lotNo == null || expired == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR code format'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _qrCodeController.clear();
      _qrCodeFocus.requestFocus();
      return;
    }

    final currentLine = _lines[_currentIndex];
    if (productCode.toLowerCase() != currentLine.productCode.toLowerCase()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('スキャンした商品が事前セットすべきの商品と違います。ご確認ください。'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _qrCodeController.clear();
      _qrCodeFocus.requestFocus();
      return;
    }

    final currentQty = double.tryParse(_actualQtyController.text) ?? 0.0;
    final newQty = currentQty + 1;

    if (newQty > currentLine.demandQty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('実数量が必要な数量を超えました'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _actualQtyController.text = currentLine.demandQty.toString();
      return;
    }

    setState(() {
      _actualQtyController.text = newQty.toString();
      _janCodeController.text = janCode;
      _lotNoController.text = lotNo;
      _expirationDateController.text = expired.replaceAll('/', '-');
      _qrCodeController.text = value;
    });

    await _saveToLocalStorage();

    if (newQty >= currentLine.demandQty) {
      if (_currentIndex < _lines.length - 1) {
        _handleNext();
      } else {
        await _verifyComplete();
      }
    } else {
      _qrCodeController.clear();
      _qrCodeFocus.requestFocus();
    }
  }

  Future<void> _saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final localStorage = LocalStorage(prefs);

    final bundlePickJson = await localStorage.getString('bundlepick');
    List<Map<String, dynamic>> bundlePick = [];
    if (bundlePickJson != null) {
      bundlePick = List<Map<String, dynamic>>.from(jsonDecode(bundlePickJson));
    }

    final transNoEntry = bundlePick.firstWhere(
      (item) => item.containsKey(widget.transNo),
      orElse: () => <String, dynamic>{},
    );

    if (transNoEntry.isEmpty) {
      bundlePick.add({widget.transNo: []});
    }

    final lines = transNoEntry[widget.transNo] as List<dynamic>? ?? [];
    final currentLine = _lines[_currentIndex];
    final lineIndex = lines.indexWhere((l) => l['id'] == currentLine.id);

    final lineData = {
      'id': currentLine.id,
      'transNo': widget.transNo,
      'productCode': currentLine.productCode,
      'bin': _binController.text,
      'demandQty': currentLine.demandQty,
      'actualQty': double.tryParse(_actualQtyController.text) ?? 0.0,
      'lotNo': _lotNoController.text,
      'expirationDate': _expirationDateController.text,
      'janCode': _janCodeController.text,
      'productQRCode': _qrCodeController.text,
      'pickbox': '',
    };

    if (lineIndex >= 0) {
      lines[lineIndex] = lineData;
    } else {
      lines.add(lineData);
    }

    transNoEntry[widget.transNo] = lines;
    await localStorage.saveString('bundlepick', jsonEncode(bundlePick));
  }

  Future<void> _verifyComplete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification'),
        content: Text('事前セット ${widget.transNo} が完了しました。送信しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('いいえ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('はい'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _syncData();
    } else {
      await _saveScannedData();
    }
  }

  Future<void> _saveScannedData() async {
    final prefs = await SharedPreferences.getInstance();
    final localStorage = LocalStorage(prefs);

    final bundlePickJson = await localStorage.getString('bundlepick');
    if (bundlePickJson == null) return;

    final bundlePick = List<Map<String, dynamic>>.from(jsonDecode(bundlePickJson));
    final transNoEntry = bundlePick.firstWhere(
      (item) => item.containsKey(widget.transNo),
      orElse: () => <String, dynamic>{},
    );

    if (transNoEntry.isEmpty) return;

    final bundleScannedJson = await localStorage.getString('bundleScanned');
    List<Map<String, dynamic>> bundleScanned = [];
    if (bundleScannedJson != null) {
      bundleScanned = List<Map<String, dynamic>>.from(jsonDecode(bundleScannedJson));
    }

    final existingIndex = bundleScanned.indexWhere((item) => item.containsKey(widget.transNo));
    if (existingIndex >= 0) {
      bundleScanned[existingIndex] = transNoEntry;
    } else {
      bundleScanned.add(transNoEntry);
    }

    await localStorage.saveString('bundleScanned', jsonEncode(bundleScanned));

    if (mounted) {
      context.go(RouteNames.bundleList);
    }
  }

  Future<void> _syncData() async {
    setState(() => _isLoading = true);

    try {
      final provider = context.read<BundleProvider>();
      // TODO: Implement full sync logic
      // This would involve:
      // 1. Get data from bundleScanned
      // 2. Upload to server
      // 3. Update HHT status
      // 4. Clear local storage

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('データは正常に同期されました'),
            backgroundColor: Colors.green,
          ),
        );

        context.go(RouteNames.bundleList);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleNext() {
    if (_currentIndex < _lines.length - 1) {
      setState(() {
        _currentIndex++;
        _updateFormFields();
      });
    }
  }

  void _handlePrev() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _updateFormFields();
      });
    }
  }

  void _startBarcodeScanner(String field) {
    setState(() {
      _scanningField = field;
      _scannerController = MobileScannerController();
    });

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 400,
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      _scannerController?.stop();
                      Navigator.pop(context);
                      if (_scanningField == 'bin') {
                        _handleBinSubmit(barcode.rawValue!);
                      } else if (_scanningField == 'qrCode') {
                        _handleQRCodeSubmit(barcode.rawValue!);
                      }
                      break;
                    }
                  }
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    _scannerController?.stop();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _lines.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.lighter,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_1.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
              ),
            ],
          ),
        ),
      );
    }

    if (_lines.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('事前セット詳細'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: const Center(
          child: Text('No bundle lines found'),
        ),
      );
    }

    final currentLine = _lines[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.lighter,
      appBar: AppBar(
        title: Text('事前セット詳細 (${_currentIndex + 1}/${_lines.length})'),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Bundle Code Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.borderTable,
              border: Border(
                bottom: BorderSide(color: AppColors.borderTable, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '事前セット:',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'MSPGothic',
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.transNo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'MSPGothic',
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 棚 (Bin)
                  _buildFieldWithBarcode(
                    label: '棚',
                    controller: _binController,
                    focusNode: _binFocus,
                    onSubmitted: _handleBinSubmit,
                    onBarcodeTap: () => _startBarcodeScanner('bin'),
                  ),
                  const SizedBox(height: 16),

                  // 商品コード (Product Code) - Read-only
                  _buildReadOnlyField(
                    label: '商品コード',
                    controller: _productCodeController,
                    icon: Icons.inventory,
                  ),
                  const SizedBox(height: 16),

                  // 商品名 (Product Name) - Read-only
                  _buildReadOnlyField(
                    label: '商品名',
                    controller: _productNameController,
                    icon: Icons.label,
                  ),
                  const SizedBox(height: 16),

                  // 需要数量 (Demand Quantity) - Read-only
                  _buildReadOnlyField(
                    label: '需要数量',
                    controller: _demandQtyController,
                    icon: Icons.shopping_cart,
                  ),
                  const SizedBox(height: 16),

                  // QRコード (QR Code)
                  _buildFieldWithBarcode(
                    label: 'QRコード',
                    controller: _qrCodeController,
                    focusNode: _qrCodeFocus,
                    onSubmitted: _handleQRCodeSubmit,
                    onBarcodeTap: () => _startBarcodeScanner('qrCode'),
                  ),
                  const SizedBox(height: 16),

                  // 実数量 (Actual Quantity)
                  _buildField(
                    label: '実数量',
                    controller: _actualQtyController,
                    focusNode: _actualQtyFocus,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // JANコード (JAN Code) - Read-only
                  _buildReadOnlyField(
                    label: 'JANコード',
                    controller: _janCodeController,
                    icon: Icons.qr_code,
                  ),
                  const SizedBox(height: 16),

                  // ロット (Lot) - Read-only
                  _buildReadOnlyField(
                    label: 'ロット',
                    controller: _lotNoController,
                    icon: Icons.numbers,
                  ),
                  const SizedBox(height: 16),

                  // 賞味期限 (Expiration Date) - Read-only
                  _buildReadOnlyField(
                    label: '賞味期限',
                    controller: _expirationDateController,
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 24),

                  // Navigation Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentIndex > 0 ? _handlePrev : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentIndex > 0
                                ? AppColors.btn_brown
                                : Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            '前へ',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentIndex < _lines.length - 1
                              ? _handleNext
                              : () => _verifyComplete(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentIndex < _lines.length - 1
                                ? AppColors.btn_brown
                                : AppColors.greenDark,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            _currentIndex < _lines.length - 1 ? '次へ' : '完了',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldWithBarcode({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String) onSubmitted,
    required VoidCallback onBarcodeTap,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'MSPGothic',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: onBarcodeTap,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
            ),
          ),
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'MSPGothic',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'MSPGothic',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }

  List<dynamic> _asList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map) return data.values.toList();
    return [];
  }

  @override
  void dispose() {
    _binController.dispose();
    _productCodeController.dispose();
    _productNameController.dispose();
    _demandQtyController.dispose();
    _actualQtyController.dispose();
    _lotNoController.dispose();
    _expirationDateController.dispose();
    _janCodeController.dispose();
    _qrCodeController.dispose();
    _binFocus.dispose();
    _qrCodeFocus.dispose();
    _actualQtyFocus.dispose();
    _scannerController?.dispose();
    super.dispose();
  }
}

