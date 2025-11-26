## **_SmartBudget – SQLite Integration_**

How SQLite is integrated into the SmartBudget app and how the PaymentDao handles payment data.

### SQLite Database Setup

Database Singleton

**File: lib/data/app_database.dart**

Database path is obtained via getDatabasesPath() and tables are created in onCreate.

**Payment Table**

Payments are stored in the following SQLite table:

CREATE TABLE payments (
1. id TEXT PRIMARY KEY,
2. amount REAL NOT NULL,
3. category TEXT NOT NULL,
4. note TEXT,
5. date TEXT NOT NULL,
6. isIncome INTEGER NOT NULL,
7. isSafing INTEGER DEFAULT 0
);


#### **Columns:**

id – unique identifier (string)

amount – payment amount (double)

category – category of payment (string)

note – optional description (string)

date – date of payment (ISO 8601 string)

isIncome – true if the payment is income, false if expense

isSafing – optional flag for special cases (default false)

**#### PaymentDao – CRUD Operations**

File: lib/data/payment_dao.dart

Handles all interactions with the payments table.

### **Methods**

#### **_Insert Payment_**

Future<int> insertPayment(Payment payment);


Converts Payment object to a map using toMap() and inserts into SQLite.

#### **_Get All Payments_**

Future<List<Payment>> getAllPayments();


Reads all rows from payments table and converts each row to a Payment object via Payment.fromMap().

#### **_Update Payment_**

Future<int> updatePayment(Payment payment);


Updates an existing payment by id.

#### **_Delete Payment_**

Future<int> deletePayment(String id);


Deletes a payment by id from SQLite.

#### **_Get Payments by Month (example for reports)_**

Future<List<Payment>> getPaymentsByMonth(int year, int month);


Retrieves payments for a specific month/year, useful for ReportsScreen.

### **_How It Works_**

The app calls AppDatabase.instance.database to get a database connection.

PaymentDao performs operations (insert, update, delete, query) directly on SQLite.

Payment objects are converted to/from Map<String, dynamic> for SQLite storage.

All payment-related screens (e.g., PaymentMonitoringPage, ReportsScreen) use PaymentDao to load data.