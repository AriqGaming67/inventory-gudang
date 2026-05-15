# Inventory Gudang

> Warehouse inventory management app built with Flutter and Supabase, designed for secure item tracking, stock movement logging, and operational visibility.

[Flutter](https://flutter.dev) | [Supabase](https://supabase.com) | [Riverpod](https://riverpod.dev) | [GoRouter](https://pub.dev/packages/go_router)

## Overview

Inventory Gudang is a Flutter-based warehouse inventory system that supports authentication, item management, stock in/out recording, transaction history, and a summary dashboard. The app is structured for clean state management, modular data access, and straightforward Supabase integration.

## Key Features

- Supabase Auth for login and registration.
- Inventory dashboard with total items, total stock, and low stock indicators.
- Full item CRUD with image upload to Supabase Storage.
- Stock in and stock out tracking with validation.
- Filterable transaction history.
- User profile, role awareness, and persistent theme settings.

## Tech Stack

| Layer            | Tools                            |
| ---------------- | -------------------------------- |
| Frontend         | Flutter, Material 3              |
| State Management | Riverpod                         |
| Routing          | GoRouter                         |
| Backend          | Supabase Auth, Database, Storage |
| Media            | Image Picker                     |
| Local Storage    | Shared Preferences               |
| Config           | Flutter Dotenv                   |

## Project Structure

```text
lib/
├── main.dart
├── models/
├── providers/
├── repositories/
├── screens/
└── widgets/
```

## Requirements

- Flutter SDK compatible with the project.
- An active Supabase project.
- A `.env` file in the project root.

## Environment Variables

Create a `.env` file in the root directory:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

The `.env` file is already declared as an asset in `pubspec.yaml`.

## Setup

```bash
flutter pub get
flutter run
```

Use the standard Flutter build command for any target platform you need.

## Core Modules

- Authentication: email/password login and registration.
- Dashboard: compact inventory summary for quick review.
- Items: list, create, update, and delete items with images.
- Transactions: record stock movement and prevent invalid stock-out operations.
- Profile: display user information and theme preference.

## Database Tables

The app is built around these tables:

- `items`
- `inventory`
- `stock_movements`
- `profiles`

## Supabase RLS (Important)

If you enable Row Level Security (RLS) on the `inventory` table, stock transactions can fail with:

`PostgrestException(code: 42501) new row violates row-level security policy for table "inventory"`

This typically happens because inserting a row into `stock_movements` triggers an `UPSERT` into `inventory`, but `inventory` has no `INSERT/UPDATE` policy for the current role.

- Fix: run the SQL in [supabase/inventory_rls.sql](supabase/inventory_rls.sql) via Supabase **SQL Editor**.
- Alternative (more secure): keep `inventory` locked down and do inventory updates inside a `SECURITY DEFINER` trigger/function.

## Important Notes

- Ensure the Supabase tables and the `gambar-barang` storage bucket are created correctly.
- Fill in the Supabase credentials before running the app.
- Theme preferences are stored locally using Shared Preferences.

## License

This project is intended for learning and internal development.
