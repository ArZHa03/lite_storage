# Changelog

## 1.1.1 (08/03/2026)
### Changed:
- Migrated Web implementation from `dart:html` to `package:web` and `dart:js_interop` to support WebAssembly (Wasm) compilation.

## 1.1.0 (04/03/2026)
### Added:
- Full support for Flutter Web using `package:web`.
- Internal architectural improvements for platform-specific storage.
### Fixed:
- Naming collision for `log` with `dart:developer`.
- Corrected `log` argument order.
### Changed:
- Updated dependencies (`path_provider`, `web`, `flutter_lints`).
- Restructured internal storage implementation.

## 1.0.0 (15/05/2025)
### Added:
- Initial release of the project. 
- Added basic functionality for the project.
- Added algorithms for multiplatform Mobile and Desktop.