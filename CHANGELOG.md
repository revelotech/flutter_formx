## Changelog

## v3.0.1
- Fix state management content in README

## v3.0.0
- [Breaking change] Add vanilla implementation - This change affects MobX implementations since we 
  have changed FormX<T> to be the vanilla implementation and applied the MobX implementation logic 
  in a new mixin FormXMobX<T>. Previous implementations of this should replace the FormX<T> usage 
  with FormXMobX<T> to have the same behavior as in previous versions
- Add Bloc implementation
- Restructure the library's folders
- Add option to apply validation on form setup. The default behavior is that the form is validated
  on the setup, so it doesn't break on previous versions. This does not apply to vanilla 
  implementations

## v2.1.0
- Fix strings with only blank spaces being validated by required field validator

## v2.0.1
- Fix image paths in README

## v2.0.0
- [Breaking change] Rename FormItem to FormXField
- [Breaking change] Expose the library file only
- Improve documentation
- Fix example project setup
- Add optional soft validation when updating and validating an item

## v1.0.0
- Initial release
