int FPS = 15;
String remoteHost0 = "localhost";
int remotePort0 = 9000;
String remoteHost1 = "localhost";
int remotePort1 = 9001;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation0, myRemoteLocation1;

int frame = 0;
boolean saving = false;
void setup() {
  size(200,200);
  frameRate(FPS);
  oscP5 = new OscP5(this,12000);
  myRemoteLocation0 = new NetAddress(remoteHost0, remotePort0);
  myRemoteLocation1 = new NetAddress(remoteHost1, remotePort1);
  
}

void draw() {
  if(!saving) 
    background(10, 255, 40); 
  else{
    background(255, 10, 40);
    OscMessage myMessage = new OscMessage("/save");
    myMessage.add(frame); 
    oscP5.send(myMessage, myRemoteLocation0);
    oscP5.send(myMessage, myRemoteLocation1);
    frame += 1;
  }
  fill(0);
  text("clik to start/stop saving\nRunning at " + FPS 
  + " fps\nFrame: " + frame + "\nRemote location (0):\n" 
  + remoteHost0 + " " + remotePort0 + "\nRemote location (1):\n" 
  + remoteHost1 + " " + remotePort1, 10, 20);
}

void mousePressed(){
    saving = !saving;
    if(saving) frame = 0;     
}

