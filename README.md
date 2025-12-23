# FBT HHT Flutter - Warehouse Management System

Ứng dụng quản lý kho hàng được xây dựng bằng Flutter + Dart, clone từ dự án React Native gốc.

## 🚀 Tính năng

- ✅ Authentication (Login với username/password hoặc QR code)
- ✅ Dashboard/Main Menu với 7 modules chính
- ✅ Warehouse Receipt (入荷)
- ✅ Putaway (棚上げ)
- ✅ Picking (ピッキング)
- ✅ Bundle (事前セット)
- ✅ Bin Movement (棚移動)
- ✅ Bin Audit (棚卸)

## 📁 Cấu trúc dự án

```
lib/
├── config/              # Configuration files
│   ├── app_config.dart
│   └── theme_config.dart
├── core/                # Core functionality
│   ├── network/         # API client, endpoints
│   ├── storage/         # Local storage
│   └── utils/           # Utilities
├── data/                # Data layer
│   ├── models/          # Data models
│   ├── repositories/    # Repository pattern
│   └── datasources/    # Remote & local data sources
├── presentation/        # UI layer
│   ├── auth/           # Authentication screens
│   ├── dashboard/      # Main menu
│   ├── widgets/        # Reusable widgets
│   └── providers/      # State management
├── routes/             # Navigation
└── services/           # Services (scanner, sound, etc.)
```

## 🎨 Components

### Core Components
- **CustomButton**: Button với nhiều styles (primary, secondary, danger, success, outline)
- **CustomInput**: Text input với validation
- **CustomCheckbox**: Checkbox component
- **CustomDropdown**: Dropdown với search và custom items

### UI Components
- **DataTableWidget**: Table hiển thị dữ liệu dạng bảng
- **ListViewWidget**: List view với empty state và loading
- **FilterWidget**: Filter component với nhiều loại field
- **ImageUploadWidget**: Upload và preview ảnh
- **ImageViewWidget**: Xem ảnh với fullscreen mode

## 🛠️ Cài đặt

1. Clone repository:
```bash
git clone <repository-url>
cd fbt_hht_flutter
```

2. Cài đặt dependencies:
```bash
flutter pub get
```

3. Chạy ứng dụng:
```bash
flutter run
```

## 📱 Navigation Pattern

Ứng dụng sử dụng GoRouter với pattern:
- **List Screen**: Hiển thị danh sách items
- **Detail Screen**: Khi click vào item, mở detail screen và ẩn list screen
- **Filter**: Có thể show/hide filter trên list screen

### Ví dụ:
```dart
// Navigate to detail
context.push('${RouteNames.warehouseReceipt}/detail?id=${item['id']}');

// Go back
context.pop();
```

## 🎯 Sử dụng Components

### CustomButton
```dart
CustomButton(
  text: '保存',
  type: ButtonType.success,
  isFullWidth: true,
  onPressed: () {},
  isLoading: false,
)
```

### CustomInput
```dart
CustomInput(
  label: 'ユーザー名',
  controller: _controller,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    return null;
  },
)
```

### CustomDropdown
```dart
CustomDropdown(
  label: '選択',
  value: _selectedValue,
  items: [
    DropdownItem(value: 1, label: 'Option 1'),
    DropdownItem(value: 2, label: 'Option 2'),
  ],
  onChanged: (value) {
    setState(() {
      _selectedValue = value;
    });
  },
)
```

### DataTableWidget
```dart
DataTableWidget(
  columns: [
    DataTableColumn(label: 'ID', width: 100),
    DataTableColumn(label: 'Name', width: 200),
  ],
  rows: [
    [Text('1'), Text('Item 1')],
    [Text('2'), Text('Item 2')],
  ],
  onRowTap: (index) {
    // Handle row tap
  },
)
```

### FilterWidget
```dart
FilterWidget(
  fields: [
    FilterField(
      key: 'name',
      label: '名前',
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
  },
)
```

### ImageUploadWidget
```dart
ImageUploadWidget(
  label: '画像',
  onImageSelected: (file) {
    // Handle image
  },
)
```

## 🔧 Configuration

### App Config (`lib/config/app_config.dart`)
- API host
- Storage keys
- Version info

### Theme Config (`lib/config/theme_config.dart`)
- Colors
- Typography
- Theme settings

## 📝 TODO

- [ ] Implement API integration
- [ ] Add state management (Provider/Riverpod)
- [ ] Implement QR scanner
- [ ] Add sound notifications
- [ ] Implement offline support
- [ ] Add unit tests
- [ ] Add integration tests

## 📄 License

Private project
