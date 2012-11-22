
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setupOsc() {
  oscP5 = new OscP5(this, localPort);
  myRemoteLocation = new NetAddress(remoteHost, remotePort);
  println("Conntect to: " + remoteHost + " port: " + remotePort);
}

void oscEvent(OscMessage theOscMessage) {

  if (theOscMessage.checkAddrPattern("/save")==true) {
    frame = theOscMessage.get(0).intValue();  
    saving = true;
    return;
  } 
  println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
}
void sendPing() {
  OscMessage myMessage = new OscMessage("/ping");
  println("Ping");
  oscP5.send(myMessage, myRemoteLocation);
}
void sendCoMs() {
  if ( kinectData.coms.size() > 0) {
    OscMessage myMessage = new OscMessage("/com");

    myMessage.add(K);

    String s = "";
    for (COM c: kinectData.coms) {
      s += c.toString();
      s += ",";
    }

    myMessage.add(s);
    oscP5.send(myMessage, myRemoteLocation);
  }
}
void sendPCs() {

  for (COM c: kinectData.coms) {
    OscMessage myMessage = new OscMessage("/pc");
    myMessage.add(K);
    myMessage.add(c.id);
    byte[] bytes = new byte[1200];
    for(int i = 0; i < 1200; i++) bytes[i] = 0;
    c.toBytes(bytes);
    myMessage.add(bytes);
    oscP5.send(myMessage, myRemoteLocation);
  }
}

