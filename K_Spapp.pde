import org.jtransforms.fft.FloatFFT_2D;

// Define images
MImage imgSource;
MImage imgDest;
MImage imgKspace;

// Define FFT module
Mfft fft;

// Spike array
ArrayList<spike> spikes = new ArrayList<spike>();

ArrayList<PImage> images = new ArrayList<PImage>();
String imageFiles[] = {"brain-1", "brain-2", "brain-3", "ankle-1", "ankle-2", 
  "knee-1", "c-spine-1", "c-spine-2", "l-spine-1", "l-spine-2", 
  "homer", "fig01", "fig02"};
int curImage = 0;

int mode = 10, modeView = 10, modeKspace = 20;
int prevMode, prevKspaceMode, prevViewMode;
boolean inDrag = false;
boolean sldDown = false;
boolean kspaceDown = false;
boolean destDown = false;
boolean doExit = false;
int size = 256;
int X=0, Y=0;
float tS;
float downX, downY, downValX, downValY, downPx, downPy, zoomX, zoomY;

// UI
PFont myFont, myFontXL, myFontXS;
RSlider sld;
RLabel lbl;

boolean setup = true;

// Image gallery
boolean imgSelected = false;
PImage imgPick, imgCam;

// =======================================================================
void settings() {
  //size(displayWidth, displayHeight, P3D);
  fullScreen(P3D);
  //size(600, 960, P3D);
  //size(400,  640, P3D);
  //size(1600, 900, P3D);
  //size(1080, 1920, P3D);
}

// =======================================================================
void setup() {
  //orientation(PORTRAIT);
  background(0);

  if (width>height) {
    tS = width/16.0;
  } else {
    // tS = 1920/16 = 120 Font = 120/2 = 60px
    tS = height/16.0;
  }

  textAlign(LEFT, TOP);
  fft = new Mfft(size);

  //gesture = new KetaiGesture(this);

  myFont = createFont("DejaVuSans-ExtraLight.ttf", int(tS/3), true);
  myFontXL = createFont("DejaVuSans-ExtraLight.ttf", int(tS)/2, true);
  myFontXS = createFont("DejaVuSans-ExtraLight.ttf", int(tS)/4, true);
  textFont(myFont);
  //textFont(myFont, int(tS/3));

  images = new ArrayList<PImage>();
  for (int i = 0; i < imageFiles.length; i++) {
    PImage img = requestImage(imageFiles[i]+".png");
    images.add(img);
  }
  while (images.get(0).width == 0 ) delay(10);

  imgSource =  new MImage(images.get(0), 9 * tS, 1 * tS, 6 * tS, 7 * tS);
  imgDest   =  new MImage(256, tS, tS+(height-tS*2)/2, width -2*tS, (height-tS*2)/2);
  imgKspace =  new MImage(256, tS, tS, width -2*tS, (height-tS*2)/2);
  if (width>height) {
    imgDest.x = tS;
    imgDest.y = tS;
    imgDest.w = (width-2*tS)/2;
    imgDest.h = height-tS*2;
    imgDest.zoom = imgDest.w;
    imgKspace.x = width/2;
    imgKspace.y = tS;
    imgKspace.w = (width-2*tS)/2;
    imgKspace.h = height-tS*2;
    imgKspace.zoom = imgKspace.w;
  }
  while (imgSource == null || imgDest == null || imgKspace == null) delay(10);

  initParameters();
  //initAndroid();
  //initHelp();

  sld = new RSlider(tS, height-tS, width-3*tS, tS);
  lbl = new RLabel(width-2*tS, height-tS, 2*tS, tS);

  imgSource.readPixels(fft.data);         // Store pixels from imgSource in data
  imgDest.writeLut(4096, 2048);
  imgDest.changed = true;
  imgKspace.writeLut(4096, 1024);
  imgKspace.changed = true;

  showHelp(false, "");
}

// =======================================================================
void draw() {
  noStroke();
  fill(colBackgroud);
  rect(0, 0, width, height);

  if (doExit) {
    exit();
  }

  // Check if image is loaded from gallery
  if (imgSelected) {
    imgSelected = false;
    if (imgPick != null) {
      imgSource.img = imgPick;
      fft.fftChanged = true;
    }
  }

  // Check if K-Space was changed
  if (fft.fftChanged) {
    if (!fft.fftBusy) {
      fft.fftChanged = false;
      fft.fftBusy = true;
      imgSource.readPixels(fft.data);
      //reconstruct_thread();
      thread("reconstruct_thread");
    }
  }

  // Check if FFT is finished
  if (fft.fftFinished) {
    fft.fftFinished = false;
    fft.fftBusy = false;
    fft.copy2dataImage();
    fft.copy2dataKspace();
  }

  if (imgDest.changed) {
    imgDest.changed = false;
    imgDest.writeLut();
    imgDest.writePixels(fft.dataImage);
  }

  if (imgKspace.changed) {
    imgKspace.changed = false;
    imgKspace.writeLut();
    imgKspace.writePixels(fft.dataKspace, 500000, -500000);
  }

  drawUI();
}

