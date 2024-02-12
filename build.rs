const COMMANDS: &[&str] = &[
    "available_ports",
    "cancel_read",
    "close",
    "close_all",
    "force_close",
    "open",
    "read",
    "write",
    "write_binary",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}
