
import SimpleOpenNI.*;
SimpleOpenNI context;

float  zoomF =0.15f;
float  rotX = radians(180);                        
float  rotY = radians(0);
PVector[] realWorldMap;
int[]   depthMap;
int userCount;
int[] userMap;

int K; //Kinect id
int frame = 0;

color[]   userColors = { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};

int   steps;  
KinectData kinectData;

String remoteHost;
int remotePort, localPort;
boolean bSendCOMData, bSendPCData;

boolean saving = false;

PFont font; 
String msg = "";
void setup()
{
  
  loadSettings();
  K = loadSetting("KINECT_ID", 0);
  remoteHost = loadSetting("REMOTE_HOST", "localhost");
  localPort = loadSetting("LOCAL_PORT", 12000);
  remotePort = loadSetting("REMOTE_PORT", 12000);
  steps = loadSetting("STEPS", 6);
  bSendCOMData =  loadSetting("SEND_COM_DATA", true);
  bSendPCData =  loadSetting("SEND_PC_DATA", true);
  
  size(800, 600, P3D);
  //context = new SimpleOpenNI(this,SimpleOpenNI.RUN_MODE_MULTI_THREADED);
  context = new SimpleOpenNI(this);
  context.setMirror(false);

  // enable depthMap generation 
  if (context.enableDepth() == false)
  {
    println("Can't open the depthMap, maybe the camera is not connected!"); 
    exit();
    return;
  }
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  context.enableScene();

  perspective(radians(45), 
  float(width)/float(height), 
  10, 150000);

  setupOsc();
  kinectData = new KinectData();
  
  
  font = loadFont("mono.vlw");
  textFont(font);
}

void draw()
{
  // update the cam
  context.update();
  background(0, 0, 0);
  depthMap = context.depthMap();
  kinectData.resetState();
  processRawData();
  
  if(saving){
    String fileName = "snapshot_" + frame + ".ply";
    kinectData.saveFrame(fileName);
    msg = "Saved " + fileName;
    saving = false;
  }
  
  context.drawCamFrustum();
  
  if(frameRate % 30 == 0) sendPing(); 
  
  if(bSendCOMData) sendCoMs();
  
  if(bSendPCData) sendPCs();
  
  
  textMode(SCREEN);
  fill(255);
  textSize(12);
  text("FPS " + frameRate, 10, 10);
  text("Kinect ID " + K, 10, 25);
  text("Local host " + oscP5.ip() + " " + oscP5.properties().listeningPort(), 10, 40);
  text("Remote host " + remoteHost + " " + remotePort, 10, 55);
  text("Detail  [a/q]" + steps, 10, 70);
  text("Sending Com data: " + bSendCOMData + " nCOMS: " + kinectData.getNumberCOMS(), 10, 85); 
  text("Sending Point Cloud[k]: " + bSendPCData, 10, 100); 
  text(msg, 10, 115);
  
  
}

void keyPressed()
{
  if(key == 'k') bSendPCData = !bSendPCData;
  if(key == 'q') steps += 1;
  if(key == 'a') steps -= 1;
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

void processRawData() {

  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);
  translate(0, 0, -2000); 

  realWorldMap = context.depthMapRealWorld();
  userCount = context.getNumberOfUsers();
  userMap = null;
  if (userCount > 0)
    userMap = context.getUsersPixels(SimpleOpenNI.USERS_ALL);

  for (int y=0;y < context.depthHeight();y+=steps)
  {
    for (int x=0;x < context.depthWidth();x+=steps)
    {
      int index = x + y * context.depthWidth();
      if (depthMap[index] > 0)
      { 
        PVector realWorldPoint = context.depthMapRealWorld()[index];
        if (userMap != null && userMap[index] != 0) {
          int userIndex = userMap[index] % userColors.length;
          stroke(userColors[userIndex]); 
          point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
          kinectData.addPoint(userIndex, realWorldPoint);
        }
      }
    }
  }
}
