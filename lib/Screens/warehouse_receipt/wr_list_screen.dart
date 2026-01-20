import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme_config.dart';
import '../../routes/route_names.dart';
import '../providers/warehouse_receipt_provider.dart';
import '../../l10n/app_strings.dart';
import '../widgets/loading_indicator.dart';

class WRListScreen extends StatefulWidget {
  final int tenantId;
  final String company;
  final String? vendorId;

  const WRListScreen({
    Key? key,
    this.tenantId = 0,
    this.company = '',
    this.vendorId,
  }) : super(key: key);

  @override
  State<WRListScreen> createState() => _WRListScreenState();
}

class _WRListScreenState extends State<WRListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedIndex;
  Map<String, dynamic>? _filters;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<WarehouseReceiptProvider>();
    try {
      await provider.fetchWarehouseReceiptOrders(
        widget.tenantId,
        vendorId: _filters?['vendorId']?.toString() ?? widget.vendorId,
        janCode: _filters?['janCode']?.toString(),
        productName: _filters?['productName']?.toString(),
        productCode: _filters?['productCode']?.toString(),
        arrivalNumber: _filters?['arrivalNumber']?.toString(),
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      print('Error loading data: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading receipts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        final strings = AppStrings.ofWithoutWatch(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.receiptSyncNone),
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

    final strings = AppStrings.ofWithoutWatch(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('{$receiptNosString}'),
            const SizedBox(height: 8),
            Text(strings.receiptSyncConfirm),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(strings.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: Text(strings.yes),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.syncOfflineData(widget.tenantId);
      if (mounted) {
        final strings = AppStrings.ofWithoutWatch(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.receiptSynced),
              backgroundColor: Colors.green,
            ),
          );
          await _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? strings.receiptSyncFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleReset(int index, String receiptNo) async {
    final strings = AppStrings.ofWithoutWatch(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirm),
        content: Text(
          '${strings.receiptNo}: $receiptNo\n${strings.receiptResetConfirm}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(strings.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: Text(strings.yes),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = context.read<WarehouseReceiptProvider>();
      final success = await provider.resetScannedData(receiptNo);
      if (mounted && success) {
        final strings = AppStrings.ofWithoutWatch(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.receiptResetDone),
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

    if (receipt.scanStatus == 3) {
      final strings = AppStrings.ofWithoutWatch(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.confirm),
          content: Text(strings.handledByOther),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: Text(strings.close),
            ),
          ],
        ),
      );
      return;
    }

    // Check receipt status from API before navigating (like React Native)
    final isHandledByOther = await provider.checkReceiptStatus(
      receipt.receiptNo,
    );
    if (isHandledByOther) {
      // Get receipt info to show user name
      try {
        final receiptOrders = await provider.repository
            .getWarehouseReceiptOrderByReceiptNo(receipt.receiptNo);
        if (receiptOrders.isNotEmpty) {
          if (mounted) {
            final strings = AppStrings.ofWithoutWatch(context);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(strings.confirm),
                content: Text(strings.handledByOther),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    child: Text(strings.close),
                  ),
                ],
              ),
            );
          }
          return;
        }
      } catch (e) {
        print('Error getting receipt info: $e');
      }
    }

    // Navigate to details
    await provider.selectReceipt(receipt);
    if (mounted) {
      // Use absolute path with RouteNames to ensure correct navigation
      context.push(
        RouteNames.warehouseReceiptDetail,
        extra: {'receipt': receipt, 'tenantId': widget.tenantId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.receiptListTitle),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RouteNames.mainMenu);
          },
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: strings.searchHint,
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
                  borderSide: BorderSide(color: AppColors.lighter, width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.lighter, width: 2),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primaryLight,
                    width: 2,
                  ),
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
                bottom: BorderSide(color: AppColors.borderTable, width: 1),
                top: BorderSide(color: AppColors.borderTable, width: 1),
                left: BorderSide(color: AppColors.borderTable, width: 1),
                right: BorderSide(color: AppColors.borderTable, width: 1),
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
                        right: BorderSide(
                          color: AppColors.borderTable,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      strings.receiptNo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'MSPGothic',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      strings.supplierName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'MSPGothic',
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
                  return const LoadingIndicator(size: 100);
                }

                if (provider.receiptOrders.isEmpty) {
                  final strings = AppStrings.of(context);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          strings.listEmpty,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (provider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Error: ${provider.errorMessage}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadData(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: provider.receiptOrders.length,
                  itemBuilder: (context, index) {
                    final receipt = provider.receiptOrders[index];
                    final isSelected = _selectedIndex == index;
                    final scanStatus = receipt.scanStatus ?? -1;

                    Color textColor = AppColors.black;
                    Widget? leadingIcon;

                    if (scanStatus == 2) {
                      // Scanned - Orange (text_warning color)
                      textColor = AppColors.text_warning;
                      leadingIcon = IconButton(
                        icon: const Icon(Icons.refresh),
                        color: AppColors.blackText,
                        iconSize: 35,
                        onPressed: () => _handleReset(index, receipt.receiptNo),
                      );
                    } else if (scanStatus == 3) {
                      // Handled by other - Grey (text_placeholder color)
                      textColor = AppColors.text_placeholder;
                      leadingIcon = IconButton(
                        icon: const Icon(
                          Icons.construction,
                        ), // account-hard-hat equivalent
                        color: AppColors.blackText,
                        iconSize: 35,
                        onPressed: () {
                          final strings = AppStrings.of(context);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(strings.confirm),
                              content: Text(strings.handledByOther),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                  child: Text(strings.close),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    // Determine status color for indicator
                    Color getStatusColor() {
                      if (scanStatus == 2)
                        return AppColors.text_warning; // Orange - scanned
                      if (scanStatus == 3)
                        return AppColors
                            .text_placeholder; // Grey - handled by other
                      return AppColors.black; // Black - not started
                    }

                    return InkWell(
                      onTap: () => _handleRowTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.headerColor
                              : Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.borderTable,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                // Receipt Number + Product Names (with icon if needed)
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      top: 10,
                                      bottom: 10,
                                      left: scanStatus == 2 || scanStatus == 3
                                          ? 0
                                          : 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: AppColors.borderTable,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Icon container (flex: 0.6 like React Native)
                                        if (scanStatus == 2 || scanStatus == 3)
                                          Container(
                                            width: 50,
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.only(
                                              right: 0,
                                              top: 8,
                                            ),
                                            child:
                                                leadingIcon ?? const SizedBox(),
                                          ),
                                        // Text container (flex: 3 like React Native)
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 4,
                                                ),
                                                child: Text(
                                                  receipt.receiptNo,
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    fontFamily: 'MSPGothic',
                                                  ),
                                                ),
                                              ),
                                              // Product Names
                                              if (receipt.productNames !=
                                                      null &&
                                                  receipt
                                                      .productNames!
                                                      .isNotEmpty)
                                                ...receipt.productNames!
                                                    .split(',')
                                                    .where(
                                                      (name) => name
                                                          .trim()
                                                          .isNotEmpty,
                                                    )
                                                    .map(
                                                      (name) => Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4,
                                                              bottom: 2,
                                                            ),
                                                        child: Text(
                                                          name.trim().length >
                                                                  25
                                                              ? '${name.trim().substring(0, 25)}...'
                                                              : name.trim(),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: textColor,
                                                            fontFamily:
                                                                'MSPGothic',
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    )
                                                    .toList()
                                              else if (receipt.productNames ==
                                                      null ||
                                                  receipt.productNames!.isEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                      ),
                                                  child: Text(
                                                    '(No products)',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Supplier Name
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                      bottom: 10,
                                      left: 8,
                                      right: 4,
                                    ),
                                    child: Text(
                                      receipt.supplierName ?? '(No supplier)',
                                      style: TextStyle(
                                        color: receipt.supplierName != null
                                            ? textColor
                                            : Colors.grey,
                                        fontSize: 14,
                                        fontFamily: 'MSPGothic',
                                        fontStyle: receipt.supplierName != null
                                            ? FontStyle.normal
                                            : FontStyle.italic,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Status indicator circle at top right
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: getStatusColor(),
                                    width: 3,
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
              border: Border(top: BorderSide(color: Colors.grey.shade400)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.go(RouteNames.mainMenu);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.btn_red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      strings.back,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await context.push<Map<String, dynamic>>(
                        RouteNames.warehouseReceiptFilter,
                        extra: {
                          'tenantId': widget.tenantId,
                          'company': widget.company,
                        },
                      );
                      if (result != null && mounted) {
                        setState(() {
                          _filters = result;
                        });
                        await _loadData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      strings.advancedSearch,
                      style: const TextStyle(fontSize: 16),
                    ),
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
                    child: Text(
                      strings.sync,
                      style: const TextStyle(fontSize: 16),
                    ),
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
