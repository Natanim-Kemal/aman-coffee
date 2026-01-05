# Coffee Business Management App - Feature Implementation Plan

## 📋 Project Overview

**App Name:** Cofiz (Coffee Distribution Management)  
**Purpose:** Manage and track money transactions for workers who receive distributions to purchase coffee for the company  
**Platform:** Flutter (Android/iOS)  
**Current Status:** UI/Design implementation complete, functionality pending

---

## 🎯 Core Business Logic

### Business Flow:
1. **Admin distributes money** to workers for coffee purchases
2. **Workers buy coffee** using the distributed money
3. **Workers return** remaining money (if any)
4. **System tracks** all transactions, coffee purchases, and worker performance
5. **Reports generated** for financial oversight and analysis

---

## 🗄️ Database Schema

### **1. Users Table**
```dart
class User {
  String id;
  String name;
  String email;
  String password; // hashed
  String role; // 'admin', 'manager', 'viewer'
  String phone;
  String? photoUrl;
  DateTime createdAt;
  DateTime lastLogin;
  bool isActive;
}
```

### **2. Workers Table**
```dart
class Worker {
  String id;
  String name;
  String phone;
  String? email;
  String role; // 'Senior Tailor', 'Junior Tailor', etc.
  int yearsOfExperience;
  String status; // 'active', 'busy', 'offline', 'suspended'
  double performanceRating; // 0-100
  String? photoUrl;
  double currentBalance; // money currently held
  double totalDistributed; // lifetime total
  double totalReturned; // lifetime total
  double totalCoffeePurchased; // lifetime total
  DateTime createdAt;
  DateTime? lastActiveAt;
  bool isActive;
}
```

### **3. Transactions Table**
```dart
class Transaction {
  String id;
  String workerId;
  String type; // 'distribution', 'return', 'purchase'
  double amount;
  String? description;
  DateTime transactionDate;
  String status; // 'completed', 'pending', 'cancelled'
  String? receiptUrl; // for coffee purchases
  String createdBy; // userId who made the transaction
  DateTime createdAt;
  
  // For coffee purchases
  double? coffeeQuantity; // kg or units
  double? coffeePrice; // price per unit
  String? supplier;
}
```

### **4. Coffee Purchases Table** (Optional - detailed tracking)
```dart
class CoffeePurchase {
  String id;
  String workerId;
  String transactionId;
  double quantity; // kg
  double pricePerKg;
  double totalAmount;
  String supplier;
  String? quality; // 'Grade A', 'Grade B', etc.
  DateTime purchaseDate;
  String? receiptUrl;
  String? notes;
}
```

### **5. Reports Table** (for saved/exported reports)
```dart
class Report {
  String id;
  String type; // 'monthly', 'custom', 'worker_performance'
  DateTime startDate;
  DateTime endDate;
  String? workerId; // if worker-specific
  Map<String, dynamic> data; // JSON data
  String generatedBy;
  DateTime createdAt;
  String? exportedFileUrl;
}
```

---

## 🏗️ Technical Architecture

### **State Management:** Provider / Riverpod
- Centralized state for workers, transactions, statistics
- Real-time updates across screens
- Efficient rebuilds

### **Local Storage:** Hive / SQLite
- Offline-first approach
- Fast local data access
- Sync with backend when online

### **Backend Options:**
1. **Firebase** (Recommended for MVP)
   - Firestore for database
   - Firebase Auth for authentication
   - Firebase Storage for images/receipts
   - Cloud Functions for complex calculations

2. **Custom API** (Node.js/Laravel)
   - RESTful API
   - MySQL/PostgreSQL database
   - JWT authentication

### **Additional Packages:**
```yaml
dependencies:
  # State Management
  provider: ^6.0.0
  
  # Local Database
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Backend (Firebase option)
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  
  # UI/UX
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  
  # Phone/Communication
  url_launcher: ^6.2.2
  flutter_phone_direct_caller: ^2.1.1
  
  # Charts
  fl_chart: ^0.66.0
  
  # PDF/Excel Export
  pdf: ^3.10.7
  excel: ^4.0.2
  path_provider: ^2.1.1
  
  # Date/Time
  intl: ^0.18.1
  
  # Image Picker
  image_picker: ^1.0.5
  
  # Permissions
  permission_handler: ^11.1.0
```

---

## 🚀 Feature Implementation Roadmap

## **Phase 1: Core Functionality (Week 1-2)**

### ✅ **1.1 Authentication System**
- [x] Create login screen with validation
- [x] Implement Firebase Auth / Custom API auth
- [x] Add password reset functionality
- [x] Session management
- [x] Auto-login with saved credentials
- [x] Logout functionality

