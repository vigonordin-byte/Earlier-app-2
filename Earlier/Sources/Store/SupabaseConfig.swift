import Foundation

/// Supabase project connection.
///
/// The `anonKey` is the **public** anon key — it is designed to ship inside the
/// client and is protected by Row-Level Security policies on the server. The
/// secret `service_role` key must never appear in the app.
///
/// Used by the (upcoming) Supabase auth + cloud-backup layer. The app is
/// local-first: SwiftData is the source of truth so alarms work fully offline,
/// and Supabase only mirrors data for accounts / backup.
enum SupabaseConfig {
    static let url = "https://nxuszaexpzzpkfxokdvx.supabase.co"
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54dXN6YWV4cHp6cGtmeG9rZHZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYzNzc1NjcsImV4cCI6MjEwMTk1MzU2N30.qW1kXlhnQ5SLN25SPYeJACnvUZOgB991WAM8YiZCt-M"
}
