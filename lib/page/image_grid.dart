import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yk/model/image.dart' as i;
import 'package:yk/page/detail.dart';

// ignore: must_be_immutable
class ImageGrid extends StatelessWidget {
  i.Image image;
  AddTag addTag;
  ImageGrid(i.Image image, AddTag addTag, {Key key}) {
    this.image = image;
    this.addTag = addTag;
  }

  @override
  Widget build(BuildContext context) {
    final width = window.physicalSize.width;
    return Container(
      height: width / image.width * image.height / 5.4,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: InkWell(
          child: Image.network(
            image.previewUrl,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes
                      : null,
                ),
              );
            },
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Detail(image: this.image,addTag: addTag,);
            }));
          },
        ),
      ),
    );
  }
}
