ArrayList<Point> pointList = new ArrayList<Point>();

void setup() {
  size(640, 480);
  frameRate(60);
}

void draw() {
  background(255);
  for (var point : pointList) {
    point.draw();
  }
}

// マウスがクリックされた時に呼び出されるハンドラ
void mouseClicked(MouseEvent e) {
  switch (e.getButton()) {
  case LEFT:  // 左クリック
    pointList.add(new Point(mouseX, mouseY));
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
