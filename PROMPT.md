# Prompt để tạo dự án Flutter mới tương tự

## Prompt cho AI Assistant

```
Tôi cần tạo một dự án Flutter mới cho Warehouse Management System với các yêu cầu sau:

1. **Cấu trúc dự án:**
   - Sử dụng clean architecture pattern
   - Tách biệt rõ ràng: config, core, data, presentation, routes, services
   - Tên dự án: fbt_hht_flutter

2. **Dependencies cần thiết:**
   - State management: provider hoặc riverpod
   - Navigation: go_router
   - Network: dio, retrofit
   - Storage: shared_preferences
   - UI: google_fonts, flutter_screenutil
   - Scanner: mobile_scanner
   - Image: image_picker, cached_network_image
   - Sound: audioplayers

3. **Components cần tạo:**
   - CustomButton: Button với nhiều types (primary, secondary, danger, success, outline)
   - CustomInput: Text input với validation và styling
   - CustomCheckbox: Checkbox component
   - CustomDropdown: Dropdown với custom items
   - DataTableWidget: Table để hiển thị dữ liệu
   - ListViewWidget: List view với empty state và loading
   - FilterWidget: Filter component với text, dropdown, date fields
   - ImageUploadWidget: Upload và preview ảnh từ gallery/camera
   - ImageViewWidget: Xem ảnh với fullscreen mode

4. **Navigation Pattern:**
   - Sử dụng GoRouter
   - Pattern: List Screen -> Detail Screen (ẩn list khi vào detail)
   - Filter có thể show/hide trên list screen

5. **Theme & Styling:**
   - Tạo theme_config.dart với colors, typography
   - Sử dụng Material 3
   - Support Japanese fonts
   - Consistent spacing và border radius

6. **Screens cần tạo:**
   - Login Screen: Username/password input, QR login option
   - Main Menu Screen: 7 menu items với colors khác nhau
   - List Screen: Hiển thị danh sách với filter
   - Detail Screen: Form để view/edit với table, image upload

7. **Config files:**
   - app_config.dart: API endpoints, storage keys, version
   - theme_config.dart: Colors, theme settings

Hãy tạo dự án với cấu trúc đầy đủ và các components có thể tái sử dụng.
```

## Hướng dẫn tạo thủ công

1. **Tạo dự án:**
```bash
flutter create fbt_hht_flutter --org com.fbt --project-name fbt_hht
```

2. **Cập nhật pubspec.yaml** với dependencies đã liệt kê

3. **Tạo cấu trúc thư mục:**
```bash
mkdir -p lib/config lib/core/network lib/core/storage lib/core/utils \
  lib/data/models lib/data/repositories lib/data/datasources/remote \
  lib/data/datasources/local lib/presentation/auth lib/presentation/dashboard \
  lib/presentation/widgets lib/presentation/providers lib/routes lib/services
```

4. **Tạo các file config và components** theo cấu trúc đã định

5. **Chạy:**
```bash
flutter pub get
flutter run
```