// =======================================================================
void drawUI() {
  // Show images
  imgDest.show();
  imgKspace.show();

  // Show curve
  //imgKspace.drawCurve();

  // Show button panels
  drawSidebar();
  drawHeader();
  drawFooter();
  lbl.show();
  sld.show();

  // Show buttons
  for (RButton btn : buttons) {
    if (btn != null) btn.show();
  }
  drawShadows();
}


// =======================================================================
void drawHeader() {
  fill(colHeader);
  rect(0, 0, width, tS);
  textAlign(CENTER, TOP);
  fill(176);
  myText("K-Spapp", width/2, 0);
  fill(colText);
  myText(buttons[modeKspace].label, width/2, tS/2);
}

void drawFooter() {
  fill(colHeader);
  rect(0, height-tS, width, tS);
  textAlign(LEFT, TOP);
  fill(200);
  //imageText(str(int(frameRate)) + " fps", tS, tS);
}

void drawSidebar() {
  fill(colHeader);
  rect(0, tS, tS, height-2*tS);
  rect(width-tS, tS, tS, height-2*tS);
}

void drawShadows() {
  //stroke(0);
  line(0, tS, width, tS);
  line(0, height-tS, width, height-tS);
  line(tS, tS, tS, height-tS);
  line(width-tS, tS, width-tS, height-tS);
  int shadowWidth = 1;
  for (int i = 0; i<shadowWidth; i++) {
    stroke(0, map(i, 0, shadowWidth, 127, 0));
    line(0, tS+i, width, tS+i);
    line(0, height-tS-i, width, height-tS-i);
    line(tS+i, tS, tS+i, height-tS);
    line(width-tS-i, tS, width-tS-i, height-tS);
  }
}



// =======================================================================
void mousePressed() {
  downX = mouseX;
  downY = mouseY;

  // Test if a button was pressed
  for (int i = 0; i < 35; i++) {
    if (buttons[i] != null) {
      if (buttons[i].hit()) {
        mode = i;
        buttons[i].down = true;
      }
    }
  }

  // Test if slider was hit
  if (sld.hit()) {
    sldDown = true;
    sld.setValMouse(mouseX);
    parameters[modeKspace].valueX = sld.val;
    fft.fftChanged = true;
    //println("mousePressed > modeKspace: ", modeKspace, " sld.val: ",sld.val, parameters[modeKspace].valueX);
  }

  // drag appeared in window
  if (imgDest.hit()) {
    destDown = true;
    switch (modeView) {
    case iWW:
      downValX = mouseX*10 + imgDest.WW;
      downValY = mouseY*10 - imgDest.WL;
      break;
    case iZoom:
      downValX = mouseX - imgDest.zoom;
      downValY = mouseY;
      break;
    case iPan:
      downValX = mouseX - imgDest.panX;
      downValY = mouseY - imgDest.panY;
      break;
    case iSettings:
      downValX = mouseX*0.1 - sld.val;
      downValY = mouseY*0.1;
      println("mouseDown: ", mouseX, downValX, sld.val);
      break;
    }
  }

  if (imgKspace.hit()) {
    kspaceDown = true;
    switch (modeView) {
    case iWW:
      downValX = mouseX*10 + imgKspace.WW;
      downValY = mouseY*10 - imgKspace.WL;
      break;
    case iZoom:
      downValX = mouseX - imgKspace.zoom;
      downValY = mouseY;
      break;
    case iPan:
      downValX = mouseX - imgKspace.panX;
      downValY = mouseY - imgKspace.panY;
      break;
    case iSettings:
      downValX = mouseX*0.1 - sld.val;
      downValY = mouseY*0.1;
      break;
    }
  }
}


