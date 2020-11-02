import java.util.Calendar;

PImage source;

float radius = 5;     // 最初の星の大きさ(直径/2)
float addRadius = 2.0; //線と線の間隔（数字が小さいと狭い）
int vc = 0;
float SCALE = 2.0; 
boolean b = true;
float thickness = 1.5;  // 線の太さの最小値
float thickMax = 11;   // 線の太さの最大値
PVector[] vertex = {};
PVector Pos, Ac;
float tr;

void setup() {
  frameRate(240);
  size(800, 800);
  background(186, 218, 246); //背景色
  fill(16, 62, 128, 100); //線の色
  noStroke();
  //blendMode(MULTIPLY);

  source = loadImage("image.png"); // 画像をロード
  source.resize(width, height);
  source.loadPixels();
  
  PVector center = new PVector(width/2, height/2);
  float lastRadius = dist(center.x, center.y, center.x, 12); // 最後の星の大きさ(直径/2)
  float rot = (lastRadius-radius) / addRadius;

  Ac = new PVector();

  //星の頂点を配列に代入
  float outR = radius;
  for (int i = 0; i < rot; i++) {
    outR += addRadius;
    float inR = radius/2;
    if (i%2 == 0) {
      radius = outR;
    } else {
      radius = inR;
    }
    float x0 =  center.x + radius*cos(radians(-90+360*i/10));
    float y0 = center.y + radius*sin(radians(-90+360*i/10));
    vertex = (PVector[]) append(vertex, new PVector(x0, y0));
  }
  
  //星の中心が画面の真ん中に来るよう移動するための計算
  //星の底辺の中点を計算する
  PVector mp;
  PVector tcenter;
  if ((vertex.length-1)%10 == 0) {
    mp = calcMidPoint(vertex[vertex.length-1], vertex[vertex.length-3]);
  } else {
    mp = calcMidPoint(vertex[vertex.length-2], vertex[vertex.length-4]);
  }
  //星の高さの中心を計算する
  if ((vertex.length-1%2) == 0) {
    tcenter = calcMidPoint(vertex[vertex.length-7], mp);
  } else {
    tcenter = calcMidPoint(vertex[vertex.length-8], mp);
  }
  //星の中心が画面の真ん中に来るよう移動するための数値
  tr = dist(center.x, center.y, tcenter.x, tcenter.y);
  
}

//辺の中点を計算する
PVector calcMidPoint(PVector end1, PVector end2) {
  float mx, my;
  if (end1.x > end2.x) {
    mx = end2.x + ((end1.x - end2.x)/2);
  } else {
    mx = end1.x + ((end2.x - end1.x)/2);
  }
  if (end1.y > end2.y) {
    my = end2.y + ((end1.y - end2.y)/2);
  } else {
    my = end1.y + ((end2.y - end1.y)/2);
  }
  PVector cMP = new PVector(mx, my);
  return cMP;
}

void draw() {
  if (b) {
    Pos = vertex[vc];
  }

  b = false;

  //Posと次の頂点との距離
  float dist = PVector.dist(Pos, vertex[vc+1]);
  Ac = PVector.sub(vertex[vc+1], Pos); //次の頂点に向かうベクトルを計算
  Ac.normalize(); //単位ベクトル化

  int cpos = (int(Pos.y+tr) * source.width) + int(Pos.x); // 画像の色を取得
  color c = source.pixels[cpos]; // 暗い色を太い線に、明るい色を細い線にする
  float dim = map(brightness(c), 0, 255, thickMax, thickness);
  ellipse(Pos.x, Pos.y+tr, dim, dim);

  if (dist>1) {
    Pos.add(Ac.x*SCALE, Ac.y*SCALE);
  } else {
    PVector m = new PVector();
    m = PVector.sub(vertex[vc+1], Pos);
    Pos.add(m.x, m.y);
  }

  if (dist<=0) { //線が角まで来たら
    if (vc == vertex.length-2) {
      noLoop();
    }
    b = true;
    vc += 1;
  }
}

void keyPressed() {
  if (key == 's' || key == 'S')saveFrame(timestamp()+"_####.png");
}


String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
