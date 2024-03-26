import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

final String _defaultProfilePic =
    "https://the-good-text-ef33a.web.app/assets/photos/G.png";

class ProfilePic extends StatelessWidget {
  ProfilePic({
    this.url,
    required this.size,
    this.margin = const EdgeInsets.all(16),
  });

  final double size;
  final String? url;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(size * 0.6),
      ),
      child: InkWell(
        onTap: () {},
        child: CachedNetworkImage(
          width: size,
          height: size,
          fit: BoxFit.cover,
          imageUrl: url ?? _defaultProfilePic,
          placeholder: (context, url) => SizedBox(
            width: size,
            height: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
