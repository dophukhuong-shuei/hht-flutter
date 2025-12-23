import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme_config.dart';
import '../widgets/custom_button.dart';
import '../widgets/data_table_widget.dart';
import '../widgets/custom_input.dart';
import '../widgets/image_upload_widget.dart';

class WRDetailScreen extends StatefulWidget {
  final String? id;

  const WRDetailScreen({Key? key, this.id}) : super(key: key);

  @override
  State<WRDetailScreen> createState() => _WRDetailScreenState();
}

class _WRDetailScreenState extends State<WRDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiptNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loadData();
    }
  }

  void _loadData() {
    // Load data based on id
    _receiptNoController.text = 'WR${widget.id}';
  }

  @override
  void dispose() {
    _receiptNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id != null ? '入荷詳細' : '新規入荷'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _handleSave,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '基本情報',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        label: '入荷番号',
                        controller: _receiptNoController,
                        readOnly: widget.id != null,
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        label: '日付',
                        readOnly: true,
                        initialValue: '2025-01-01',
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Items Table
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'アイテム一覧',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CustomButton(
                            text: '追加',
                            type: ButtonType.primary,
                            onPressed: () {
                              // Add item
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DataTableWidget(
                        columns: const [
                          DataTableColumn(label: '商品コード', width: 150),
                          DataTableColumn(label: '商品名', width: 200),
                          DataTableColumn(label: '数量', width: 100),
                          DataTableColumn(label: '操作', width: 100),
                        ],
                        rows: [
                          [
                            const Text('P001'),
                            const Text('商品名1'),
                            const Text('10'),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: null,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Image Upload
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '画像',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ImageUploadWidget(
                        label: '商品画像',
                        onImageSelected: (file) {
                          // Handle image selection
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'キャンセル',
                    type: ButtonType.outline,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 16),
                  CustomButton(
                    text: '保存',
                    type: ButtonType.success,
                    onPressed: _handleSave,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // Save logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存しました')),
      );
      context.pop();
    }
  }
}

