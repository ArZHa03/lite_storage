## Usage
A super-duper-mega-ultra-extra fast, light and synchronous key-value storage written.

```dart
await LiteStorage.init(); // init first

// example CRUD
LiteStorage().write('token', '!@#$%^&*'); // over/write key token on storage
LiteStorage().read('token'); // read storage with key token : "!@#$%^&*"
LiteStorage().remove('token'); // delete key token on storage
LiteStorage().clear(); // delete all data storage
```
