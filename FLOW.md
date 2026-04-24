Build a mobile application using Flutter integrated with Supabase as the backend for a warehouse inventory management system.

Use the following database schema as the core data model:

- items (id, name, sku, description, image_url, created_at)
- inventory (id, item_id, quantity, updated_at)
- stock_movements (id, item_id, type ['in','out'], quantity, note, created_by, created_at)
- profiles (id, name, role ['manager','staff'], created_at)

---

## 🧠 COMPUTATIONAL THINKING APPROACH

### 1. Problem Decomposition
Break down the system into modules:
- Authentication (login & role management)
- Item Management (CRUD + image upload)
- Inventory Management (stock tracking via movements)
- Dashboard (analytics & summary)
- Transaction History (filterable logs)

---

### 2. Pattern Recognition
Identify reusable patterns:
- CRUD pattern for items
- Form handling (add/edit item, stock input)
- API calls to Supabase (fetch, insert, update)
- State management pattern (loading, success, error)
- Reusable UI components (cards, lists, buttons)

---

### 3. Abstraction
Separate concerns clearly:
- UI Layer (Flutter Widgets)
- Business Logic Layer (State Management: Riverpod/Bloc/Provider)
- Data Layer (Supabase API calls)
- Storage Layer (image upload to Supabase Storage)

Avoid tightly coupling UI with database logic.

---

### 4. Algorithm Design (Step-by-step logic)

#### Add Item:
1. User inputs item data
2. Upload image to Supabase Storage (bucket: `gambar-barang`)
3. Get public URL
4. Insert into `items` table

#### Stock In:
1. User inputs quantity
2. Insert into `stock_movements` (type = 'in')
3. Database trigger updates inventory

#### Stock Out:
1. Fetch current stock
2. Validate quantity (must not exceed stock)
3. Insert into `stock_movements` (type = 'out')

#### Delete Item:
1. Delete item from database
2. Delete image from storage

---

### 5. User Flow

1. User opens app
2. Login → authentication via Supabase
3. Redirect to Dashboard
4. Navigate via bottom navigation:
   - Dashboard → overview
   - Items → manage products
   - Transactions → stock history
   - Profile → user info
5. Perform actions (add item, update stock, view reports)

---

## 🔐 Authentication
- Use Supabase Auth (email & password)
- Fetch profile after login
- Role-based access:
  - manager → full access
  - staff → restricted (no delete)

---

## 📦 Item Management (CRUD)
- Create item:
  - name, sku, description, image
  - upload image to bucket: `gambar-barang`
  - store image_url

- Read:
  - list items with stock (join inventory)

- Update:
  - edit item & replace image

- Delete:
  - remove item + delete image from storage

---

## 🔄 Stock Management
- Stock In → insert movement (type = 'in')
- Stock Out → insert movement (type = 'out')
- Prevent negative stock
- DO NOT update inventory directly from frontend

---

## 📊 Dashboard
Display:
- Total items
- Total stock
- Low stock items (< 5)
- Recent transactions
- Simple chart (stock in vs out)

---

## 📜 Transaction History
- List stock_movements
- Filter:
  - by date
  - by type
- Show:
  - item name
  - quantity
  - type
  - user

---

## 🖼️ Storage
- Bucket: `gambar-barang`
- Structure:
  items/{item_id}/main.jpg
- Use public URLs

---

## 🎨 UI/UX REQUIREMENTS (IMPORTANT)
- Minimalist design
- NO gradients
- Use solid colors only
- Clean spacing and typography
- Flat design (no heavy shadows)
- Use card-based layout
- Consistent padding & margin
- Focus on readability and usability

Bottom navigation:
- Dashboard
- Items
- Transactions
- Profile

---

## ⚙️ Technical Requirements
- Flutter (latest stable)
- Packages:
  - supabase_flutter
  - image_picker
  - state management (choose one: Riverpod / Bloc / Provider)

- Use clean architecture or MVVM

---

## ⚠️ Validation & Edge Cases
- Prevent negative stock
- Handle upload errors
- Handle network failures
- Show loading indicators

---

## 🎯 Expected Output
Provide:

1. Project folder structure
2. Code examples:
   - authentication (login)
   - fetch items + inventory join
   - insert stock movement
   - upload image to Supabase Storage
3. UI examples:
   - dashboard screen
   - item list screen
   - add/edit item form

Ensure code is modular, readable, and production-ready.