ArrayList<Point> pointList = new ArrayList<Point>();
ArrayList<Line> lineList = new ArrayList<Line>();

Point previousPoint = null;

void setup() {
  size(640, 480);
  frameRate(60);
}

void draw() {
  background(255);
  for (var point : pointList) {
    point.draw();
  }
  for (var line : lineList) {
    line.draw();
  }
}

// マウスがクリックされた時に呼び出されるハンドラ
void mouseClicked(MouseEvent e) {
  switch (e.getButton()) {
  case LEFT: // 左クリック
    Point newPoint = new Point(mouseX, mouseY);
    pointList.add(newPoint);
    if (previousPoint != null) {
      Line newLine = new Line(previousPoint, newPoint);
      lineList.add(newLine);
    }
    previousPoint = newPoint;
    break;
  case CENTER:  // ホイールクリック
    break;
  case RIGHT:  // 右クリック
    break;
  default:
    break;
  }
  // DEBUG:
  print("(mouseX, mouseY) = (" + mouseX + ", " + mouseY + ")\n");
}

// グラフの点
class Point {
  int x;
  int y;
  color _color;

  // TODO: 後で色を変えられるようにする
  Point(int x, int y) {
    this.x = x;
    this.y = y;
    this._color = color(255, 100, 100);
  }

  void draw() {
    fill(_color);
    ellipse(x, y, 20, 20);
  }
}

// グラフ線分
class Line {
  // 二点への参照で表現する
  Point begin;
  Point end;

  Line(Point begin, Point end) {
    this.begin = begin;
    this.end = end;
  }

  void draw() {
    // TODO: 終点に矢印を描く
    line(begin.x, begin.y, end.x, end.y);
  }
}