**Files to modify:**
- `lib/presentation/screens/auth/login_screen.dart`
- Create: `lib/core/services/auth_service.dart`
- Create: `lib/core/providers/auth_provider.dart`

---

### ✅ **1.2 Worker Management**

#### 1.2.1 Worker List (Worker Page - flutter_01.png)
- [x] Fetch workers from database
- [x] Display worker list with real data
- [x] Implement search functionality
- [x] Implement filter by status
- [ ] Sort workers (name, performance, etc.)
- [x] Pull-to-refresh

**Functionalities:**
- **Search:** Filter workers by name in real-time
- **Filter:** Show only Active/Busy/Offline workers
- **Actions:**
  - [x] **Call:** Launch phone dialer with worker's number
  - [x] **Message:** Open SMS app or in-app messaging
  - [x] **View:** Navigate to worker detail page

**Files to modify:**
- `lib/presentation/screens/worker_list/worker_list_screen.dart`
- Create: `lib/core/services/worker_service.dart`
- Create: `lib/core/providers/worker_provider.dart`

#### 1.2.2 Worker Details Page
- [x] Create worker detail screen
- [x] Show complete worker information
- [x] Display transaction history for this worker
- [x] Show current balance
- [x] Edit worker button
- [x] Delete worker (with confirmation)

**Create new file:** `lib/presentation/screens/worker_detail/worker_detail_screen.dart`

#### 1.2.3 Add/Edit Worker
- [x] Create form for adding new worker
- [ ] Photo upload functionality
- [x] Validation (name, phone required)
- [x] Save to database
- [x] Update existing worker info

**Create new file:** `lib/presentation/screens/worker_form/worker_form_screen.dart`

---

### ✅ **1.3 Statistics Calculation**

#### Real-time Stats (shown on Dashboard and Workers page):
- [x] **Total Workers:** Count all active workers
- [x] **Active Today:** Count workers with status = 'active'
- [x] **Total Revenue:** Sum of all distributed amounts (or coffee purchased?)
- [x] **Avg Performance:** Calculate average performance rating

**Create:** `lib/core/services/statistics_service.dart`

---

## **Phase 2: Transaction Management (Week 3)**

### ✅ **2.1 Dashboard (flutter_02.png)**

#### 2.1.1 Dashboard Overview
- [x] Welcome message with current user name
- [x] Monthly overview statistics:
  - [x] Total Distributed this month
  - [x] Active Workers count
  - [x] Pending Returns amount
  - [x] Coffee Purchased this month
- [x] Quick action buttons (functional)
- [x] Recent transactions list (last 10)
- [x] Activity chart (monthly trend)

**Files to modify:**
- `lib/presentation/screens/dashboard/dashboard_screen.dart`
- Create: `lib/core/services/transaction_service.dart`
- Create: `lib/core/providers/transaction_provider.dart`

#### 2.1.2 Quick Actions Implementation
- [x] **New Distribution:** Open distribution form
- [x] **Add Worker:** Navigate to worker form
- [ ] **View Reports:** Navigate to reports page
- [ ] **Settings:** Navigate to settings

#### 2.1.3 Recent Transactions Feed
- [x] Fetch last 10 transactions
- [x] Show worker name, type, amount, date
- [x] Color coding (green for returns, red for distributions)
- [x] Tap to view transaction details

---

### ✅ **2.2 Money Distribution**

#### 2.2.1 Create Distribution Form
- [x] Select worker (dropdown or search)
- [x] Enter amount
- [x] Add description/notes
- [ ] Date picker (default: today)
- [x] Take photo of receipt (optional)
- [x] Validation
- [x] Save transaction
- [x] Update worker's current balance

**Create new file:** `lib/presentation/screens/transactions/distribution_form_screen.dart`
**(Implemented as transaction dialog instead)**

#### 2.2.2 Record Money Return
- [x] Select worker
- [x] Show current balance
- [x] Enter return amount (must not exceed balance)
- [x] Add notes
- [x] Save transaction
- [x] Update worker's current balance

**Create new file:** `lib/presentation/screens/transactions/return_form_screen.dart`
**(Implemented as transaction dialog instead)**

#### 2.2.3 Record Coffee Purchase
- [x] Select worker
- [x] Enter coffee quantity (kg) - *Simplified to amount*
- [x] Enter price per kg - *Simplified to total amount*
- [x] Auto-calculate total amount
- [ ] Supplier name
- [ ] Quality/Grade
- [x] Upload receipt photo
- [x] Deduct from worker's balance
- [x] Save transaction

**Create new file:** `lib/presentation/screens/transactions/coffee_purchase_form_screen.dart`
**(Implemented as transaction dialog instead)**

---

## **Phase 3: Reports & Analytics (Week 4)**

