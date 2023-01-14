import java.util.LinkedList;

LinkedList<Point> pointList = new LinkedList<Point>();
LinkedList<Line> lineList = new LinkedList<Line>();

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
    if (pointList.size() >= 1) {
      Line newLine = new Line(pointList.getLast(), newPoint);
      lineList.add(newLine);
    }
    pointList.add(newPoint);
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
    noStroke();
    ellipse(x, y, 10, 10);
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

  // 二点間の角度 (rad)
  private double getRadian() {
    double radian = Math.atan2(end.y - begin.y, end.x - begin.x);
    return radian;
  }

  void draw() {
    // TODO: 要メソッド化
    
    // 終点に矢印を描画
    double lineRadian = getRadian();
    // 矢印の右端 (+30°)
    double arrowRightRadian = lineRadian + ((180 + 30) * Math.PI / 180);
    // 矢印の左端 (-30°)
    double arrowLeftRadian = lineRadian + ((180 - 30) * Math.PI / 180);

    // 矢印の先端を点にめり込まないようにする
    double arrowReverseRadian = lineRadian + (180 * Math.PI / 180);
    Point arrowEdgePoint = new Point(
      end.x + (int)(Math.cos(arrowReverseRadian) * 10),
      end.y + (int)(Math.sin(arrowReverseRadian) * 10)
    );

    // 矢印の先端が太く見えてしまうのを避けるために線分は少し短く描画する
    {
      stroke(color(255, 100, 100));
      strokeWeight(5);
      Point endForDraw = new Point(
        end.x + (int)(Math.cos(arrowReverseRadian) * 10),
        end.y + (int)(Math.sin(arrowReverseRadian) * 10)
      );
      line(begin.x, begin.y, endForDraw.x, endForDraw.y);
    }

    final int ARROW_SIZE = 10;

    Point arrowRightPoint = new Point(
      arrowEdgePoint.x + (int)(Math.cos(arrowRightRadian) * ARROW_SIZE),
      arrowEdgePoint.y + (int)(Math.sin(arrowRightRadian) * ARROW_SIZE)
    );

    Point arrowLeftPoint = new Point(
      arrowEdgePoint.x + (int)(Math.cos(arrowLeftRadian) * ARROW_SIZE),
      arrowEdgePoint.y + (int)(Math.sin(arrowLeftRadian) * ARROW_SIZE)
    );

    triangle(
      arrowEdgePoint.x,
      arrowEdgePoint.y,
      arrowRightPoint.x,
      arrowRightPoint.y,
      arrowLeftPoint.x,
      arrowLeftPoint.y
    );
  }
}
