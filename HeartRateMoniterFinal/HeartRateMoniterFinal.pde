/**
 * <p>Ketai Sensor Library for Android: http://KetaiProject.org</p>
 *
 * <p>Ketai Camera Features:
 * <ul>
 * <li>Interface for built-in camera</li>
 * <li>TODO: fix HACK of camera registration that currently exceptions in setup() at the moment.</li>
 * </ul>
 * <p>Updated: 2012-10-21 Daniel Sauter/j.duran</p>
 */

import ketai.camera.*;

KetaiCamera cam;

int netBrightness, dataLength, heartBeatCount;

float dataPoint1, dataPoint2, sum, divideBy, newMean, totalMean, standardDev, slope, lastSlope, mappedMean, heartBeat;
boolean countAvailible;
int[] heartRateRecording;
int startMillis, numHeartRatesRecorded = 50, heartRateTotal;
float[] aData, dataMeans;

void setup() {
  startMillis = 0;
  heartBeat = 0;
  fullScreen();
  orientation(PORTRAIT);
  imageMode(CENTER);
  textSize(45);
  dataLength = 100;
  heartBeatCount = 0;
    aData = new float[dataLength];
    dataMeans = new float[dataLength];
  for (int i = 0; i < dataLength; i = i+1) {
    aData[i] = 0;
    dataMeans[i] = 0;
  }
  countAvailible = true;
  heartRateRecording = new int[numHeartRatesRecorded];
  
  for (int i = 0; i < numHeartRatesRecorded; i = i+1) {
    heartRateRecording[i] = 0;
  }
}

void draw() {
  
  ///MEAN LINE---------------------------------------------------
  //discussed with Marisa Lu
  float sum=0;
  float divideBy=0;
  for(int i=dataLength-50;i<dataLength;i++){
    sum +=aData[i]; 
    divideBy+=1;
  }
  float newMean = sum/divideBy;
  stroke(100,255,255);
  //-----------------------------------------------------------------

  ///CAMERA & SPLASH SCREEN---------------------------------------------------
  //taken from ketai library examples  
  if(cam != null && cam.isStarted()){
    image(cam, width/2, height/2, width, height);
    cam.loadPixels();
    netBrightness = 0;
    //gets the brightness of each frame
    for(int i = 0; i < cam.pixels.length; i = i + 20){
      netBrightness += red(cam.pixels[i]) + blue(cam.pixels[i]) + green(cam.pixels[i]);
    }
  }else{
    background(128);
    textSize(40);
    textAlign(CENTER);
    text("Place finger on camera and touch screen to activate", width/2, height/2 - 50);
    }
   //-----------------------------------------------------------------
    
  ///DATA ANALYSIS & VISUALIZATION--------------------------------------------------- 
  //updates & draws the array of data
  for (int i = 0; i < dataLength-1; i = i+1){
    aData[i] = aData[i + 1];
  }
    aData[dataLength - 1] = netBrightness;
    
 for (int i = 1; i < dataLength - 1; i = i+1) {
    stroke(255);

      dataPoint1 = map(aData[i], 50, 4000000, -1000, 4000);
      dataPoint2 = map(aData[i+1], 50, 4000000, -1000, 4000);
      mappedMean = map(newMean, 50, 4000000, -1000, 4000);
      slope = aData[i+1] - aData[i];
      lastSlope = aData[i] - aData[i - 1];

      line(i * (1100/dataLength), (dataPoint1 - mappedMean) + height/2, (i+1) * (1100/dataLength), (dataPoint2 - mappedMean) + height/2);
      line(0, height/2, width, height/2);
    if(aData[i] - newMean < 0){
      countAvailible = true;
    }

    //calculates standard deviation / discussed Marisa Lu  
    dataMeans[i] = abs(aData[i] - newMean);
    
    for (int j = 1; j < dataLength - 1; j = j+1) {
      totalMean += dataMeans[i];
    }
  
    standardDev = sqrt(totalMean/(dataLength-2));
    
    //gets time difference between heart beats
    if(((slope >= 0 && lastSlope <= 0) || (slope <= 0 && lastSlope >= 0)) 
        && (aData[i] - newMean > standardDev*.05) && (countAvailible == true)){
      print("HI");
      fill(0, 255, 0);
      stroke(255, 255, 255, 0);
      ellipse(i * (1100/dataLength), (dataPoint1 - mappedMean) + height/2, 10, 10);
      countAvailible = false;
      if(i == dataLength- 2){
        
        heartBeatCount = heartBeatCount + 1;
        for(int j = 1; j < numHeartRatesRecorded - 1; j++){
          heartRateRecording[j] = heartRateRecording[j + 1];
        }
        heartRateRecording[numHeartRatesRecorded-1] = millis() - startMillis;
        startMillis = millis();
        
      }
    }
   }
   
   //computes heart rate
   heartRateTotal = 0;
   for(int i = 0; i < numHeartRatesRecorded; i ++){
     heartRateTotal += heartRateRecording[i];
   }
   heartBeat =60000/((heartRateTotal/numHeartRatesRecorded)+ 1);

  //draws heartRate
  fill(255);
  textSize(100);
  textAlign(CENTER);
  if(heartBeatCount > 20){
      text("BPM: "+heartBeat,width/2,380); 
  }else{
      text("BPM: "+heartBeat,width/2,380); 
      text("Waiting...",width/2,480); 
  }
  print(heartBeatCount);
  
}
///-------------------------------------------------------------------

///CAMERA INFO---------------------------------------------------
//taken from ketai library examples 
void onCameraPreviewEvent()
{
  cam.read();
}

// start/stop camera preview by tapping the screen
void mousePressed()
{
  //HACK: Instantiate camera once we are in the sketch itself
  if(cam == null)
      cam = new KetaiCamera(this, 640, 480, 24);
      
  if (cam.isStarted())
  {
    cam.stop();
  }
  else
    cam.start();
}
void keyPressed() {
  if(cam == null)
    return;
    
  if (key == CODED) {
    if (keyCode == MENU) {
      if (cam.isFlashEnabled())
        cam.disableFlash();
      else
        cam.enableFlash();
    }
  }
}
//-----------------------------------------------------------------