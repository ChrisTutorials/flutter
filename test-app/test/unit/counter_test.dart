import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/models/counter.dart';

void main() {
  group('Counter Model Tests', () {
    late Counter counter;

    setUp(() {
      counter = Counter();
    });

    test('Initial value should be 0', () {
      expect(counter.value, 0);
    });

    test('Increment should increase value by 1', () {
      counter.increment();
      expect(counter.value, 1);
    });

    test('Multiple increments should work correctly', () {
      counter.increment();
      counter.increment();
      counter.increment();
      expect(counter.value, 3);
    });

    test('Decrement should decrease value by 1 when value > 0', () {
      counter.increment();
      counter.increment();
      counter.decrement();
      expect(counter.value, 1);
    });

    test('Decrement should not go below 0', () {
      counter.decrement();
      expect(counter.value, 0);
    });

    test('Reset should set value to 0', () {
      counter.increment();
      counter.increment();
      counter.increment();
      counter.reset();
      expect(counter.value, 0);
    });

    test('Reset should work when value is already 0', () {
      counter.reset();
      expect(counter.value, 0);
    });

    test('SetValue should set value to positive number', () {
      counter.setValue(10);
      expect(counter.value, 10);
    });

    test('SetValue should set value to 0', () {
      counter.increment();
      counter.setValue(0);
      expect(counter.value, 0);
    });

    test('SetValue should not accept negative values', () {
      counter.setValue(5);
      counter.setValue(-1);
      expect(counter.value, 5);
    });

    test('Add should add positive amount to value', () {
      counter.add(5);
      expect(counter.value, 5);
    });

    test('Add should work multiple times', () {
      counter.add(3);
      counter.add(2);
      expect(counter.value, 5);
    });

    test('Add should not accept negative amounts', () {
      counter.add(5);
      counter.add(-2);
      expect(counter.value, 5);
    });

    test('Add should not accept zero', () {
      counter.add(0);
      expect(counter.value, 0);
    });

    test('Increment and decrement combination', () {
      counter.increment();
      counter.increment();
      counter.increment();
      counter.decrement();
      counter.increment();
      expect(counter.value, 3);
    });

    test('Complex operation sequence', () {
      counter.setValue(10);
      counter.add(5);
      counter.decrement();
      counter.decrement();
      counter.increment();
      // 10 + 5 = 15, -1 = 14, -1 = 13, +1 = 14
      expect(counter.value, 14);
    });

    test('Multiple resets', () {
      counter.increment();
      counter.reset();
      counter.increment();
      counter.increment();
      counter.reset();
      expect(counter.value, 0);
    });
  });

  group('Counter Edge Cases', () {
    test('Large increment count', () {
      final counter = Counter();
      for (int i = 0; i < 1000; i++) {
        counter.increment();
      }
      expect(counter.value, 1000);
    });

    test('Large value setting', () {
      final counter = Counter();
      counter.setValue(1000000);
      expect(counter.value, 1000000);
    });

    test('Alternating increment and decrement', () {
      final counter = Counter();
      for (int i = 0; i < 100; i++) {
        counter.increment();
        counter.decrement();
      }
      expect(counter.value, 0);
    });
  });
}
