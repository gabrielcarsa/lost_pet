import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget cachedNetworkImage(mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => Container(
      padding: EdgeInsets.all(20.0),
      width: MediaQuery.of(context).size.width * 0.100,
      child: CircularProgressIndicator(),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}
