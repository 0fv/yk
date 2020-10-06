import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:yk/model/image.dart' as i;

typedef void AddTag(String tag);

// ignore: must_be_immutable
class Detail extends StatelessWidget {
  AddTag addTag;
  i.Image image;
  Detail({Key key, this.addTag, this.image}) {
    this.addTag = addTag;
    this.image = image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(),
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              child: PhotoView(
                imageProvider: NetworkImage(this.image.jpegUrl),
              ),
            ),
            Positioned(
                bottom: 1.0,
                child: Container(
                    height: 30,
                    width: 400,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 2.0),
                        child: Container(
                          height: 25,
                          child: Container(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: this
                                  .image
                                  .tags
                                  .split(" ")
                                  .map(
                                    (e) => Container(
                                        margin:
                                            EdgeInsets.fromLTRB(10, 0, 0, 4),
                                        child: RaisedButton(
                                          color: Colors.blue[240],
                                          highlightColor: Colors.yellow,
                                          splashColor: Colors.yellow,
                                          colorBrightness: Brightness.light,
                                          onPressed: () {
                                            this.addTag(e);
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            e,
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w300),
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                        )),
                                  )
                                  .toList(),
                            ),
                          ),
                        )))),
          ],
        ));
  }
}
