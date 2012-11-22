int N = 3;

import SimpleOpenNI.*;

SimpleOpenNI context;
float        zoomF =0.12f;
float        rotX = 2;  // by default rotate the hole scene 180deg around the x-axis,                                   // the data from openni comes upside down
float        rotY = radians(0);
PVector[] realWorldMap;
int[]   depthMap;


String matrixFile = "/Users/miguel/Desktop/aligment3.mlp";

color[]   userColors = { 
  color(255, 0, 0), color(0, 255, 0), color(0, 0, 255), color(255, 255, 0), color(255, 0, 255), color(0, 255, 255)
};
color[]  userCoMColors = { 
  color(255, 100, 100), color(100, 255, 100), color(100, 100, 255), color(255, 255, 100), color(255, 100, 255), color(100, 255, 255)
};

int userCount;
int[] userMap;

KinectData[] kinects;
User[] users;

boolean calibrated = false;
boolean saving = false;

float[] M0, M1;
boolean tracking = false;
int frame; 

void setup()
{
  frameRate(300);

  size(1024, 768, P3D);  
  parseMatrix();
  context = new SimpleOpenNI(this);
  context.setMirror(false);

  if (context.enableDepth() == false)
  {
    println("Can't open the depthMap, maybe the camera is not connected!"); 
    exit();
    return;
  }
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  context.enableScene();

  stroke(255, 255, 255);
  
  perspective(radians(45), 
  float(width)/float(height), 
  10, 150000);


  setupOsc();
  kinects = new KinectData[2];
  kinects[0] = new KinectData();
  kinects[1] = new KinectData();

  kinects[0].setMatrix(M0);
  kinects[1].setMatrix(M1);


  users = new User[N];
  for (int i = 0; i < N; i++) {
    users[i] = new User();
    users[i].setColor(userCoMColors[i]);
  }
  
  users[0].calibCom = new COM(0, new PVector(61, -250, 1820));
  users[1].calibCom = new COM(0, new PVector(-360, 346, 4140));
  users[2].calibCom = new COM(0, new PVector(1270, 297, 2853));
}

