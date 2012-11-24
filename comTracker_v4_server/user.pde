
class User {

  PVector lerpedCom = null;
  COM com;
  color c;
  boolean tracked = false;
  COM calibCom;

  Vector<COM> candidates;

  User() {
    candidates = new Vector<COM>();
    this.com = new COM(-1);
    this.c = color(0);
    calibCom = new COM(0, new PVector(0, 0, 0));
  }

  User(COM com) {
    this.com = com;
    this.c = color(0);
    candidates = new Vector<COM>();
    calibCom = new COM(0, new PVector(0, 0, 0));
  }

  void setColor(color c) {
    this.c = c;
  }


  void draw(int s) {
    com.draw(c, s);
  }

  void resetCandidates() {
    candidates = new Vector<COM>();
  }

  boolean matchCom() {
    this.tracked = false;
    COM closest = null;

    for (COM c: candidates) {
      if (closest == null)
        closest = c;
      else if (com.dist(c) < com.dist(closest))
        closest = c;
    }
    if (closest == null) 
      return false;

    this.com = closest;
    this.tracked = true;
    return true;
  }

  void lerp() {
    if (lerpedCom == null)
      lerpedCom = new PVector(com.getCOM().x, com.getCOM().y, com.getCOM().z);

    float smoothFactor=0.25;
    lerpedCom.x = PApplet.lerp(lerpedCom.x, com.getCOM().x, smoothFactor);
    lerpedCom.y = PApplet.lerp(lerpedCom.y, com.getCOM().y, smoothFactor);
    lerpedCom.z = PApplet.lerp(lerpedCom.z, com.getCOM().z, smoothFactor);
  }
  float dist(User u) {
    return this.com.dist(u.com);
  }

  void setCalibrationPoint(COM c) {
    calibCom.pos.x = c.pos.x;
    calibCom.pos.y = c.pos.y;
    calibCom.pos.z = c.pos.z;
  }
  void resetCalibrationPoint() {
    calibCom.pos.x = 0;
    calibCom.pos.y = 0;
    calibCom.pos.z = 0;
    reset();
  }

  void reset() {
    lerpedCom = null;
    this.com = calibCom;
  }
}

