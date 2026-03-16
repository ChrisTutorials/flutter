import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File(r'C:\dev\flutter\marketing\unit_converter\screenshots\raw_store_screenshots\phone_01_home_history_light_portrait_1080x1920.png');
  final image = img.decodePng(file.readAsBytesSync());
  
  if (image == null) {
    print('Failed to decode image');
    return;
  }
  
  print('Width: ' + image.width.toString());
  print('Height: ' + image.height.toString());
  
  // Find the last row with non-white pixels
  var lastNonWhiteRow = 0;
  for (var y = image.height - 1; y >= 0; y--) {
    var hasNonWhitePixel = false;
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      if (pixel.r < 250 || pixel.g < 250 || pixel.b < 250) {
        hasNonWhitePixel = true;
        break;
      }
    }
    if (hasNonWhitePixel) {
      lastNonWhiteRow = y;
      break;
    }
  }
  
  print('Last non-white row: ' + lastNonWhiteRow.toString());
  print('Whitespace at bottom: ' + (image.height - lastNonWhiteRow - 1).toString() + ' pixels');
  print('Whitespace percentage: ' + ((image.height - lastNonWhiteRow - 1) / image.height * 100).toStringAsFixed(2) + '%');
}
