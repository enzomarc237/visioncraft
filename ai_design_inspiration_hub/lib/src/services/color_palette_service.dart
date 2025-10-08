import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ColorPaletteService {
  List<String> extractDominantColors(Uint8List bytes, {int k = 5}) {
    final img.Image? image = img.decodeImage(bytes);
    if (image == null) return const [];

    // Simple quantization by sampling pixels uniformly.
    final List<List<double>> colors = <List<double>>[];
    final int stepX = (image.width / 50).clamp(1, image.width).toInt();
    final int stepY = (image.height / 50).clamp(1, image.height).toInt();
    for (int y = 0; y < image.height; y += stepY) {
      for (int x = 0; x < image.width; x += stepX) {
        final img.Pixel p = image.getPixel(x, y);
        final double r = p.getChannel(img.Channel.red).toDouble();
        final double g = p.getChannel(img.Channel.green).toDouble();
        final double b = p.getChannel(img.Channel.blue).toDouble();
        colors.add(<double>[r, g, b]);
      }
    }

    final int n = colors.length;
    if (n == 0) return const [];
    final int clusters = k.clamp(1, n);
    final List<List<double>> centroids = <List<double>>[];
    for (int i = 0; i < clusters; i++) {
      centroids.add(List<double>.from(colors[i]));
    }

    final List<List<List<double>>> groups =
        List.generate(clusters, (_) => <List<double>>[]);
    for (final List<double> rgb in colors) {
      int best = 0;
      double bestDist = double.infinity;
      for (int i = 0; i < clusters; i++) {
        final double d = _dist2(rgb, centroids[i]);
        if (d < bestDist) {
          bestDist = d;
          best = i;
        }
      }
      groups[best].add(rgb);
    }

    final List<String> hexes = <String>[];
    for (final List<List<double>> g in groups) {
      if (g.isEmpty) continue;
      double r = 0, gg = 0, b = 0;
      for (final List<double> rgb in g) {
        r += rgb[0];
        gg += rgb[1];
        b += rgb[2];
      }
      r /= g.length;
      gg /= g.length;
      b /= g.length;
      hexes.add(_toHex(r.toInt(), gg.toInt(), b.toInt()));
    }
    return hexes;
  }

  double _dist2(List<double> a, List<double> b) {
    final double dr = a[0] - b[0];
    final double dg = a[1] - b[1];
    final double db = a[2] - b[2];
    return dr * dr + dg * dg + db * db;
  }

  String _toHex(int r, int g, int b) {
    int clamp(int v) => v.clamp(0, 255);
    String two(int v) => clamp(v).toRadixString(16).padLeft(2, '0');
    return '#${two(r)}${two(g)}${two(b)}'.toUpperCase();
  }
}

