import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../config/theme_config.dart';
import '../../routes/route_names.dart';
import '../providers/bundle_provider.dart';
import '../../l10n/strings_en.dart';
import '../widgets/loading_indicator.dart';

class BundleItemsScreen extends StatefulWidget {
  final String transNo;

  const BundleItemsScreen({
    Key? key,
    required this.transNo,
  }) : super(key: key);

  @override
  State<BundleItemsScreen> createState() => _BundleItemsScreenState();
}

class _BundleItemsScreenState extends State<BundleItemsScreen> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<BundleProvider>();
    try {
      await provider.selectBundle(widget.transNo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bundle items: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final provider = context.read<BundleProvider>();
    final lines = provider.currentBundleLines;
    if (index >= lines.length) return;

    final line = lines[index];

    // Navigate to details
    if (mounted) {
      context.push(
        RouteNames.bundleDetail,
        extra: {
          'transNo': widget.transNo,
          'bundleLine': line,
          'currentIndex': index,
        },
      );
    }
  }

  String _getStatusLabel(double? actualQty, double demandQty) {
    if (actualQty == null || actualQty == 0) {
      return '未対応';
    } else if (actualQty < demandQty) {
      return '一部対応';
    } else {
      return '完了';
    }
  }

  Color _getStatusColor(double? actualQty, double demandQty) {
    if (actualQty == null || actualQty == 0) {
      return AppColors.black;
    } else if (actualQty < demandQty) {
      return AppColors.text_warning;
    } else {
      return AppColors.greenDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('事前セット明細'),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Bundle Code Header
          Consumer<BundleProvider>(
            builder: (context, provider, child) {
              final lines = provider.currentBundleLines;
              final completedCount = lines.where((l) => l.actualQty >= l.demandQty).length;
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.borderTable,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '事前セット：',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'MSPGothic',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.transNo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'MSPGothic',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$completedCount/${lines.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'MSPGothic',
                        color: completedCount == lines.length 
                            ? AppColors.greenDark 
                            : AppColors.textError,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Items List
          Expanded(
            child: Consumer<BundleProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingIndicator(size: 100);
                }

                final lines = provider.currentBundleLines;
                if (lines.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No bundle items found',
                          style: TextStyle(fontSize: 16),
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
                  padding: const EdgeInsets.all(8),
                  itemCount: lines.length,
                  itemBuilder: (context, index) {
                    final line = lines[index];
                    final isSelected = _selectedIndex == index;
                    final statusLabel = _getStatusLabel(line.actualQty, line.demandQty);
                    final statusColor = _getStatusColor(line.actualQty, line.demandQty);

                    return InkWell(
                      onTap: () => _handleItemTap(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.headerColor
                              : Colors.white,
                          border: Border.all(
                            color: AppColors.borderTable,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Bin number
                                  Row(
                                    children: [
                                      const Text(
                                        '棚番：',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          fontFamily: 'MSPGothic',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        line.bin ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'MSPGothic',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Product
                                  Row(
                                    children: [
                                      const Text(
                                        '商品：',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          fontFamily: 'MSPGothic',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          line.productName ?? line.productCode,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'MSPGothic',
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Quantity
                                  Row(
                                    children: [
                                      const Text(
                                        '数量：',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          fontFamily: 'MSPGothic',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${line.demandQty.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'MSPGothic',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Status
                                  Row(
                                    children: [
                                      const Text(
                                        'ステータス：',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          fontFamily: 'MSPGothic',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        statusLabel,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'MSPGothic',
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

