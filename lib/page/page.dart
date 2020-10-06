import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:yk/api/api.dart';
import 'package:yk/api/base_url.dart';
import 'package:yk/model/image.dart' as i;
import 'package:yk/page/image_grid.dart';

class Posts extends StatefulWidget {
  Posts({Key key}) : super(key: key);
  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  String title = "yande";
  Site site = Site.yande;
  List<i.Image> imageList;
  int page = 1;
  Set<String> tags = {};
  Future<List<i.Image>> fl;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;
  TextEditingController tec;
  ScrollController _scrollController;
  bool last = false;
  bool searchStatus = false;
  Widget titleWidget;

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    this.titleWidget = Text(this.title);
    _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
    tec = new TextEditingController();
    // 进入页面立即显示刷新动画
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });

    this._getList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _nextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _getList() {
    print("request");
    this.fl = api
        .getPost(this.site, page: this.page, tags: this.tags)
        .then((value) => this.imageList = value);
  }

  Future<void> _refresh() {
    _clearList();
    return api
        .getPost(this.site, page: this.page, tags: this.tags)
        .then((value) => this.imageList = value);
  }

  _clearList() {
    this.imageList = [];
    this.page = 1;
    this.last = false;
  }

  _addTag(String tag) {
    setState(() {
      this.searchStatus = false;
      _clearList();
      if (this.tags.add(tag)) {
        _getList();
      }
    });
  }

  _removeTag(String tag) {
    setState(() {
      if (this.tags.remove(tag)) {
        _clearList();
        _getList();
      }
    });
  }

  _siteChange() {
    setState(() {
      if (this.site == Site.yande) {
        this.site = Site.konachan;
        this.title = "konachan";
        _clearList();
        _setTitle();
        _getList();
      } else {
        this.site = Site.yande;
        this.title = "yande";
        _clearList();
        _setTitle();
        _getList();
      }
    });
  }

  Future<dynamic> _nextPage() {
    if (this.last) {
      return Future.value("last");
    }
    var n = page+1;
    return api.getPost(this.site, page: n, tags: this.tags).then((value) {
      setState(() {
        this.page = n;
        if (value.length != 40) {
          this.last = true;
        }
        this.imageList.addAll(value);
      });
    });
  }

  _setTitle() {
    setState(() {
      if (this.searchStatus) {
        this.titleWidget = TextField(
            controller: this.tec,
            textInputAction: TextInputAction.search,
            onEditingComplete: () {
              var _tag = tec.text;
              _addTag(_tag);
              tec.text = "";
            },
            decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: 'add tag',
                hintStyle: TextStyle(color: Colors.white)));
      } else {
        this.titleWidget = Text(this.title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          height: 100,
        ),
        title: titleWidget,
        actions: [
          IconButton(icon: Icon(Icons.track_changes), onPressed: _siteChange),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                this.searchStatus = !this.searchStatus;
                _setTitle();
              });
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size(0.0, 22.0),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 4.0),
              child: Container(
                height: 25,
                child: Container(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: tags
                        .map(
                          (e) => Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: RaisedButton(
                                color: Colors.blue[240],
                                highlightColor: Colors.yellow,
                                splashColor: Colors.yellow,
                                colorBrightness: Brightness.light,
                                onPressed: () {
                                  _removeTag(e);
                                },
                                child: Text(
                                  e,
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                              )),
                        )
                        .toList(),
                  ),
                ),
              )),
        ),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder(
            future: this.fl,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return StaggeredGridView.countBuilder(
                  staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                  crossAxisCount: 4,
                  controller: this._scrollController,
                  itemCount: this.imageList == null ? 0 : this.imageList.length,
                  itemBuilder: (context, index) {
                    if (index == this.imageList.length - 1 &&
                        this.imageList.length > 40) {
                      return _loadMoreWidget();
                    } else {
                      var _data = this.imageList[index];
                      return Container(
                          padding: EdgeInsets.all(2),
                          // leading: Image.network(_data.previewUrl),
                          child: ImageGrid(_data,_addTag));
                    }
                  },
                );
              } else if (snapshot.hasError) {
                return Text("error" + snapshot.error);
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          this._scrollController.animateTo(0,
              duration: Duration(milliseconds: 600), curve: Curves.ease);
        },
        child: Icon(Icons.arrow_drop_up),
      ),
    );
  }

  Widget _loadMoreWidget() {
    return this.last
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(15.0), // 外边距
            child: new Center(child: new CircularProgressIndicator()),
          );
  }
}
