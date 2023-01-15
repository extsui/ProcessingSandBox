import java.util.LinkedList;

LinkedList<Point> pointList = new LinkedList<Point>();
LinkedList<Line> lineList = new LinkedList<Line>();
LinkedList<Point> crossList = new LinkedList<Point>();

color DEFAULT_COLOR = color(255, 100, 100);

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
  for (var cross : crossList) {
    cross.draw();
  }
}

// マウスが押下された時に呼び出されるハンドラ
// NOTE: mouseClicked() の反応がかなり悪いので押下判定とした
void mousePressed(MouseEvent e) {
  switch (e.getButton()) {  // mouseButton でも思う
  case LEFT: // 左クリック
    Point newPoint = new Point(mouseX, mouseY);
    if (pointList.size() >= 1) {
      Line newLine = new Line(pointList.getLast(), newPoint);

      // 交点の設定
      // 新しく追加した Line を今まで描いた Line 全てと交点判定をする
      // ただし直前に描いた Line は除く (線分の端点が必ず交点になってしまうため)
      for (var line : lineList) {
        if (line != lineList.getLast()) {
          Point crossPoint = ContainsCrossPoint(newLine, line);
          if (crossPoint != null) {
            print("cross = (" + crossPoint.GetX() + ", " + crossPoint.GetY() + ")\n");
            crossList.add(crossPoint);
          }
        }
      }

      lineList.add(newLine);
    }
    pointList.add(newPoint);
    break;
  case CENTER:  // ホイールクリック
    break;
  case RIGHT:  // 右クリック
    pointList.clear();
    lineList.clear();
    crossList.clear();
    break;
  default:
    break;
  }
  // DEBUG:
  print("click = (" + mouseX + ", " + mouseY + ")\n");
}

// グラフの点
class Point {
  private int x;
  private int y;
  private color _color;

  int GetX() {
    return x;
  }

  int GetY() {
    return y;
  }

  Point(int x, int y, color c) {
    this.x = x;
    this.y = y;
    this._color = c;
  }

  Point(int x, int y) {
    this(x, y, DEFAULT_COLOR);
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
  public Point begin;
  public Point end;

  Line(Point begin, Point end) {
    this.begin = begin;
    this.end = end;
  }

  // 二点間の角度 (rad)
  private double getRadian() {
    double radian = Math.atan2(end.GetY() - begin.GetY(), end.GetX() - begin.GetX());
    return radian;
  }

  // 対象の点が線分の範囲内にあるか
  boolean isRange(int x, int y) {
    int xMin;
    int xMax;
    if (begin.GetX() > end.GetX()) {
      xMin = end.GetX();
      xMax = begin.GetX();
    } else {
      xMin = begin.GetX();
      xMax = end.GetX();
    }
    return ((xMin <= x) && (x <= xMax));
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
      end.GetX() + (int)(Math.cos(arrowReverseRadian) * 10),
      end.GetY() + (int)(Math.sin(arrowReverseRadian) * 10)
    );

    // 矢印の先端が太く見えてしまうのを避けるために線分は少し短く描画する
    {
      stroke(color(255, 100, 100));
      strokeWeight(5);
      Point endForDraw = new Point(
        end.GetX() + (int)(Math.cos(arrowReverseRadian) * 10),
        end.GetY() + (int)(Math.sin(arrowReverseRadian) * 10)
      );
      line(begin.x, begin.y, endForDraw.x, endForDraw.y);
    }

    final int ARROW_SIZE = 10;

    Point arrowRightPoint = new Point(
      arrowEdgePoint.GetX() + (int)(Math.cos(arrowRightRadian) * ARROW_SIZE),
      arrowEdgePoint.GetY() + (int)(Math.sin(arrowRightRadian) * ARROW_SIZE)
    );

    Point arrowLeftPoint = new Point(
      arrowEdgePoint.GetX() + (int)(Math.cos(arrowLeftRadian) * ARROW_SIZE),
      arrowEdgePoint.GetY() + (int)(Math.sin(arrowLeftRadian) * ARROW_SIZE)
    );

    triangle(
      arrowEdgePoint.GetX(),
      arrowEdgePoint.GetY(),
      arrowRightPoint.GetX(),
      arrowRightPoint.GetY(),
      arrowLeftPoint.GetX(),
      arrowLeftPoint.GetY()
    );
  }
}

// 二本の線分の交点を求める
// 存在しない場合は null を返す
Point ContainsCrossPoint(final Line line1, final Line line2) {
  // 直線 p1p2 { p1(a, b), p2(c, d) } と p3p4 { p3(e, f), p4(g, h) } の交点の座標を求める公式
  //
  // div = (d - b)(g - e) - (c - a)(h - f)
  // 
  // Xp = ((fg - eh)(c - a) - (bc - ad)(g - e)) / div
  // Yp = ((fg - eh)(d - b) - (bc - ad)(h - f)) / div
  int a = line1.begin.GetX();
  int b = line1.begin.GetY();
  int c = line1.end.GetX();
  int d = line1.end.GetY();
  int e = line2.begin.GetX();
  int f = line2.begin.GetY();
  int g = line2.end.GetX();
  int h = line2.end.GetY();
  int divisor = ((d - b) * (g - e)) - ((c - a) * (h - f));
  // 除数がゼロになった場合は平行を意味している
  if (divisor == 0) {
    return null;
  }

  int fgeh = (f * g - e * h);
  int bcad = (b * c - a * d);
  int x = (fgeh * (c - a) - bcad * (g - e)) / divisor;
  int y = (fgeh * (d - b) - bcad * (h - f)) / divisor;
  if (line1.isRange(x, y) && line2.isRange(x, y)) {
    // TORIAEZU: 色を変えておく
    return new Point(x, y, #80FF80);
  } else {
    return null;
  }
}
