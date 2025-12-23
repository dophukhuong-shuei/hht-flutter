import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/warehouse_receipt_provider.dart';

class WRListScreen extends StatefulWidget {
  final int tenantId;
  final String? vendorId;

  const WRListScreen({
    Key? key,
    required this.tenantId,
    this.vendorId,
  }) : super(key: key);

  @override
  State<WRListScreen> createState() => _WRListScreenState();
}

class _WRListScreenState extends State<WRListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<WarehouseReceiptProvider>();
    await provider.fetchWarehouseReceiptOrders(
      widget.tenantId,
      vendorId: widget.vendorId,
    );
  }

  Future<void> _handleSearch(String keyword) async {
    final provider = context.read<WarehouseReceiptProvider>();
    await provider.searchReceipts(keyword, widget.tenantId);
  }

  Future<void> _handleSync() async {
    final provider = context.read<WarehouseReceiptProvider>();

    // Get offline data for this tenant
    final offlineData = provider.getOfflineDataByTenant(widget.tenantId);

    if (offlineData.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('データ同期なし'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Build receipt numbers list
    final receiptNos = offlineData
        .map((data) => data.warehouseReceiptNo)
        .toList();
    final receiptNosString = receiptNos.join(', ');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('{$receiptNosString}'),
            const SizedBox(height: 8),
            const Text('をWMSに同期しますか？'),
          ],
        ),
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

    if (confirmed == true) {
      final success = await provider.syncOfflineData(widget.tenantId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('データは正常に同期されました'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? '同期に失敗しました'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleReset(int index, String receiptNo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: Text('$receiptNo の対応中のデータをリセットしますか?'),
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

    if (confirmed == true) {
      final provider = context.read<WarehouseReceiptProvider>();
      final success = await provider.resetScannedData(receiptNo);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('リセットしました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _handleRowTap(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    final provider = context.read<WarehouseReceiptProvider>();
    final receipt = provider.receiptOrders[index];

    // Check if handled by other device
    if (receipt.scanStatus == 3) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('通知'),
          content: Text(
            'ユーザー「${receipt.hhtInfo?.split('-').first ?? ''}」は別デバイスで ${receipt.receiptNo} を対応してます。ご確認ください。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    // Navigate to details
    await provider.selectReceipt(receipt);
    if (mounted) {
      Navigator.pushNamed(
        context,
        '/warehouse-receipt/details',
        arguments: {
          'receipt': receipt,
          'tenantId': widget.tenantId,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('入荷一覧'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'フィルターする内容を入力してください。',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadData();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
              ),
              onSubmitted: _handleSearch,
              onChanged: (value) {
                setState(() {}); // Update to show/hide clear button
              },
            ),
          ),

          // Table Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: const Text(
                      '入荷番号',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      '仕入先名',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Receipt list
          Expanded(
            child: Consumer<WarehouseReceiptProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.receiptOrders.isEmpty) {
                  return const Center(
                    child: Text(
                      'データがありません',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: provider.receiptOrders.length,
                  itemBuilder: (context, index) {
                    final receipt = provider.receiptOrders[index];
                    final isSelected = _selectedIndex == index;
                    final scanStatus = receipt.scanStatus ?? -1;

                    Color textColor = Colors.black;
                    Widget? leadingIcon;

                    if (scanStatus == 2) {
                      // Scanned - Orange
                      textColor = const Color(0xFFFF6600);
                      leadingIcon = IconButton(
                        icon: const Icon(Icons.refresh),
                        color: Colors.black,
                        iconSize: 35,
                        onPressed: () => _handleReset(index, receipt.receiptNo),
                      );
                    } else if (scanStatus == 3) {
                      // Handled by other - Grey
                      textColor = Colors.grey;
                      leadingIcon = IconButton(
                        icon: const Icon(Icons.account_circle),
                        color: Colors.grey,
                        iconSize: 35,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('通知'),
                              content: Text(
                                'ユーザー「${receipt.hhtInfo?.split('-').first ?? ''}」は別デバイスで ${receipt.receiptNo} を対応してます。ご確認ください。',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    return InkWell(
                      onTap: () => _handleRowTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade100
                              : Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Leading icon or empty space
                            SizedBox(
                              width: 50,
                              child: leadingIcon ?? const SizedBox(),
                            ),
                            // Receipt Number + Product Names
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      receipt.receiptNo,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (receipt.productNames != null &&
                                        receipt.productNames!.isNotEmpty)
                                      ...receipt.productNames!
                                          .split(', ')
                                          .take(3)
                                          .map((name) => Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 5),
                                                child: Text(
                                                  name.length > 15
                                                      ? '${name.substring(0, 15)}...'
                                                      : name,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: textColor
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                  ],
                                ),
                              ),
                            ),
                            // Supplier Name
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  receipt.supplierName ?? '',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border(
                top: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('戻る', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/warehouse-receipt/filter',
                        arguments: {'tenantId': widget.tenantId},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('詳細検索', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSync,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('送信', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