void draw()
{
  // update the cam
  context.update();

  background(0, 0, 0);


  pushMatrix();
  kinects[0].resetState(); 

  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);

  depthMap = context.depthMap();
  int     steps   = 6;  
  int     index;
  PVector realWorldPoint;

  translate(0, 0, -2000); 

  stroke(255);

  realWorldMap = context.depthMapRealWorld();
  userCount = context.getNumberOfUsers();
  userMap = null;
  if (userCount > 0)
  {
    userMap = context.getUsersPixels(SimpleOpenNI.USERS_ALL);
  }

  for (int y=0;y < context.depthHeight();y+=steps)
  {
    for (int x=0;x < context.depthWidth();x+=steps)
    {
      index = x + y * context.depthWidth();
      if (depthMap[index] > 0)
      { 
        // get the realworld points
        realWorldPoint = context.depthMapRealWorld()[index];

        // check if there is a user
        if (userMap != null && userMap[index] != 0)
        {  // calc the user color
          int colorIndex = userMap[index] % userColors.length;
          stroke(userColors[colorIndex]); 
          point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
          kinects[0].addPoint(colorIndex, realWorldPoint);
        }
      }
    }
  }
  if(saving){
    sendSaving();
    String fileName = "snapshot_" + frame + ".ply";
    kinect[0].saveFrame(fileName);
    frame ++;
  }
  kinects[0].setCoM();

  kinects[0].calculateRealWorldCoordinates();
  kinects[1].calculateRealWorldCoordinates();

  context.drawCamFrustum();
  for (User u: users)
    u.calibCom.draw(color(40, 200, 100), 30);

  popMatrix();
  
    
  kinects[0].drawCoM();
  kinects[1].drawCoM();
  
  

  if (tracking) {
    if (!calibrated) {
      print("Calibrating... ");
      for (KinectData d:kinects) {
        if (d.calibrate()) {
          calibrated = true;
          break;
        }
      }
      if (calibrated) println("[YES]");
      else println("[NO]");
    }
    else {
      for (User u: users)
        u.resetCandidates();

      for (KinectData d:kinects)
        d.matchCandidates();

      for (User u: users)
        u.matchCom();
    }
    for (User u: users) 
      u.lerp();

    for (User u: users)
      u.draw(5);

    pushStyle();
    strokeWeight(4);
    // noStroke();
    fill(255, 5, 0, 100);

    beginShape();   
    for (int i = 0; i < N; i++)
      for (int j = 0; j < N; j++)
      {

        PVector v0 = users[i].lerpedCom;
        vertex(v0.x, v0.y, v0.z);
      }
    endShape(CLOSE);

    PVector v0 = users[0].lerpedCom;
    PVector v1 = users[1].lerpedCom;
    PVector v2 = users[2].lerpedCom;
    stroke(255, 0, 0);
    line(v1.x, v1.y, v1.z, v0.x, v0.y, v0.z);
    stroke(0, 255, 0);
    line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
    stroke(0, 0, 255);
    line(v2.x, v2.y, v2.z, v0.x, v0.y, v0.z);

    popStyle();
    sendDistances();
  }

  updateCoMs();

  textMode(SCREEN);
  fill(255);
  if (frameCount % 30 == 0) {
    sendPing();
    println("fps: "+ frameRate);
  }
  text("fps: "+ frameRate + "\n" +  
    kinects[0].coms.size() + " local coms" + "\n"  
    + kinects[1].coms.size() + " remote coms" + "\n" 
    , 10, 40);
  if (calibrated && tracking) {
    fill(0, 255, 0);
    text("CALIBRATED [ON] TRACKING [ON] type 't' to turn ON/OFF the tracking", 10, 20);
  }
  if (!tracking) {
    fill(255, 0, 0);
    text("CALIBRATED [OFF] TRACKING [OFF] type 't' to turn ON/OFF the tracking", 10, 20);
  }
  if (!calibrated && tracking) {
    fill(255, 255, 0);
    text("CALIBRATED [OFF] TRACKING [ON] type 't' to turn ON/OFF the tracking", 10, 20);
  }
  // sendTestDistances();


  text("Calibration Points [1/2/3]: " + users[0].calibCom.toString() + " " 
    + users[1].calibCom.toString() + " " 
    + users[2].calibCom.toString(), 10, 105);
  text("Saving: " + saving, 10, 125);
}


void keyPressed()
{
  switch(key)
  {
  case 's':
    saving = !saving;
    println("[SAVING: ] " + saving);
    if(saving) frame = 0;
    break;
  case ' ':
    calibrated = false;
    break;
  case 't':
    tracking = !tracking;
    println("Tracking: " + tracking);
    if (!tracking) {
      calibrated = false;
      for (int i = 0; i < N; i++) 
        users[i].reset();
    }
    break;
  case '0':
    users[0].resetCalibrationPoint();
    users[1].resetCalibrationPoint();
    users[2].resetCalibrationPoint();
    break;
  case '1':
    kinects[0].setCalibrationPoint(0);
    break;
  case '2':
    kinects[0].setCalibrationPoint(1);
    break;
  case '3':
    kinects[0].setCalibrationPoint(2);
    break;
  }
  switch(keyCode)
  {
  case LEFT:
    rotY += 0.1f;
    break;
  case RIGHT:
    // zoom out
    rotY -= 0.1f;
    break;
  case UP:
    if (keyEvent.isShiftDown())
      zoomF += 0.02f;
    else
      rotX += 0.1f;
    break;
  case DOWN:
    if (keyEvent.isShiftDown())
    {
      zoomF -= 0.02f;
      if (zoomF < 0.01)
        zoomF = 0.01;
    }
    else
      rotX -= 0.1f;
    break;
  }
}

