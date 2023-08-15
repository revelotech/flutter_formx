import 'package:equatable/equatable.dart';

/// The state of the form.
abstract class FormXCubitState extends Equatable {
  @override
  List<Object> get props => [];
}

/// Emitted in the initial form state, before it was built.
class FormXInitial extends FormXCubitState {}

/// Emitted when the form is ready.
class FormXBuilt<T> extends FormXCubitState {}

/// Emitted when the form is updating.
class FormXUpdating extends FormXCubitState {}

/// Emitted when the form is validating.
class FormXValidating extends FormXCubitState {}
