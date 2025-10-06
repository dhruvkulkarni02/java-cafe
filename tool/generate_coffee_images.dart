import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

class DrinkAsset {
  const DrinkAsset(this.fileName, this.label, this.base, this.accent);

  final String fileName;
  final String label;
  final List<int> base;
  final List<int> accent;
}

void main() {
  final drinks = <DrinkAsset>[
    const DrinkAsset(
      'cappuccino',
      'Cappuccino',
      [193, 150, 109],
      [247, 224, 200],
    ),
    const DrinkAsset('latte', 'Latte', [210, 184, 156], [252, 238, 215]),
    const DrinkAsset('espresso', 'Espresso', [73, 45, 33], [150, 98, 61]),
    const DrinkAsset(
      'iced_coffee',
      'Iced Coffee',
      [125, 88, 66],
      [212, 175, 144],
    ),
    const DrinkAsset(
      'flat_white',
      'Flat White',
      [214, 185, 156],
      [242, 231, 211],
    ),
    const DrinkAsset('mocha', 'Mocha', [114, 79, 64], [193, 140, 112]),
    const DrinkAsset('cold_brew', 'Cold Brew', [58, 40, 29], [112, 70, 43]),
    const DrinkAsset(
      'nitro_cold_brew',
      'Nitro Cold Brew',
      [46, 30, 24],
      [98, 58, 37],
    ),
    const DrinkAsset('americano', 'Americano', [88, 59, 45], [166, 116, 79]),
    const DrinkAsset(
      'caramel_macchiato',
      'Caramel Macchiato',
      [198, 142, 87],
      [255, 214, 157],
    ),
    const DrinkAsset(
      'pumpkin_spice_latte',
      'Pumpkin Spice Latte',
      [193, 121, 63],
      [246, 184, 120],
    ),
    const DrinkAsset(
      'matcha_latte',
      'Matcha Latte',
      [126, 157, 103],
      [192, 222, 166],
    ),
    const DrinkAsset('affogato', 'Affogato', [134, 93, 72], [230, 209, 186]),
    const DrinkAsset(
      'turkish_coffee',
      'Turkish Coffee',
      [97, 67, 50],
      [198, 149, 100],
    ),
    const DrinkAsset(
      'irish_coffee',
      'Irish Coffee',
      [101, 66, 53],
      [183, 126, 86],
    ),
    const DrinkAsset(
      'vienna_coffee',
      'Vienna Coffee',
      [141, 103, 88],
      [228, 196, 172],
    ),
    const DrinkAsset('cortado', 'Cortado', [157, 113, 85], [226, 189, 157]),
    const DrinkAsset('ristretto', 'Ristretto', [62, 38, 30], [125, 78, 54]),
    const DrinkAsset('doppio', 'Doppio', [84, 52, 37], [156, 99, 63]),
    const DrinkAsset(
      'piccolo_latte',
      'Piccolo Latte',
      [182, 140, 105],
      [236, 209, 176],
    ),
    const DrinkAsset('red_eye', 'Red Eye', [71, 41, 33], [143, 82, 57]),
    const DrinkAsset(
      'iced_matcha',
      'Iced Matcha',
      [129, 171, 118],
      [196, 229, 184],
    ),
    const DrinkAsset(
      'iced_mocha',
      'Iced Mocha',
      [122, 86, 66],
      [211, 158, 120],
    ),
    const DrinkAsset(
      'iced_caramel_latte',
      'Iced Caramel Latte',
      [184, 133, 94],
      [244, 197, 149],
    ),
    const DrinkAsset('frappe', 'Frappé', [152, 120, 96], [223, 197, 170]),
    const DrinkAsset(
      'iced_americano',
      'Iced Americano',
      [102, 72, 55],
      [173, 122, 88],
    ),
  ];

  final outputDir = Directory('assets/images');
  outputDir.createSync(recursive: true);

  for (final drink in drinks) {
    final image = img.Image(720, 900);
    final baseColor = _color(drink.base);
    final accentColor = _color(drink.accent);
    final cremaColor = _color(_lerp(drink.base, drink.accent, .35));
    final foamHighlight = _color(
      _lerp(drink.accent, const [255, 255, 255], .4),
    );

    img.fill(image, baseColor);

    const centerX = 360;
    const centerY = 360;
    img.drawCircle(image, centerX, centerY, 250, accentColor);
    img.drawCircle(image, centerX, centerY, 180, cremaColor);
    img.drawCircle(image, centerX - 70, centerY - 60, 70, foamHighlight);
    img.drawCircle(image, centerX + 55, centerY + 40, 55, accentColor);
    img.drawCircle(image, centerX + 55, centerY + 40, 38, cremaColor);

    final rimOuterColor = _color(_lerp(drink.base, const [40, 25, 18], .6));
    img.drawCircle(image, centerX, centerY, 255, rimOuterColor);
    img.drawCircle(image, centerX, centerY, 247, baseColor);

    final steamColor = img.getColor(255, 255, 255, 60);
    for (var i = 0; i < 3; i++) {
      final offset = i * 48;
      _drawSteam(image, centerX - 120 + offset, 160, steamColor);
    }

    final shadowColor = img.getColor(0, 0, 0, 120);
    img.fillRect(image, 0, 680, image.width, image.height, shadowColor);

    final textColor = img.getColor(255, 248, 240);
    final lines = _wrapLabel(drink.label.toUpperCase(), 16);
    final font = lines.length > 2 ? img.arial_24 : img.arial_48;
    var textY = 720;
    final lineHeight = font.lineHeight == 0 ? 48 : font.lineHeight;
    for (final line in lines) {
      img.drawString(image, font, 52, textY, line, color: textColor);
      textY += lineHeight + 8;
    }

    final file = File('assets/images/${drink.fileName}.png');
    file.writeAsBytesSync(img.encodePng(image));
  }
}

int _color(List<int> rgb, [int alpha = 255]) => img.getColor(
  rgb[0].clamp(0, 255),
  rgb[1].clamp(0, 255),
  rgb[2].clamp(0, 255),
  alpha,
);

List<int> _lerp(List<int> a, List<int> b, double t) => [
  (a[0] + (b[0] - a[0]) * t).round(),
  (a[1] + (b[1] - a[1]) * t).round(),
  (a[2] + (b[2] - a[2]) * t).round(),
];

List<String> _wrapLabel(String text, int maxLen) {
  final words = text.split(' ');
  final lines = <String>[];
  var current = '';
  for (final word in words) {
    final attempt = (current.isEmpty ? word : '$current $word');
    if (attempt.length > maxLen && current.isNotEmpty) {
      lines.add(current);
      current = word;
    } else {
      current = attempt;
    }
  }
  if (current.isNotEmpty) {
    lines.add(current);
  }
  return lines;
}

void _drawSteam(img.Image image, int startX, int startY, int color) {
  var x = startX;
  var y = startY;
  const steps = 80;
  for (var i = 0; i < steps; i++) {
    final t = i / steps;
    final dx = (math.sin(t * math.pi) * 12).toInt();
    final dy = (t * 80).toInt();
    _setPixelSafe(image, x + dx, y - dy, color);
    _setPixelSafe(image, x + dx + 1, y - dy, color);
  }
}

void _setPixelSafe(img.Image image, int x, int y, int color) {
  if (x < 0 || x >= image.width || y < 0 || y >= image.height) {
    return;
  }
  image.setPixel(x, y, color);
}
