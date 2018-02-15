// =======================================================================
// Class parameter
class Parameter {
  int minX, maxX, defX;
  int minY, maxY, defY;
  int valueX;
  int valueY;
  float scale;

  // ---------------------------------------------------------------------
  // Constructor
  Parameter(int _MinX, int _MaxX, int _DefX, float tScale) {
    minX = _MinX;
    maxX = _MaxX;
    defX = _DefX;
    scale = tScale;
    valueX = _DefX;
  }

  // ---------------------------------------------------------------------
  // Increment value
  public void inc() {
    if (valueX < maxX) {
      valueX++;
    } else {
      valueX = minX;
    }
  }

  // ---------------------------------------------------------------------
  // Set value and check range
  void set(float _valueX) {
    valueX = int(_valueX * scale);
    if (valueX < minX) valueX = minX;
    if (valueX > maxX) valueX = maxX;
  }
  void set(float _valueX, float _valueY) {
    valueX = int(_valueX * scale);
    if (valueX < minX) valueX = minX;
    if (valueX > maxX) valueX = maxX;
    valueY = int(_valueY * scale);
    if (valueY < minY) valueY = minY;
    if (valueY > maxY) valueY = maxY;
  }

  // ---------------------------------------------------------------------
  // Reset value to default value
  void reset() {
    valueX = defX;
    valueY = defY;
  }
}

// =======================================================================
// Initialize parameters
Parameter[] parameters;
RButton[] buttons;
final int iExit  = 0;
final int iMenu  = 1;
final int iInfo  = 2;
final int iReset = 3;
final int iHelp  = 4;
final int iImage = 5;
final int iPick = 6;
final int iCam = 7;
final int iLike = 8;
final int iPlay = 9;

final int iWW    = 10;
final int iWL    = 11;
final int iZoom  = 13;
final int iPan  = 14;
final int iSettings  = 16;

final int iPerc  = 20;
final int iHalf  = 21;
final int iShutIn = 22;
final int iShutOut = 23;
final int iNoise = 24;
final int iTreshold = 25;
final int iMotion = 26;
final int iSpike = 27;
final int iWWKspace = 28;
final int iHann = 30;
final int iView = 31;
final int iSkip = 32;

void initParameters() {
  parameters = new Parameter[35];
  parameters[iPerc]     =  new Parameter(0, 100, 100, 0.1);
  parameters[iHalf]     =  new Parameter(0, 100, 0, 0.1);
  parameters[iShutIn]   =  new Parameter(0, 100, 0, 0.1);
  parameters[iShutOut]  =  new Parameter(0, 100, 0, 0.1);
  parameters[iNoise]    =  new Parameter(0, 100, 0, 0.1);
  parameters[iMotion]   =  new Parameter(0, 100, 0, 0.1);
  parameters[iSkip]     =  new Parameter(1, 10, 1, 0.1);

  parameters[iTreshold] =  new Parameter(0, 100, 25, 0.1);
  parameters[iImage]    =  new Parameter(0, 1, 0, 10);
  parameters[iSpike]    =  new Parameter(0, 100, 25, 1);
  parameters[iHann]     =  new Parameter(0, 100, 0, 0.1);
  parameters[iView]     =  new Parameter(0, 100, 0, 0.1);

  buttons = new RButton[35];
  //buttons[iMenu]    = new RButton(0, 0, tS, tS, "Menu", "menu") ;
  buttons[iHelp]    = new RButton(0, 0, tS, tS, "Menu", "help") ;
  buttons[iExit]    = new RButton(width-tS, 0, tS, tS, "Exit", "close") ;

  buttons[iWW]      = new RButton(0, 1*tS, tS, tS, "Window width & level", "wwl", "general") ;
  buttons[iZoom]    = new RButton(0, 2*tS, tS, tS, "Zoom", "zoom", "general") ;
  buttons[iPan]     = new RButton(0, 3*tS, tS, tS, "Pan", "pan", "general") ;
  buttons[iSettings]= new RButton(0, 4*tS, tS, tS, "Settings", "settings", "general") ;

  buttons[iCam]     = new RButton(0, height-5*tS, tS, tS, "Take photo", "camera", "import") ;
  buttons[iPick]    = new RButton(0, height-4*tS, tS, tS, "Select from gallery", "gallery", "import") ;
  buttons[iImage]   = new RButton(0, height-3*tS, tS, tS, "Select image", "image", "import") ;
  buttons[iReset]   = new RButton(0, height-2*tS, tS, tS, "Reset", "reset") ;
  buttons[iPlay]    = new RButton(0, height-1*tS, tS, tS, "Play", "play") ;

  buttons[iPerc]    = new RButton(width-tS, 1*tS, tS, tS, "Scan percentage", "perc") ;
  buttons[iHalf]    = new RButton(width-tS, 2*tS, tS, tS, "Half scan", "half") ;
  buttons[iShutOut] = new RButton(width-tS, 3*tS, tS, tS, "K-space shutter", "outer") ;
  buttons[iShutIn]  = new RButton(width-tS, 4*tS, tS, tS, "Inner shutter", "inner") ;
  buttons[iHann]    = new RButton(width-tS, 5*tS, tS, tS, "Hanning filter", "hanning") ;
  buttons[iNoise]   = new RButton(width-tS, 6*tS, tS, tS, "Noise", "noise") ;
  buttons[iMotion]  = new RButton(width-tS, 7*tS, tS, tS, "Motion", "motion") ;
  buttons[iSpike ]  = new RButton(width-tS, 8*tS, tS, tS, "Spikes", "spike") ;
  buttons[iSkip  ]  = new RButton(width-tS, 9*tS, tS, tS, "Skip K-spacelines", "skip") ;

  buttons[iLike]    = new RButton(width-tS, height-2*tS, tS, tS, "Menu", "thumb") ;

  buttons[iWW].selected = true;
  buttons[iPerc].selected = true;
  prevViewMode = iWW;
  prevKspaceMode = iPerc;
}