### ✅ **3.1 Reports Page (flutter_03.png)**

#### 3.1.1 Filters
- [ ] Date range picker (From/To)
- [ ] Transaction type filter (All, Distributed, Returned, Purchased)
- [ ] Worker filter (All or specific worker)
- [ ] Status filter

#### 3.1.2 Summary Cards
- [ ] Calculate total distributed in date range
- [ ] Calculate total returned in date range
- [ ] Calculate net amount
- [ ] Count number of transactions

#### 3.1.3 Transaction List
- [ ] Fetch transactions based on filters
- [ ] Display in list format
- [ ] Pagination or infinite scroll
- [ ] Tap to view details

#### 3.1.4 Export Functionality
- [ ] **Export to PDF:**
  - Generate PDF with company header
  - Include summary statistics
  - Include transaction table
  - Save to device
### ✅ **3.1 Reports Screen**
- [x] Create dedicated reports page
- [x] Date range filter (Daily, Weekly, Monthly)
- [x] Summary cards (Total Distributed, Returned, Profit)
- [x] Transaction list with filtering
- [x] Export to PDF/Excel (PDF implemented)

**Create:** `lib/presentation/screens/reports/reports_screen.dart`
**Create:** `lib/core/services/report_service.dart`

### ⬜ **3.2 Advanced Features (Bonus)**
- [ ] Worker performance ranking
- [ ] Automated weekly email reports
- [ ] Offline support improvements
- [ ] Dark mode toggle (Settings)

---

## **Phase 4: Settings & User Management (Week 5)**

### ✅ **4.1 Settings Page (flutter_04.png)**

#### 4.1.1 Profile Management
- [ ] Display current user info
- [ ] Edit profile (name, email, photo)
- [ ] Change password
- [ ] Update user in database

#### 4.1.2 Notification Settings
- [ ] Toggle email notifications
- [ ] Toggle SMS notifications
- [ ] Toggle push notifications
- [ ] Save preferences

#### 4.1.3 App Settings
- [ ] Language selection (Amharic, English)
- [ ] Currency display (Birr)
- [ ] Theme switcher (Light/Dark)
- [ ] Save to local storage

#### 4.1.4 Business Settings
- [ ] Edit company information
- [ ] Set distribution limits (max amount per worker)
- [ ] Default coffee prices
- [ ] Save to database

#### 4.1.5 Data Management
- [ ] **Backup Data:** Export all data to JSON file
- [ ] **Export All Data:** Generate comprehensive report
- [ ] **Clear Cache:** Clear local storage
- [ ] Warning dialogs for destructive actions

#### 4.1.6 About Section
- [ ] Display app version
- [ ] Terms & Conditions page
- [ ] Privacy Policy page
- [ ] Contact support

#### 4.1.7 Logout
- [ ] Confirm logout dialog
- [ ] Clear session
- [ ] Navigate to login screen

**Files to modify:**
- `lib/presentation/screens/settings/settings_screen.dart`
- Create: `lib/presentation/screens/settings/profile_edit_screen.dart`
- Create: `lib/presentation/screens/settings/company_settings_screen.dart`
- Create: `lib/core/services/settings_service.dart`

---

## **Phase 5: Advanced Features (Week 6+)**

### ✅ **5.1 Notifications**
- [ ] Push notifications for new distributions
- [ ] Reminders for pending returns
- [ ] Low balance alerts
- [ ] Daily/weekly summary notifications

### ✅ **5.2 Offline Mode**
- [ ] Cache all data locally with Hive
- [ ] Queue transactions when offline
- [ ] Sync when connection restored
- [ ] Show offline indicator

### ✅ **5.3 Multi-user Support**
- [ ] Role-based access control
- [ ] Admin can manage users
- [ ] Audit log (who did what)
- [ ] User activity tracking

### ✅ **5.4 Advanced Analytics**
- [ ] Worker performance trends
- [ ] Best performing workers
- [ ] Coffee purchase patterns
- [ ] Financial forecasting
- [ ] Custom date comparisons

### ✅ **5.5 Data Validation**
- [ ] Prevent negative balances
- [ ] Warn if distribution exceeds business limits
- [ ] Validate phone numbers, emails
- [ ] Duplicate detection

### ✅ **5.6 Search & Filtering Enhancements**
- [ ] Advanced search across all data
- [ ] Saved search filters
- [ ] Recent searches
- [ ] Autocomplete suggestions

---

## 🎨 UI/UX Enhancements

### **Loading States**
- [ ] Shimmer loading for lists
- [ ] Progress indicators for forms
- [ ] Skeleton screens

### **Error Handling**
- [ ] User-friendly error messages
- [ ] Retry mechanisms
- [ ] Offline error handling
- [ ] Form validation messages

