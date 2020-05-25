//*********************************************
// Example Code for Interactive Intelligent Products
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

import processing.serial.*;
Serial port; 

PImage img0;
PImage img1;
PImage img2;
PImage img3;

import processing.sound.*;
SoundFile file;
SoundFile file2;
SoundFile file3;
SoundFile file4;
SoundFile gong;

int sensorNum = 3;
int[] rawData = new int[sensorNum];
boolean dataUpdated = false;

char guess;

boolean played = true;// false if you want the introduction
boolean played2 = false;
boolean played3 = false;
boolean played4 = false;
boolean playedGong= false;

boolean pose0= false; 
boolean pose1= false;
boolean pose2 = false;
boolean pose3= false;

boolean check = false;



void setup() {
  size(800, 450);             //set a canvas
  // fullScreen();

  file = new SoundFile(this, "Pose-1.wav");
  file2 = new SoundFile (this, "Pose-5.wav");
  file3= new SoundFile (this, "Pose-6.wav");
  file4 = new SoundFile(this, "Pose-7.wav");
  gong = new SoundFile (this, "gong.wav");


  img0= loadImage("3_poses_zonnegroet-04.png");
  img1= loadImage("3_poses_zonnegroet-01.png");
  img2= loadImage("3_poses_zonnegroet-02.png");
  img3= loadImage("3_poses_zonnegroet-03.png");

  //Initialize the serial port
  for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);
  String portName = Serial.list()[Serial.list().length-1];//MAC: check the printed list
  //String portName = Serial.list()[9];//WINDOWS: check the printed list
  port = new Serial(this, portName, 115200);
  port.bufferUntil('\n'); // arduino ends each data packet with a carriage return 
  port.clear();           // flush the Serial buffer

  loadTrainARFF(dataset="A012GestTest3.arff"); //load a ARFF dataset
  trainLinearSVC(C=1);               //train a linear SV classifier
  saveModel(model="LinearSVC.model"); //save the model

  background(52);
}

void draw() {

  //image (img1,0,0, width,height);
  if (dataUpdated) {
    //background(52);
    fill(255);
    float[] X = {rawData[0], rawData[1], rawData[2]}; 
    String Y = getPrediction(X);
    guess= Y.charAt(0);

    playImage(guess);
    dataUpdated = false;
  }
}

void serialEvent(Serial port) {   
  String inData = port.readStringUntil('\n');  // read the serial string until seeing a carriage return
  if (!dataUpdated) 
  {
    if (inData.charAt(0) == 'A') {
      rawData[0] = int(trim(inData.substring(1)));
    }
    if (inData.charAt(0) == 'B') {
      rawData[1] = int(trim(inData.substring(1)));
    }
    if (inData.charAt(0) == 'C') {
      rawData[2] = int(trim(inData.substring(1)));
      dataUpdated = true;
    }
  }
  return;
}

void playImage(char pred) {
  println(pred);
  if (pose0== false) {
    image(img0, 0, 0, width, height);
    playSound(0);
  }

  if (file.isPlaying() == false && pose0 ==false) {
    image(img1, 0, 0, width, height);
    playSound(1);
    pose0= true;
  }

  // Pose B = first pose
  if (file2.isPlaying()==false && played2== true && pred=='B'  && gong.isPlaying() == false && playedGong == false && pose1==false && pose0==true) {
    gong.play();
    println(pred);
    playedGong = true;
    pose1 = true;
  }
  //reset gong and play next instuction
  if (gong.isPlaying() == false && playedGong==true && pose2== false) {
    playedGong= false;
    image(img2, 0, 0, width, height);
    playSound(2);
  }


  //Pose C = second pose
  if (file3.isPlaying()==false && played3== true && pred=='C' && gong.isPlaying() == false && playedGong == false && pose1 == true && pose2 == false) {
    // sw2.start();
    gong.play();
    println(pred);
    playedGong = true;
    pose2= true;
  }
  //reset gong and play next instuction
  if (gong.isPlaying() == false && playedGong==true && pose3 ==false) {
    playedGong= false;
    image(img3, 0, 0, width, height);
    playSound(3);
  }
  //Pose D = third pose
  if (file4.isPlaying()==false && played4== true && pred=='D' && gong.isPlaying() == false && playedGong == false && pose1 == true && pose2 == true && pose3 == false) {
    // sw2.start();
    gong.play();
    println(pred);
    playedGong = true;
    pose3= true;
    println("Finished");
  }

  //reset gong and play next instuction
  if (gong.isPlaying() == false && playedGong==true && pose1 == true && pose2 == true && pose3 == true) {
    playedGong= false;
    println("Reset");
    resetPoses();
  }
}



void playSound(int i) {
  if (i==0 && played == false) {
    if (file.isPlaying() == false && file2.isPlaying() == false && file3.isPlaying()== false&& file4.isPlaying()== false) {
      file.play();
      played = true;
    }
  }
  if (i == 1 && played2 == false) {
    if (file.isPlaying() == false && file2.isPlaying() == false && file3.isPlaying()== false&& file4.isPlaying()== false) {
      file2.play();
      played2 = true;
    }
  }
  if (i ==2&& played3 == false ) {
    if (file.isPlaying() == false && file2.isPlaying() == false && file3.isPlaying()== false&& file4.isPlaying()== false) {
      file3.play();
      played3 = true;
    }
  }
  if (i ==3&& played4 == false) {
    if (file.isPlaying() == false && file2.isPlaying() == false && file3.isPlaying()== false&& file4.isPlaying()== false) {
      file4.play();
      played4 = true;
    }
  }
}

void resetPoses() {
  played = true;
  played2 = false;
  played3 = false;
  played4 = false;
  playedGong= false;

  pose0= false;
  pose1= false;
  pose2 = false;
  pose3= false;
  return;
}
