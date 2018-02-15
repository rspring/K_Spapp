color colBackgroud = color(16);
color colHeader = color(32);
color colBorder = color(128);
color colText   = #0084CB;

// =======================================================================
public class RButton {
  float x, y, w, h;
  boolean enabled = true;
  boolean selected = false;
  boolean down = false;
  PImage icon;
  String label;
  String ID;
  String help;
  int durOn = 0;

  // ---------------------------------------------------------------------
  // Constructor
  RButton(float _x, float _y, float _w, float _h, String _label, String _ID) {
    x = _x; 
    y = _y; 
    w = _w; 
    h = _h;
    ID=_ID;
    icon = loadImage("btn_"+_ID+".png");
    while (icon.width == 0) delay(10);
    label = _label;
    help = _ID;
    enabled = false;
    selected = false;
  }

  RButton(float _x, float _y, float _w, float _h, String _label, String _ID, String _help) {
    x = _x; 
    y = _y; 
    w = _w; 
    h = _h;
    ID=_ID;
    icon = loadImage("btn_"+_ID+".png");
    while (icon.width == 0) delay(10);
    label = _label;
    help = _help;
    enabled = false;
    selected = false;
  }

  // ---------------------------------------------------------------------
  // Toggle enabled state
  public void set() {
    enabled = !enabled;
  }

  // ---------------------------------------------------------------------
  // Show the button
  public void show() {
    pushStyle();

    if (down) {                // light Gray when pressed
      fill(64);
      durOn++;
      println("duron", durOn);
    } else {
      durOn=0;
      fill(colHeader);
    }
    rect(x, y, w, h);

    if (selected) {              // blue accent and blue icon
      tint(colText);
      image(icon, x, y, h, h);
      fill(colText);
      rect(x, y, h/16.0, h);
    } else {
      tint(192);
      image(icon, x, y, h, h);
    }
    
    if ((durOn > 10) && (durOn < 20)) {
      fill(#2bcb65);
      rect(x, y, h/16.0, h*(durOn-10)/10);
    }

    popStyle();

    // reset value
    if (durOn == 20) {
      vibrate(20);
      if (parameters[mode] != null) {
        parameters[mode].reset();
        sld.val = parameters[mode].valueX;
        if (mode == iSpike) {
          spikes.clear();
        }
        fft.fftChanged = true;
      }
    }
  }

  // ---------------------------------------------------------------------
  // Check if mouse is over button
  public boolean hit() {
    boolean inside = false;
    if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h) {
      inside = true;
    } else {
      inside = false;
    }
    return inside;
  }
}

// =======================================================================
public class RLabel {
  float x, y, w, h;
  String text = "0 %";
  String unit = "%";
  int val;

  // ---------------------------------------------------------------------
  // Constructor
  RLabel(float _x, float _y, float _w, float _h) {
    x = _x; 
    y = _y; 
    w = _w; 
    h = _h;
  }

  // ---------------------------------------------------------------------
  // Set value
  public void set(int _value, String _unit) {
    val = _value;
    text = str(int(_value)) + " " + _unit;
  }

  // ---------------------------------------------------------------------
  // Show label
  public void show() {
    text = str(int(val)) + " " + unit;
    pushStyle();
    fill(colHeader);
    rect(x, y, w, h);
    fill(colText);
    myText(text, x, y + tS/10);
    popStyle();
  }
}

// =======================================================================
public class RSlider {
  int min = 0;
  int max = 100;
  int val = 100;
  float x, y, w, h;
  float p1, p2, t;
  int prevVal = -1; 

  // ---------------------------------------------------------------------
  // Constructor
  RSlider(float _x, float _y, float _w, float _h) {
    x = _x; 
    y = _y; 
    w = _w; 
    h = _h;
    p1 = h / 2.06; // padding
    p2 = h / 2.03; // padding
    t = h / 2; //thickness
  }

  // ---------------------------------------------------------------------
  // Set value of slider, check boundaries, return true if val was changed
  public boolean setValMouse(float _mouseX) {
    val = constrain(round(map(_mouseX, x+t, x+w-t, min, max)), min, max);
    if (val != prevVal) {
      prevVal = val;
      if ((val == min) || (val == max)) vibrate(15);
      lbl.set(val, "%");
      return true;
    } else {
      return false;
    }
  }

  // ---------------------------------------------------------------------
  // Set value of slider, check boundaries
  public void setVal(int _val) {
    val = constrain(_val, min, max);
    lbl.set(val, "%");
  }

  // ---------------------------------------------------------------------
  // Show slider
  public void show() {
    pushStyle();
    fill(colHeader);
    rect(x, y, w, h);
    fill(128);
    rect(x+p2, y+p2, w-p2-p2, h-p2-p2, p2, p2, p2, p2);
    fill(colText);
    rect(x+p1, y+p1, map(val, min, max, 0, w-p1-p1), h-p1-p1, p1, p1, p1, p1);
    ellipse(map(val, min, max, x+t, x+w-t), y+t, t*.7, t*0.7);
    popStyle();
  }

  // ---------------------------------------------------------------------
  // Test if mouse is over slider
  public boolean hit() {
    boolean inside = false;
    if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h) {
      inside = true;
    } else {
      inside = false;
    }
    return inside;
  }
}



// =======================================================================
// Draw text with shadow
void imageText(String _text, float _x, float _y) {
  final float blur = 1;
  pushStyle();
  fill(0);
  text(_text, _x-blur, _y-blur);
  text(_text, _x-blur, _y+blur);
  text(_text, _x+blur, _y-blur);
  text(_text, _x+blur, _y+blur);
  popStyle();
  text(_text, _x, _y);
}

// =======================================================================
// Draw text on with offset at location
void myText(String _text, float _x, float _y) {
  //text(_text, _x + tS/5, _y + tS/4);
  text(_text, _x, _y + tS/8);
}