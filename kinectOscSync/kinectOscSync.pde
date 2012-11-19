int FPS = 15;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
Vector<NetAddress> hosts;

int frame = 0;
boolean saving = false;
void setup() {
  size(200,200);
  frameRate(FPS);
  oscP5 = new OscP5(this,12000);
  hosts = new Vector<NetAddress>();
  hosts.add(new NetAddress("localhost", 9000));
  hosts.add(new NetAddress("169.254.33.7", 9000));
  
}

void draw() {
  if(!saving) 
    background(10, 255, 40); 
  else{
    background(255, 10, 40);
    OscMessage myMessage = new OscMessage("/save");
    myMessage.add(frame); 
    for(NetAddress n: hosts)
      oscP5.send(myMessage,n);
    frame += 1;
  }
  fill(0);
  text("clik to start/stop saving\nRunning at " + FPS 
  + " fps\nFrame: " + frame, 10, 20);
}

void mousePressed(){
    saving = !saving;
    if(saving) frame = 0;     
}

