
class COM {
  int id;
  PVector pos;
  int n;
  Vector<PVector> points;

  COM(int id) {
    this.id = id;
    pos = new PVector(0, 0, 0);
    points = new Vector<PVector>();
  }
  COM(int id, PVector p) {
    this.id = id;
    this.pos = p;
    this.n = 1;
    points = new Vector<PVector>();
  }
  void addPoint(PVector p) {
    n += 1;
    pos.x += p.x;
    pos.y += p.y;
    pos.z += p.z;
    points.add(p);
  } 

  void setCoM() {
    pos =  new PVector(pos.x/n, pos.y/n, pos.z/n);
  }

  PVector getCOM() {
    return pos;
  }

  String toString() {
    return "c " + id + " " + pos.x/n + " " + pos.y/n + " " + pos.z/n;
  }

  void saveFrame(PrintWriter output) {
    for (PVector p: points) {
      String s = p.x + " " + p.y + " " + p.z + " " + id;
      output.println(s);
    }
  }

  void draw(color col, int s) {
    // println("Drawing: " + this.toString());
    PVector p = getCOM();

    pushMatrix();
    pushStyle();
    stroke(col);
    fill(col);
    translate(p.x, p.y, p.z);

    ellipse(0, 0, s, s);
    popStyle();
    popMatrix();
  }

  void calculateRealWorldCoordinates() {

    PVector p = getCOM();
    pushMatrix();
    translate(p.x, p.y, p.z);
    stroke(255, 0, 0);
    this.pos =  new PVector(
    modelX(0, 0, 0), 
    modelY(0, 0, 0), 
    modelZ(0, 0, 0));
    popMatrix();
  }


  void draw() {
    this.draw(color(255), 5);
  }

  float dist(User u) {
    return this.dist(u.com);
  }

  float dist(COM c) {
    PVector p = getCOM();
    return p.dist(c.getCOM());
  }
}

