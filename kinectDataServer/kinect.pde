class KinectData {
  Vector<COM> coms;

  KinectData() {
    coms = new Vector<COM>();
  }

  void addPoint(int id, PVector p) {
    boolean added = false;
    for (COM c: coms) {
      if (c.id == id) {
        c.addPoint(p); 
        added = true;
        break;
      }
    }
    if (!added) {
      COM c = new COM(id);
      c.addPoint(p);
      coms.add(c);
    }
  }
  int getNumberCOMS(){
    return coms.size();
  }
  void resetState() {
    coms.removeAllElements();
  }
  void saveFrame(String fileName) {
    PrintWriter output;
    output = createWriter(fileName);
    output.println("ply");
    output.println("format ascii 1.0");
    output.println("comment : created from Kinect user tracker");
    int n = 0;
    for (COM c: coms)  n += c.points.size();
    output.println("element vertex "+ n);
    output.println("property float x");
    output.println("property float y");
    output.println("property float z");
    output.println("property int userId");
    output.println("end_header");
    for (COM c: coms)  c.saveFrame(output);
    output.close();
  }
}

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
  void addPoint(PVector p) {
    n += 1;
    pos.x += p.x;
    pos.y += p.y;
    pos.z += p.z;
    points.add(p);
  } 

  PVector getCOM() {
    return new PVector(pos.x/n, pos.y/n, pos.z/n);
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
}

