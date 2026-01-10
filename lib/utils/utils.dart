import 'package:interact/interact.dart';

final radioTheme = Theme.colorfulTheme.copyWith(
  activeItemPrefix: '❯ ◉', // Filled radio
  inactiveItemPrefix: '  ○', // Empty radio
  inputPrefix: '',
  successPrefix: '',
);

// Checkbox style for multi-select
final checkboxTheme = Theme.colorfulTheme.copyWith(
  checkedItemPrefix: '[✓]',
  uncheckedItemPrefix: '[ ]',
  inputPrefix: '',
  successPrefix: '',
);

// input theme
final inputTheme = Theme.colorfulTheme.copyWith(
  inputPrefix: '',
  successPrefix: '',
);

List<T> multiSelect<T>(String message, {required List<T> options, required String Function(T) display}) {
  final selection = MultiSelect.withTheme(
    prompt: message,
    options: List.of(options.map(display)),
    theme: checkboxTheme,
  ).interact();
  return List.of(selection.map((index) => options[index]));
}

T singleSelect<T>(String message, {required List<T> options, required String Function(T) display}) {
  final index = Select.withTheme(
    prompt: message,
    options: List.of(options.map(display)),
    theme: radioTheme,
  ).interact();
  return options[index];
}

String prompt(String message, {String? defaultValue, String? validatorErrorMessage}) {
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
