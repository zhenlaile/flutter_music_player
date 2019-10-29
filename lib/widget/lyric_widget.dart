import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/Lyric.dart';
import 'package:flutter_music_player/utils/screen_util.dart';

class LyricPage extends StatefulWidget {
  final Lyric lyric;
  LyricPage({Key key, this.lyric}) : super(key: key);
  _LyricPageState _state;

  @override
  _LyricPageState createState() {
    _state = _LyricPageState();
    return _state;
  }

  void updatePosition(int position) {
    _state?.updatePosition(position);
  }

  void updateLyric(Lyric result) {
    //_state?.updateLyric(result);
  }
}

class _LyricPageState extends State<LyricPage> {
  final double itemHeight = 30.0;
  int visibleItemSize = 7;

  ScrollController _controller;
  int _currentIndex = 0;
  bool isTaping = false;

  @override
  void initState() {
    super.initState();
    print('LyricPage initState');

    _controller = ScrollController();
    _controller.addListener(() {
      //print('ScrollController');

    visibleItemSize = ScreenUtil.screenHeight <700 ? 5 : 7;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lyric == null) {
      return Text('...无歌词...',
          style: TextStyle(color: Colors.white30, fontSize: 13.0));
    }

    //_style.color =
    return Container(
      alignment: Alignment.center,
      child:ConstrainedBox(
        constraints: BoxConstraints(maxHeight: itemHeight * 7),
        child: CustomScrollView(controller: _controller, slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return _getItem(widget.lyric.items[index]);
              },
              childCount: widget.lyric.items.length,
            )
            /* delegate: SliverChildListDelegate(
                widget.lyric.items.map((item) => _getItem(item)).toList()), */
          ),
        ]),
    ));
  }

  Widget _getItem(LyricItem item) {
    return Container(
        alignment: Alignment.center,
        height: itemHeight,
        child: Text(
          item.content,
          style: TextStyle(
              fontSize: 13.0,
              color: (item.index == _currentIndex)
                  ? Colors.white
                  : Colors.white60),
        ));
  }

  int getIndexOfPosition(int position) {
    int index = 0;
    for (LyricItem item in widget.lyric.items) {
      if (position * 1000 <= item.position) {
        index = index - 1;
        if (index < 0) {
          index = 0;
        }
        break;
      }
      index++;
    }
    return index;
  }

  void scrollTo(int index) {
    int itemSize = widget.lyric.items.length;
    // 选中的Index是否超出边界
    if (index < 0 || index >= itemSize) {
      return;
    }

    int offset = (visibleItemSize - 1) ~/ 2;
    int topIndex = index - offset; // 选中元素居中时,top的Index
    int bottomIndex = index + offset;

    setState(() {
      _currentIndex = index;
    });

    if (isTaping) {
      // 如果手指按着就不滚动
      return;
    }

    // 是否需要滚动(top和bottom到边界时不滚动了)
    if (topIndex < 0 && _controller.offset <= 0) {
      return;
    }
    if (bottomIndex >= itemSize &&
        _controller.offset >= (itemSize - visibleItemSize) * itemHeight) {
      return;
    }

    _controller.animateTo(topIndex * itemHeight,
        duration: Duration(seconds: 1), curve: Curves.easeInOut);
  }

  // 根据歌曲播放的位置确定滚动的位置
  void updatePosition(int position) {
    int _index = getIndexOfPosition(position);
    if (_index != _currentIndex) {
      /* setState(() {
        _currentIndex = _index;
      }); */
      _currentIndex = _index;
      scrollTo(_currentIndex);
    }
  }

/*   void updateLyric(Lyric lyric) {
    setState(() {
      widget.lyric = lyric;
    });
  } */
}