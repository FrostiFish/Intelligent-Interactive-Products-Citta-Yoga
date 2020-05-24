//*********************************************
// Example Code for Interactive Intelligent Products
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

import papaya.*;
import processing.serial.*;
Serial port; 

int sensorNum = 3; 
int streamSize = 500;
int[] rawData = new int[sensorNum];
float[][] sensorHist = new float[sensorNum][streamSize]; //history data to show



float[] modeArray = new float[streamSize]; //To show activated or not

boolean b_sampling = false; //flag to keep data collection non-preemptive
int sampleCnt = 0; //counter of samples

//Statistical Features
float[] windowM = new float[sensorNum]; //mean
float[] windowSD = new float[sensorNum]; //standard deviation

//Save
Table csvData;
boolean b_saveCSV = false;
String dataSetName = "A012GestTest2"; 
String[] attrNames = new String[]{ "x", "y", "z", "label"};
boolean[] attrIsNominal = new boolean[]{false, false, false, true};
int labelIndex = 0;

void setup() {
  size(500, 500, P2D);
  initSerial();
  initCSV();
}

void draw() {
  background(255);

  for (int c = 0; c < sensorNum; c++) {
    lineGraph(sensorHist[c], 0, 500, c*width/3, 0, width/3, height/3, 0); //draw sensor stream

    //barGraph (modeArray, c*width/3, height/3, width/3, height/3);
    //lineGraph(windowArray[c], 0, 1023, c*width/3, 2*height/3, width/3, height/3, 3); //history of window
  }

  showInfo("Current Label: "+getCharFromInteger(labelIndex), 20, 20);
  showInfo("Num of Data: "+csvData.getRowCount(), 20, 40);
  showInfo("[X]:del/[C]:clear/[S]:save", 20, 60);
  showInfo("[/]:label+", 20, 80);

  if (mousePressed && (frameCount%6==0)) b_sampling = true;
  else b_sampling = false;

  if (b_sampling == true) {
    appendArrayTail(modeArray, labelIndex); //the class is null without mouse pressed.
    TableRow newRow = csvData.addRow(); 

    newRow.setFloat("x", rawData[0]);
    newRow.setFloat("y", rawData[1]);
    newRow.setFloat("z", rawData[2]);
    newRow.setString("label", getCharFromInteger(labelIndex));

    println(csvData.getRowCount());
    b_sampling = false;
  } else {
    appendArrayTail(modeArray, -1); //the class is null without mouse pressed.
  }

  if (b_saveCSV) {
    saveCSV(dataSetName, csvData);
    saveARFF(dataSetName, csvData);
    b_saveCSV = false;
  }
}


void keyPressed() {
  if (key == 'C' || key == 'c') {
    csvData.clearRows();
    println(csvData.getRowCount());
  }
  if (key == 'X' || key == 'x') {
    csvData.removeRow(csvData.getRowCount()-1);
  }
  if (key == 'S' || key == 's') {
    b_saveCSV = true;
  }
  if (key == '/') {
    ++labelIndex;
    labelIndex %= 10;
  }
  if (key == '0') {
    labelIndex = 0;
  }
}


float diff = 0;
void serialEvent(Serial port) {   
  String inData = port.readStringUntil('\n');  // read the serial string until seeing a carriage return
  if (inData.charAt(0) == 'A') {
    rawData[0] = int(trim(inData.substring(1)));
    appendArrayTail( sensorHist[0], rawData[0]); //store the data to history (for visualization)
  }
  if (inData.charAt(0) == 'B') {
    rawData[1] = int(trim(inData.substring(1)));
    appendArrayTail(sensorHist[1], rawData[1]); //store the data to history (for visualization)
  }
  if (inData.charAt(0) == 'C') {
    rawData[2] = int(trim(inData.substring(1)));

    appendArrayTail(sensorHist[2], rawData[2]); //store the data to history (for visualization)
  }
}

float[] appendArrayTail (float[] _array, float _val) {
  float[] array = _array;
  float[] tempArray = new float[_array.length-1];
  arrayCopy(array, 1, tempArray, 0, tempArray.length);
  array[tempArray.length] = _val;
  arrayCopy(tempArray, 0, array, 0, tempArray.length);
  return array;
}

////Append a value to a float[] array.
//float[] appendArray (float[] _array, float _val) {
//  float[] array = _array;
//  float[] tempArray = new float[_array.length-1];
//  arrayCopy(array, tempArray, tempArray.length);
//  array[0] = _val;
//  arrayCopy(tempArray, 0, array, 1, tempArray.length);
//  return array;
//}

void initSerial() {
  //Initiate the serial port
  for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);
  String portName = Serial.list()[Serial.list().length-1];//MAC: check the printed list
  //String portName = Serial.list()[9];//WINDOWS: check the printed list
  port = new Serial(this, portName, 115200);
  port.bufferUntil('\n'); // arduino ends each data packet with a carriage return 
  port.clear();           // flush the Serial buffer
}
