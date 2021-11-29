import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DefaultNetworkImage extends StatelessWidget {
  const DefaultNetworkImage(this.url,
      {Key? key,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
      this.errorWidget})
      : super(key: key);

  final String url;

  final double? width;

  final double? height;

  final BoxFit fit;

  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return url.endsWith('.svg') || url.contains('.svg?')
        ? SvgPicture.network(
            url,
            width: width,
            height: height,
            fit: fit,
            placeholderBuilder: (BuildContext context) =>
                const CupertinoActivityIndicator(),
          )
        : CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            fit: fit,
            errorWidget: (context, url, error) =>
                errorWidget ??
                Image.asset(
                  'assets/images/ic_img_error.png',
                  width: 50,
                  height: 50,
                ),
            placeholder: (context, url) => const CupertinoActivityIndicator());
  }
}
