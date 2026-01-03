import 'package:interact/interact.dart';

List<T> multiSelect<T>(String message, {required List<T> options, required String Function(T) display}) {
  final selection = MultiSelect(
    prompt: message,
    options: List.of(options.map(display)),
  ).interact();
  return List.of(selection.map((index) => options[index]));
}

T singleSelect<T>(String message, {required List<T> options, required String Function(T) display}) {
  final index = Select(
    prompt: message,
    options: List.of(options.map(display)),
  ).interact();
  return options[index];
}

String prompt(String message, {String? defaultValue}) {
  return Input(
    prompt: message,
    defaultValue: defaultValue,
  ).interact();
}
