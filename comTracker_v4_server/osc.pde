import oscP5.*;
import netP5.*;

Vector<COM> cms;
OscP5 oscP5;
NetAddress pdLocation;
NetAddress myLocation;
NetAddress serverLocation;
NetAddress iPhoneLocation0;
NetAddress iPhoneLocation1;
NetAddress iPhoneLocation2;

void setupOsc() {
  oscP5 = new OscP5(this, 12000);
  pdLocation = new NetAddress("169.254.0.1", 12001);
  myLocation = new NetAddress("169.254.0.2", 12000);
  serverLocation = new NetAddress("169.254.0.3", 12000);
  iPhoneLocation0 = new NetAddress("169.254.0.4", 12000);
  iPhoneLocation1 = new NetAddress("169.254.0.5", 12000);
  iPhoneLocation2 = new NetAddress("169.254.0.6", 12000);
}

void sendPing() {
  OscMessage myMessage = new OscMessage("/ping");  
  oscP5.send(myMessage, pdLocation);
 /* oscP5.send(myMessage, iPhoneLocation0);
  oscP5.send(myMessage, iPhoneLocation1);
  oscP5.send(myMessage, iPhoneLocation2);*/
}
void sendSave() {
  OscMessage myMessage = new OscMessage("/save");
  myMessage.add(frame); 
  oscP5.send(myMessage, serverLocation);
}

void sendDistances() {
  OscMessage myMessage = new OscMessage("/distances");

  PVector v0 = users[0].lerpedCom;
  PVector v1 = users[1].lerpedCom;
  PVector v2 = users[2].lerpedCom;

  text("Distances: " + int(v0.dist(v1)) + " " 
    + int(v1.dist(v2)) + " " 
    + int(v2.dist(v0)), 10, 150);

  myMessage.add(v0.dist(v1)); 
  myMessage.add(v1.dist(v2));
  myMessage.add(v2.dist(v0)); 

  oscP5.send(myMessage, pdLocation);
  oscP5.send(myMessage, iPhoneLocation0);
  oscP5.send(myMessage, iPhoneLocation1);
  oscP5.send(myMessage, iPhoneLocation2);
}


void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/pc")==true) {
    int k = theOscMessage.get(0).intValue();
    int id = theOscMessage.get(1).intValue();
    byte bytes[] = theOscMessage.get(2).bytesValue();
    
    for(int i = 0; i < bytes.length; i += 6){
       PVector p = new PVector();
       p.x = ((int)bytes[i + 1] << 8) | ((int)bytes[i] & 0xFF);
       p.y = ((int)bytes[i + 3] << 8) | ((int)bytes[i + 2] & 0xFF);
       p.z = ((int)bytes[i + 5] << 8) | ((int)bytes[i + 4] & 0xFF);
       remotePC.add(p);
    }
  }
  
  if (theOscMessage.checkAddrPattern("/ping")==true) {
    pushStyle();
    fill(0, 255, 0);
    text("PING", 10, 135);
    popStyle();
  }

  if (theOscMessage.checkAddrPattern("/com")==true) {

    int k = theOscMessage.get(0).intValue();
    String s = theOscMessage.get(1).stringValue(); 

    String[] ss = s.split(",");
    cms.removeAllElements();

    for (int i = 0; i < ss.length; i++) {
      String[] tokens = ss[i].split(" ");
      int index = int(tokens[1]);
      PVector pos = new PVector(float(tokens[2]), 
      float(tokens[3]), 
      float(tokens[4]));
      cms.add(new COM(index, pos));
    }

    return;
  }
}


