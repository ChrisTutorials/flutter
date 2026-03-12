import 'package:intl/intl.dart';

void main() {
  print('Testing intl scientificPattern:');
  print('1000: ${NumberFormat.scientificPattern().format(1000)}');
  print('0.001: ${NumberFormat.scientificPattern().format(0.001)}');
  print('12345: ${NumberFormat.scientificPattern().format(12345)}');
  print('1: ${NumberFormat.scientificPattern().format(1)}');
  print('10: ${NumberFormat.scientificPattern().format(10)}');
  print('100: ${NumberFormat.scientificPattern().format(100)}');
}