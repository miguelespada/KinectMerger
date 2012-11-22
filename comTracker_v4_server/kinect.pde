class KinectData {
  Vector<COM> coms;
  float M[]; 

  private float bestValue;
  private int[] bestSol;

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
  void addCoM(int id, PVector p) {
    coms.add(new COM(id, p));
  }

  void drawCoM() {
    for (COM c: coms)
      c.draw();
  }
  void calculateRealWorldCoordinates() {
    pushMatrix();
    applyMatrix(this.M);
    for (COM c: coms)
      c.calculateRealWorldCoordinates();
    popMatrix();
  }
  void setCoM() { 
    for (COM c: coms)
      c.setCoM();
  }

  void setMatrix(float[] M) {
    this.M = M;
  }
  float[] getMatrix() {
    return this.M;
  }
  void resetState() {
    coms.removeAllElements();
  }

  boolean calibrate() {
    if (coms.size() != N) return false;

    for (int i = 0; i < N; i++)  
      users[i].com = coms.get(i);

    return true;
  }


  void matchCandidates() {

    int[] sol = new int[N];
    bestValue = 100000000;
    bestSol = new int[N];
    for (int i = 0; i < N; i ++)
      bestSol[i] = -1;

    matchCandidatesBT(0, sol);

    for (int i = 0; i < N; i ++) {
      if (bestSol[i] != -1)
        users[i].candidates.add(coms.get(bestSol[i]));
    }
  }

  boolean isSol(int k, int j, int sol[]) {
    for (int i = 0; i < k; i++) {
      if (sol[i] == -1) continue;
      if (j == sol[i]) return false;
    }
    return true;
  }

  float distancias(int sol[]) {
    float v = 0;
    for (int i = 0; i < N; i ++) {
      if (sol[i] == -1) v += 1000;
      else v += coms.get(sol[i]).dist(users[i]);
    }
    return v;
  }

  void matchCandidatesBT(int k, int sol[]) {
    for (int j = -1; j < coms.size(); j++) {
      if (isSol(k, j, sol)) {
        sol[k] = j;
        if (k == N - 1) {
          float currentValue = distancias(sol);
          if (currentValue < bestValue) {
            for (int i = 0; i < N; i ++)
              bestSol[i] = sol[i];
            bestValue = currentValue;
          }
        }
        else
          matchCandidatesBT(k + 1, sol);
      }
    }
  }
  void setCalibrationPoint(int id){
    if (coms.size() ==1) 
      users[id].setCalibrationPoint(coms.get(0));
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

