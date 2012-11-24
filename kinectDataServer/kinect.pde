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
  int getNumberCOMS() {
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
    for (COM c: coms)  c.savePoints(output);
    output.close();
  }
}

class COM {
  int id;
  PVector pos;
  Vector<PVector> points;

  COM(int id) {
    this.id = id;
    pos = new PVector(0, 0, 0);
    points = new Vector<PVector>();
  }
  
  void addPoint(PVector p) {
    pos.x += p.x;
    pos.y += p.y;
    pos.z += p.z;
    points.add(p);
  } 

  PVector getCOM() {
    int n = points.size();
    return new PVector(pos.x/n, pos.y/n, pos.z/n);
  }

  String toString() {
    PVector com = getCOM();
    return "c " + id + " " + com.x + " " + com.y + " " + com.z;
  }

  void savePoints(PrintWriter output) {
    for (PVector p: points) {
      String s = p.x + " " + p.y + " " + p.z + " " + id;
      output.println(s);
    }
  }
  
  boolean canSerializeMoreData(int packect) {
    return points.size() - (200 * packect) > 0;
  }
  void serializeToBytes(byte[] A, int packect) {
    int n = 0;
    for (int i = 200 * packect; i < 200; i += 1, n += 6) {
      if (i >= points.size()) break;
      PVector p = points.get(i);
      short x = (short)(p.x);
      short y = (short)(p.y);
      short z = (short)(p.z);
      A[n    ] = (byte)(x & 0xff);
      A[n + 1] = (byte)((x >> 8) & 0xff);
      A[n + 2] = (byte)(y & 0xff);
      A[n + 3] = (byte)((y >> 8) & 0xff);
      A[n + 4] = (byte)(z & 0xff);
      A[n + 5] = (byte)((z >> 8) & 0xff);
    }
  }
}

