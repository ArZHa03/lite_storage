# LiteStorage

A simple, secure, fast, light and synchronous key-value storage written.

## Installation

Add this to your package's `pubspec.yaml` file and then run `pub get`:

```yaml
dependencies:
  lite_storage: 
    git: https://github.com/ArZHa03/lite_storage.git
```

## Usage

First, initialize the storage:

```dart
await LiteStorage.init(); // init first
```

### Secure Storage

You can also initialize the storage with a password for encryption:

```dart
await LiteStorage.init(password: 'your-secure-password'); // init with password
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

- `Future<void> init([String container = 'LiteStorage', String? password])`: Initialize the storage.
- `T? read<T>(String key)`: Read a value from the storage.
- `void write(String key, dynamic value)`: Write a value to the storage.
- `void remove(String key)`: Remove a value from the storage.
- `void erase()`: Clear all values from the storage.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.