### **Animations**
- [ ] Page transitions
- [ ] List item animations
- [ ] Button feedback
- [ ] Chart animations

### **Empty States**
- [ ] No workers yet
- [ ] No transactions
- [ ] No search results
- [ ] Helpful illustrations

---

## 📊 Data Models (Dart Classes)

### Location: `lib/core/models/`

Create the following model files:
- `user_model.dart`
- `worker_model.dart`
- `transaction_model.dart`
- `coffee_purchase_model.dart`
- `report_model.dart`

Each model should include:
- Properties
- Constructor
- `fromJson()` factory
- `toJson()` method
- `copyWith()` method

---

## 🔐 Security Considerations

1. **Authentication:**
   - Implement proper password hashing
   - Session timeout after inactivity
   - Secure token storage

2. **Data Protection:**
   - Encrypt sensitive local data
   - HTTPS for all API calls
   - Input sanitization

3. **Authorization:**
   - Role-based permissions
   - Restrict delete operations to admins
   - Audit trail for financial transactions

4. **Validation:**
   - Server-side validation for all inputs
   - Amount limits enforcement
   - Phone/email format validation

---

## 🧪 Testing Strategy

### **Unit Tests**
- [ ] Model serialization/deserialization
- [ ] Business logic calculations
- [ ] Service layer methods

### **Widget Tests**
- [ ] Form validation
- [ ] Button interactions
- [ ] Navigation flows

### **Integration Tests**
- [ ] End-to-end user flows
- [ ] Database operations
- [ ] API interactions

---

## 📱 Deployment Checklist

### **Before Launch:**
- [ ] Test on multiple devices
- [ ] Performance optimization
- [ ] Remove debug code
- [ ] Update app icons and splash screen
- [ ] Prepare store listings (Play Store, App Store)
- [ ] Privacy policy and terms
- [ ] Beta testing with real users
- [ ] Set up analytics (Google Analytics, Firebase)
- [ ] Set up crash reporting (Firebase Crashlytics)

---

## 📝 Development Best Practices

1. **Code Organization:**
   - Follow Clean Architecture principles
   - Separate business logic from UI
   - Use dependency injection

2. **Git Workflow:**
   - Create feature branches
   - Meaningful commit messages
   - Regular commits
   - Code reviews before merge

3. **Documentation:**
   - Comment complex logic
   - Update README
   - API documentation
   - User manual

4. **Performance:**
   - Lazy loading for lists
   - Image optimization
   - Debounce search inputs
   - Cache frequently accessed data

---

## 🎯 Success Metrics

### **Technical KPIs:**
- App load time < 3 seconds
- Transaction save time < 1 second
- 99% crash-free rate
- Support for Android 6.0+

### **Business KPIs:**
- Track all worker distributions
- Accurate financial reporting
- Reduce manual record-keeping time
- Improve transaction transparency

---

## 📞 Support & Maintenance

### **Post-Launch:**
- Monitor crash reports
- User feedback collection
- Regular updates
- Bug fixes
- Feature enhancements based on user requests

---

## 🗓️ Estimated Timeline

| Phase | Duration | Tasks |
|-------|----------|-------|
| Phase 1 | 2 weeks | Auth + Worker Management + Stats |
| Phase 2 | 1 week | Transactions (Distribution, Return, Purchase) |
| Phase 3 | 1 week | Reports & Analytics |
| Phase 4 | 1 week | Settings & User Management |
| Phase 5 | 2+ weeks | Advanced Features |
| Testing | 1 week | QA, Bug fixes |
| **Total** | **8-10 weeks** | Full MVP completion |

---

## 💡 Future Enhancements

1. **SMS Integration:** Send transaction receipts via SMS
2. **Barcode/QR Scanner:** Quick worker identification
3. **Voice Input:** Record transactions via voice
4. **Multi-currency Support:** For international expansion
5. **Inventory Management:** Full coffee stock tracking
6. **Supplier Management:** Track coffee suppliers
7. **Payroll Integration:** Link with salary system
8. **Mobile Web Version:** PWA for desktop access
9. **WhatsApp Integration:** Send reports via WhatsApp
10. **Biometric Authentication:** Fingerprint/Face ID

---

## 📚 Resources & Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Provider State Management](https://pub.dev/packages/provider)
- [Hive Database](https://docs.hivedb.dev/)

---

## ✅ Ready to Start?

This implementation plan provides a complete roadmap for building your coffee business management app. 

**Next Steps:**
1. Review and approve this plan
2. Set up development environment
3. Choose backend (Firebase vs Custom API)
4. Start with Phase 1: Authentication & Worker Management

**Questions? Adjustments needed?** Let me know and we can refine the plan before starting development!
