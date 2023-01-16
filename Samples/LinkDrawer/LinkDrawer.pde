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

  // TODO: おそらく全て共通のインタフェースにできるはず

  // 描画処理
  for (var point : pointList) {
    point.draw();
  }
  for (var line : lineList) {
    line.draw();
  }
  for (var cross : crossList) {
    cross.draw();
  }

  // マウスとの衝突判定
  Point mousePoint = new Point(mouseX, mouseY);
  for (var point : pointList) {
    if (point.isCollided(mousePoint)) {
      point.onCollided();
    }
  }
  for (var line : lineList) {
    if (line.isCollided(mousePoint)) {
      line.onCollided();
    }
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
            print("cross = (" + crossPoint.x + ", " + crossPoint.y + ")\n");
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
  public int x;
  public int y;
  private color _color;

  final int RADIUS = 10;

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

  // 対象の点と衝突しているか
  boolean isCollided(final Point point) {
    // 二点間の距離が r 以下であれば衝突している
    int diffX = (point.x - this.x);
    int diffY = (point.y - this.y);
    double distance = Math.sqrt(diffX * diffX + diffY * diffY);
    return distance <= RADIUS;
  }

  // 衝突時の処理
  void onCollided() {
    fill(#8080FF);
    noStroke();
    ellipse(x, y, 10, 10);
  }
}

// グラフ線分
class Line {
  // 二点への参照で表現する
  public Point begin;
  public Point end;

  // 衝突判定用長方形の幅
  final int THICKNESS = 5;

  // 衝突判定用の内部データ (長方形で記載しているが実際は斜めの場合もあり)
  //               <---
  //                v4 (vector)
  //       p1 +-------------+ p4      +
  //          |             |         |-- THICKNESS
  //  begin-->*             *<--end   +
  //          |             |
  //       p2 +-------------+ p3
  //               --->
  //                v2 (vector)
  private Point p1, p2, p3, p4; // 四隅の点
  private Point v1, v2, v3, v4; // 各点間のベクトル

  Line(Point begin, Point end) {
    this.begin = begin;
    this.end = end;

    // それぞれの端点の +90°, -90° に一定距離進んだ点を四隅の点とする
    double verticalUpRadian = getSlope() + (90 * Math.PI / 180);
    double verticalDownRadian = getSlope() + (-90 * Math.PI / 180);

    p1 = new Point(
      begin.x + (int)(Math.cos(verticalUpRadian) * THICKNESS),
      begin.y + (int)(Math.sin(verticalUpRadian) * THICKNESS)
    );
    p2 = new Point(
      begin.x + (int)(Math.cos(verticalDownRadian) * THICKNESS),
      begin.y + (int)(Math.sin(verticalDownRadian) * THICKNESS)
    );
    p3 = new Point(
      end.x + (int)(Math.cos(verticalDownRadian) * THICKNESS),
      end.y + (int)(Math.sin(verticalDownRadian) * THICKNESS)
    );
    p4 = new Point(
      end.x + (int)(Math.cos(verticalUpRadian) * THICKNESS),
      end.y + (int)(Math.sin(verticalUpRadian) * THICKNESS)
    );

    // 衝突判定用に p1->p2, p2->p3, p3->p4, p4->p1 のベクトルを作成
    // * Point 構造体で代用 (ベクトルとして使用していることに注意)
    v1 = new Point(p2.x - p1.x, p2.y - p1.y);
    v2 = new Point(p3.x - p2.x, p3.y - p2.y);
    v3 = new Point(p4.x - p3.x, p4.y - p3.y);
    v4 = new Point(p1.x - p4.x, p1.y - p4.y);
  }

  // 二点間の角度 (rad)
  private double getSlope() {
    double radian = Math.atan2(end.y - begin.y, end.x - begin.x);
    return radian;
  }

  // 対象の点が線分の範囲内にあるか
  boolean isRange(int x, int y) {
    int xMin;
    int xMax;
    if (begin.x > end.x) {
      xMin = end.x;
      xMax = begin.x;
    } else {
      xMin = begin.x;
      xMax = end.x;
    }
    return ((xMin <= x) && (x <= xMax));
  }

  void draw() {

    // DEBUG:
    //stroke(#CCCCCC);
    //quad(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);

    // TODO: 要メソッド化
    
    // 終点に矢印を描画
    double lineRadian = getSlope();
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

  // 外積
  private int getOuterProduct(final Point vect1, final Point vect2) {
    return vect2.x * vect1.y - vect1.x * vect2.y;
  }

  boolean isCollided(final Point point) {
    // 4個のベクトルの外積を求めて全て正なら内側
    int o1 = getOuterProduct(v1, new Point(p1.x - point.x, p1.y - point.y));
    int o2 = getOuterProduct(v2, new Point(p2.x - point.x, p2.y - point.y));
    int o3 = getOuterProduct(v3, new Point(p3.x - point.x, p3.y - point.y));
    int o4 = getOuterProduct(v4, new Point(p4.x - point.x, p4.y - point.y));

    // DEBUG:
    //fill(0);
    //textSize(12);
    //text(o1 + "," + o2 + "," + o3 + "," + o4, 0, 12);

    return (o1 >= 0) && (o2 >= 0) && (o3 >= 0) && (o4 >= 0);
  }

  // 衝突時の処理
  void onCollided() {
    fill(#8080FF);
    noStroke();
    quad(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
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
  int a = line1.begin.x;
  int b = line1.begin.y;
  int c = line1.end.x;
  int d = line1.end.y;
  int e = line2.begin.x;
  int f = line2.begin.y;
  int g = line2.end.x;
  int h = line2.end.y;
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
