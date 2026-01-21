import 'package:interact/interact.dart';
import 'package:permit/utils/logger.dart';

/// Theme for radio buttons.
final radioTheme = Theme.colorfulTheme.copyWith(
  activeItemPrefix: '❯ ◉', // Filled radio
  inactiveItemPrefix: '  ○', // Empty radio
  inputPrefix: '',
  successPrefix: '',
);

/// Theme for checkboxes.
final checkboxTheme = Theme.colorfulTheme.copyWith(
  checkedItemPrefix: '[✓]',
  uncheckedItemPrefix: '[ ]',
  inputPrefix: '',
  successPrefix: '',
);

/// Theme for text inputs.
final inputTheme = Theme.colorfulTheme.copyWith(
  inputPrefix: '',
  successPrefix: '',
);

/// Prompts the user to select multiple options from a list.
List<T> multiSelect<T>(
  String message, {
  required List<T> options,
  required String Function(T) display,
}) {
  final selection = MultiSelect.withTheme(
    prompt:
        '$message ${Logger.mutedPen.write('(↑↓ navigate, space to select)')}',
    options: List.of(options.map(display)),
    theme: checkboxTheme,
  ).interact();
  return List.of(selection.map((index) => options[index]));
}

/// Prompts the user to select a single option from a list.
T singleSelect<T>(
  String message, {
  required List<T> options,
  required String Function(T) display,
}) {
  final index = Select.withTheme(
    prompt: message,
    options: List.of(options.map(display)),
    theme: radioTheme,
  ).interact();
  return options[index];
}

/// Prompts the user for text input.
String prompt(
  String message, {
  String? defaultValue,
  String? validatorErrorMessage,
}) {
  return Input.withTheme(
    theme: inputTheme,
    prompt: message,
    validator: (input) {
      if (input.isEmpty) {
        throw ValidationError(validatorErrorMessage ?? 'Input cannot be empty');
      }
      return true;
    },
    defaultValue: defaultValue,
  ).interact();
}
