void parseMatrix(){
  XMLElement xml = new XMLElement(this, matrixFile);
  String auxM0 = xml.getChild(0).getChild(0).getChild(0).getContent();
  String auxM1 = xml.getChild(0).getChild(1).getChild(0).getContent();
 
  auxM0 = auxM0.replace("\n", "");
  String[] tokens = auxM0.split(" ");
  M0 = new float[tokens.length];
  for(int i = 0; i < tokens.length; i++)
    M0[i] = float(tokens[i]);
  
  auxM1 = auxM1.replace("\n", "");
  tokens = auxM1.split(" ");
  M1 = new float[tokens.length];
  for(int i = 0; i < tokens.length; i++)
    M1[i] = float(tokens[i]);
  
}

void applyMatrix(float[] M){
 applyMatrix(
   M[0], M[1], M[2], M[3],
   M[4], M[5], M[6], M[7],
   M[8], M[9], M[10], M[11],
   M[12], M[13], M[14], M[15]);   
}

PVector multMatrix(float M[], PVector pos){
  float[] R = new float[4];
    float[] P = {pos.x, pos.y, pos.z, 1};
  
  for(int i = 0; i < 4; i ++){
    int index = i;
      R[i] = M[i] * P[0] + M[i + 1] * P[1] + M[i + 2] * P[2] + M[i + 3] * P[3];
  }
  return new PVector(R[0], R[1], R[2]);
  
}


