import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme_config.dart';
import '../widgets/list_view_widget.dart';
import '../widgets/filter_widget.dart';
import '../widgets/custom_button.dart';
import 'wr_detail_screen.dart';
import '../../routes/route_names.dart';

class WRListScreen extends StatefulWidget {
  const WRListScreen({Key? key}) : super(key: key);

  @override
  State<WRListScreen> createState() => _WRListScreenState();
}

class _WRListScreenState extends State<WRListScreen> {
  final List<Map<String, dynamic>> _items = [
    {'id': '1', 'receiptNo': 'WR001', 'date': '2025-01-01', 'status': 'Pending'},
    {'id': '2', 'receiptNo': 'WR002', 'date': '2025-01-02', 'status': 'In Progress'},
    {'id': '3', 'receiptNo': 'WR003', 'date': '2025-01-03', 'status': 'Completed'},
  ];

  bool _showFilter = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('入荷一覧'),
        actions: [
          IconButton(
            icon: Icon(_showFilter ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () {
              setState(() {
                _showFilter = !_showFilter;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilter)
            FilterWidget(
              fields: [
                FilterField(
                  key: 'receiptNo',
                  label: '入荷番号',
                  type: FilterFieldType.text,
                ),
                FilterField(
                  key: 'date',
                  label: '日付',
                  type: FilterFieldType.date,
                ),
              ],
              onFilter: (filters) {
                // Handle filter
                print('Filters: $filters');
              },
            ),
          Expanded(
            child: ListViewWidget<Map<String, dynamic>>(
              items: _items,
              itemBuilder: (context, item, index) {
                return ListItemCard(
                  onTap: () {
                    // Navigate to detail screen, hide list
                    context.push(
                      '${RouteNames.warehouseReceipt}/detail?id=${item['id']}',
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '入荷番号: ${item['receiptNo']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(item['status']),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['status'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '日付: ${item['date']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPlaceholder,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new item
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.btnGreen;
      case 'In Progress':
        return AppColors.primary;
      default:
        return AppColors.gray;
    }
  }
}

