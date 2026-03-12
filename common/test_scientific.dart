import 'package:intl/intl.dart';

void main() {
  final result = NumberFormat.scientificPattern().format(1000);
  print('Result: $result');
  
  final result2 = NumberFormat.scientificPattern().format(0.001);
  print('Result 2: $result2');
  
  final result3 = NumberFormat.scientificPattern().format(12345);
  print('Result 3: $result3');
}