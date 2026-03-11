import '../models/conversion.dart';

class ComparisonService {
  static String? describe({
    required String categoryName,
    required Unit? fromUnit,
    required Unit? toUnit,
  }) {
    if (fromUnit == null || toUnit == null) {
      return null;
    }

    if (categoryName == 'Length') {
      switch (fromUnit.symbol) {
        case 'in':
          return '1 inch is about the width of an adult thumb.';
        case 'ft':
          return '1 foot is roughly the length of a standard ruler.';
        case 'm':
          return '1 meter is a little taller than a kitchen counter.';
        case 'km':
          return '1 kilometer is about a 10-minute walk.';
      }
    }

    if (categoryName == 'Weight') {
      switch (fromUnit.symbol) {
        case 'lb':
          return '1 pound is close to a loaf of sandwich bread.';
        case 'kg':
          return '1 kilogram is about the mass of a liter of water.';
      }
    }

    if (categoryName == 'Volume') {
      switch (fromUnit.symbol) {
        case 'L':
          return '1 liter is about a standard reusable water bottle.';
        case 'gal':
          return '1 US gallon is roughly 3.8 one-liter bottles.';
        case 'cup':
          return '1 US cup is close to a typical coffee mug serving.';
      }
    }

    if (categoryName == 'Temperature') {
      switch (fromUnit.symbol) {
        case '°F':
          return '32°F is the freezing point of water and 212°F is boiling.';
        case '°C':
          return '0°C is freezing and 100°C is boiling at sea level.';
      }
    }

    if (categoryName == 'Area') {
      switch (fromUnit.symbol) {
        case 'ac':
          return '1 acre is a little smaller than a football field.';
        case 'm²':
          return '1 square meter is about the area of a small desk.';
      }
    }

    if (categoryName == 'Data') {
      switch (fromUnit.symbol) {
        case 'MB':
          return '1 megabyte is roughly a high-quality photo from a phone camera.';
        case 'GB':
          return '1 gigabyte can cover hours of music or a standard-definition movie.';
      }
    }

    if (categoryName == 'Pressure') {
      switch (fromUnit.symbol) {
        case 'psi':
          return '32 psi is a common target for car tire pressure.';
        case 'bar':
          return '1 bar is close to the air pressure you feel at sea level.';
      }
    }

    if (categoryName == 'Cooking') {
      switch (fromUnit.symbol) {
        case 'tbsp':
          return '1 tablespoon is about the bowl of a large soup spoon.';
        case 'cup':
          return '1 cup is about the volume of a small breakfast mug.';
      }
    }

    return null;
  }
}