void mouseReleased() {
  // End of push or drag action
  sldDown = false;
  destDown = false;
  kspaceDown = false;
  for (int i = 0; i < 35; i++) {
    if (buttons[i] != null) {
      buttons[i].down = false;
    }
  }

  // Only change mode when not dragged
  if (!inDrag) {
    //vibrate(12);

    if (mode != prevMode) {
      // a Viewing button is pressed
      if ((mode >= 10) && (mode < 20)) {
        // a Viewing button is pressed
        buttons[prevViewMode].selected = false;
        modeView = mode;
        buttons[modeView].selected = true;
        prevViewMode = mode;
        prevMode = mode;
      }
      if (mode >= 20) {
        // a K-space button is pressed
        buttons[prevKspaceMode].selected = false;
        modeKspace = mode;
        buttons[modeKspace].selected = true;
        prevKspaceMode = mode;

        sld.val  = parameters[modeKspace].valueX;
        sld.max = parameters[modeKspace].maxX;
        sld.min = parameters[modeKspace].minX;
        lbl.val  = sld.val;
        prevMode = mode;
      }
      // update help page
      if (buttons[iHelp].selected) {
        showHelp(buttons[iHelp].selected, buttons[mode].help);
      }
    }

    switch (mode) {
    case iExit:
      doExit = true;
      break;
    case iHelp:
      buttons[iHelp].selected = !buttons[iHelp].selected;
      showHelp(buttons[iHelp].selected, buttons[prevMode].help);
      mode = prevMode;
      break;
    case iImage:
      if (curImage < images.size()-1) {
        curImage++;
      } else {
        curImage = 0;
      }
      imgSource.img = images.get(curImage);
      mode = prevMode;
      fft.fftChanged = true;
      break;
    case iPick:
      if (!buttons[iHelp].selected) {
        mode = prevMode;
        pickImage();
      } else {
        showHelp(buttons[iHelp].selected, buttons[iPick].help);
      }
      break;
    case iLike:
      mode = prevMode;
      rateApp();
      break;
    case iCam:
      if (!buttons[iHelp].selected) {
        mode = prevMode;
        takePhoto();
      } else {
        showHelp(buttons[iHelp].selected, buttons[iCam].help);
      }
      break;
    case iReset:
      vibrate(20);
      for (int i=0; i<35; i++) {
        if (parameters[i] != null) {
          parameters[i].valueX = parameters[i].defX;
          parameters[i].valueY = parameters[i].defY;
        }
      }
      spikes.clear();
      mode = prevMode;
      imgDest.reset();
      imgKspace.reset();
      fft.fftChanged = true;
      imgDest.changed = true;
      imgKspace.changed = true;
      sld.setVal(parameters[modeKspace].valueX);
      break;
    }
  }

  // Only add spikes when mouse was not moved
  if ((modeKspace == iSpike) && (!inDrag)) {
    int x, y, halfSize;
    halfSize = size/2;
    x = imgKspace.getX(mouseX);
    y = imgKspace.getY(mouseY);
    if ((x >= 0) && (y>=0)) {
      println("Spike added at: ", x, y);
      if ((x > 0) && (x < size-1) && (y > 0) && (y < size-1)) {
        if (x >= halfSize) { 
          x -= halfSize;
        } else { 
          x += halfSize;
        }
        if (y >= halfSize) { 
          y -= halfSize;
        } else { 
          y += halfSize;
        }
        spikes.add(new spike(x, y, 2000000));
        fft.fftChanged = true;
      }
    }
  }   

  inDrag = false;
}

void mouseDragged() {
  if (dist(mouseX, mouseY, downX, downY) > 20) {
    inDrag = true;
    buttons[mode].down = false;
  }

  if (sldDown) {
    //int prevValue = parameters[modeKspace].valueX;
    if (sld.setValMouse(mouseX)) {
      parameters[modeKspace].valueX = sld.val;
      fft.fftChanged = true;
    }
    //println("mouseDragged > modeKspace: ", modeKspace, " sld.val: ",sld.val, parameters[modeKspace].valueX);
  }

  if (destDown) {
    switch (modeView) {
    case iWW:
      imgDest.WW = -mouseX*10 + downValX;
      imgDest.WL = mouseY*10 - downValY;
      imgDest.changed = true;
      break;
    case iZoom:
      imgDest.zoom = mouseX - downValX + mouseY - downValY;
      imgDest.changed = true;
      break;
    case iPan:
      imgDest.panX = mouseX - downValX;
      imgDest.panY = mouseY - downValY;
      imgDest.changed = true;
      break;
    case iSettings:
      sld.setVal(int(mouseX*0.1 - downValX + mouseY*0.1 - downValY));
      parameters[modeKspace].valueX = sld.val;
      fft.fftChanged = true;
      break;
    }
  }

  if (kspaceDown) {
    switch (modeView) {
    case iWW:
      imgKspace.WW = -mouseX*10 + downValX;
      imgKspace.WL = mouseY*10 - downValY;
      imgKspace.changed = true;
      break;
    case iZoom:
      imgKspace.zoom = mouseX - downValX + mouseY - downValY;
      imgKspace.changed = true;
      break;
    case iPan:
      imgKspace.panX = mouseX - downValX;
      imgKspace.panY = mouseY - downValY;
      imgKspace.changed = true;
      break;
    case iSettings:
      sld.setVal(int(mouseX*0.1 - downValX + mouseY*0.1 - downValY));
      parameters[modeKspace].valueX = sld.val;
      fft.fftChanged = true;
      break;
    }
  }
}