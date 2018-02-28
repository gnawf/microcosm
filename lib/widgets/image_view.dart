import "package:flutter/material.dart";
import "package:meta/meta.dart";

ImageProvider networkImageOrPlaceholder(String url) {
  if (url == null) {
    return const AssetImage("assets/images/1x1.png");
  }
  return new NetworkImage(url);
}

class ImageView extends StatelessWidget {
  const ImageView({
    @required this.image,
    this.imageScale = 1.0,
    this.fadeOutDuration: const Duration(milliseconds: 300),
    this.fadeOutCurve: Curves.easeOut,
    this.fadeInDuration: const Duration(milliseconds: 300),
    this.fadeInCurve: Curves.easeIn,
    this.fit,
    this.width,
    this.height,
  });

  final String image;

  final double imageScale;

  final Duration fadeOutDuration;

  final Curve fadeOutCurve;

  final Duration fadeInDuration;

  final Curve fadeInCurve;

  final double width;

  final double height;

  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    // Return an empty view if we don't have an image to display
    if (image == null) {
      return new Container(width: width, height: height);
    }

    return new FadeInImage.assetNetwork(
      placeholder: "assets/images/1x1.png",
      placeholderScale: 1.0,
      image: image,
      imageScale: imageScale,
      fadeOutDuration: fadeOutDuration,
      fadeOutCurve: fadeOutCurve,
      fadeInDuration: fadeInDuration,
      fadeInCurve: fadeInCurve,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
