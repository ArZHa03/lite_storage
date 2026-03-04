# LiteStorage

A super-duper-mega-ultra-extra fast, light and synchronous key-value storage for Flutter (Mobile, Desktop, and Web).

## Features

- 🚀 **Fast**: Synchronous read and write operations.
- 🪶 **Lightweight**: Minimal dependencies and small footprint.
- 🌐 **Web Support**: Fully compatible with Flutter Web using `package:web`.
- 💻 **Multiplatform**: Works on Android, iOS, macOS, Windows, Linux, and Web.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  lite_storage: ^1.1.0
```


## Usage

First, initialize the storage:

```dart
await LiteStorage.init(); // init first
```

#### Example CRUD Operations

```dart
// Write a value
LiteStorage.write('token', '!@#$%^&*'); // over/write key token on storage

// Read a value
String? token = LiteStorage.read<String>('token'); // read storage with key token : "!@#$%^&*"

// Remove a value
LiteStorage.remove('token'); // delete key token on storage

// Clear all values
LiteStorage.erase(); // delete all data storage
```

### API

#### Methods

- `Future<void> init([String container = 'LiteStorage'])`: Initialize the storage.
- `T? read<T>(String key)`: Read a value from the storage.
- `void write(String key, dynamic value)`: Write a value to the storage.
- `void remove(String key)`: Remove a value from the storage.
- `void erase()`: Clear all values from the storage.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
