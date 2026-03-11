/// A simple counter model that manages counter state
class Counter {
  int _value = 0;

  /// Gets the current counter value
  int get value => _value;

  /// Increments the counter by 1
  void increment() {
    _value++;
  }

  /// Decrements the counter by 1
  void decrement() {
    if (_value > 0) {
      _value--;
    }
  }

  /// Resets the counter to 0
  void reset() {
    _value = 0;
  }

  /// Sets the counter to a specific value
  void setValue(int newValue) {
    if (newValue >= 0) {
      _value = newValue;
    }
  }

  /// Adds a specific amount to the counter
  void add(int amount) {
    if (amount > 0) {
      _value += amount;
    }
  }
}
