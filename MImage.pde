// =======================================================================
public class MImage {

  public PImage img;

  color[] lut = new color[4096];

  float panX = 0, panY = 0;
  float WW = 4096, WL = 2048, defWW, defWL;
  float min = 0, max = 4096;
  float zoom;
  float x, y, w, h;

  boolean changed = false;

  MImage (PImage _image, float _x, float _y, float _w, float _h) {
    img = _image;
    while (img.width == 0) delay(50);
    x = _x; 
    y = _y; 
    w = _w; 
    h = _h;
    size = img.width;
    zoom = _h;
  }

  MImage (String _filename, float _x, float _y, float _w, float _h) {
    img = requestImage(_filename);
    while (img.width == 0) delay(50);
    x = _x; 
    y = _y; 
    w = _w; 
    h = _h;
    size = img.width;
    zoom = _h;
  }

  MImage (int _size, float _x, float _y, float _w, float _h) {
    img = createImage(_size, _size, RGB);
    x = _x; 
    y = _y; 
    w = _w; 
    h = _h;
    size = _size;
    zoom = _h;
  }

  private void reset() {
    panX = 0; 
    panY = 0;
    zoom = h;
    if (w<h) zoom = w;
    WL = defWL;
    WW = defWW;
  }

  // ---------------------------------------------------------------------
  // Read image pixels from img to array
  private void readPixels(float[][] _array) {
    //println("  img.readPixels(float[][] _array)");
    img.loadPixels();
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        _array[x][y*2]   = green(img.pixels[x + y*size])*16;
        _array[x][y*2+1] = 0.0;
      }
    }
    img.updatePixels();
  }

  // ---------------------------------------------------------------------
  private void writeLut(float _ww, float _wl) {
    //println("  img.writeLut(float _ww, float _wl)");
    WW = _ww;
    WL = _wl;
    defWW = WW;
    defWL = WL;
    writeLut();
  }
  private void writeLut() {
    //println("  img.writeLut()");
    float ww = WW/16;
    float wl = WL/16;
    int c;
    for (int i = 0; i < 4095; i++) {
      c = int(map((float)i, 0, 4095, wl-ww/2, wl+ww/2));
      lut[i] = color(c, c, c);
    }
  }

  // ---------------------------------------------------------------------
  // write array to image pixels
  private void writePixels(float[][] _array, float _min, float _max) {
    //println("  img.writePixels(float[][] _array, float _min, float _max)");
    min = _min; 
    max = _max;
    writePixels(_array);
  }
  private void writePixels(float[][] _array) {
    //println("  img.writePixels(float[][] _array)");
    int c;
    img.loadPixels();
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        c = int(map(_array[x][y*2], min, max, 0, 4095));
        c = constrain(c, 0, 4095-16);
        img.pixels[x + y*size] = lut[c];
        if (_array[x][y*2+1] == 0.1) {
          img.pixels[x + y*size] = color(#164266);
        }
      }
    }
    img.updatePixels();
  }

  // ---------------------------------------------------------------------
  private void show() {
    //println("img.show()");
    float dX, dY, dS;
    pushStyle();
    clip(x, y, w, h);
    fill(colHeader);
    rect(x, y, w, h);

    if (w>h) {
      dS = zoom;
      dX = x + panX + (w-h)/2.0 + (h-zoom)/2;
      dY = y + panY + (h-zoom)/2;
    } else {
      dS = zoom;
      dX = x + panX + (w-zoom)/2;
      dY = y + panY + (h-w)/2.0 + (w-zoom)/2;
    }
    image(img, dX, dY, dS, dS);
    noClip();
    popStyle();
  }

  // ---------------------------------------------------------------------
  /*  void drawCurve() {
   pushStyle();
   clip(x, y, w, h);
   strokeWeight(1);
   stroke(colText);
   
   img.loadPixels();
   float x1, y1, x2, y2; 
   for (int i = 0; i < size-1; i++) {
   x1 = map(i, 0, size, x, x+w);
   x2 = map(i+1, 0, size, x, x+w);
   y1 = map(red(img.pixels[size*size/2+i]), 0, 255, y, y+h);
   y2 = map(red(img.pixels[size*size/2+i+1]), 0, 255, y, y+h);
   //println(x1, y1, x2, y2);
   line(x1, y1, x2, y2);
   }
   img.updatePixels();
   noClip();
   popStyle();
   }
   */
  void drawCurve() {
    pushStyle();
    clip(x, y, w, h);
    strokeWeight(1);
    stroke(colText);
    float x1, y1, x2, y2;
    int i2 = 0;

    for (int i = 0; i < size-1; i++) {
      if ( i < size/2 ) i2 = i + size/2; 
      else i2 = i - size/2;
      if (i2 < size) {
        //println(i, i2);
        x1 = map(i, 0, size, x, x+w);
        x2 = map(i+1, 0, size, x, x+w);
        if (i2 >= 256) i2 -= size;
        y1 = map(fft.midline[i2][0], min*10, max*10, y, y+h);
        i2++;
        if (i2 >= 256) i2 -= size;
        y2 = map(fft.midline[i2][0], min*10, max*10, y, y+h);
        line(x1, y1, x2, y2);
      }
    }
    
    //stroke(192,0,0);
    for (int i = 0; i < size-1; i++) {
      if ( i < size/2 ) i2 = i + size/2; 
      else i2 = i - size/2;
      if (i2 < size) {
        //println(i, i2);
        x1 = map(i, 0, size, x, x+w);
        x2 = map(i+1, 0, size, x, x+w);
        if (i2 >= 256) i2 -= size;
        y1 = map(abs(fft.midline[i2][0]), min*10, max*10, y, y+h);
        i2++;
        if (i2 >= 256) i2 -= size;
        y2 = map(abs(fft.midline[i2][0]), min*10, max*10, y, y+h);
        line(x1, y1, x2, y2);
      }
    }
    
    //stroke(192,0,0);
    for (int i = 0; i < size-1; i++) {
      if ( i < size/2 ) i2 = i + size/2; 
      else i2 = i - size/2;
      if (i2 < size) {
        //println(i, i2);
        x1 = map(i, 0, size, x, x+w);
        x2 = map(i+1, 0, size, x, x+w);
        if (i2 >= 256) i2 -= size;
        y1 = map(-abs(fft.midline[i2][0]), min*10, max*10, y, y+h);
        i2++;
        if (i2 >= 256) i2 -= size;
        y2 = map(-abs(fft.midline[i2][0]), min*10, max*10, y, y+h);
        line(x1, y1, x2, y2);
      }
    }

    noClip();
    popStyle();
  }

  public int getX(float _mouseX) {
    float dX, dS, posX;
    if (w>h) {
      dS = zoom;
      dX = x + panX + (w-h)/2.0 + (h-zoom)/2;
    } else {
      dS = zoom;
      dX = x + panX + (w-zoom)/2;
    }
    posX = map(_mouseX, dX, dX+dS, 0, 255);
    if ((posX > 0) && (posX < size)) {
      return int(posX);
    } else {
      return -1;
    }
  }
  public int getY(float _mouseY) {
    float dY, dS, posY;
    if (w>h) {
      dS = zoom;
      dY = y + panY + (h-zoom)/2;
    } else {
      dS = zoom;
      dY = y + panY + (h-w)/2.0 + (w-zoom)/2;
    }
    posY = map(_mouseY, dY, dY+dS, 0, 255);
    if ((posY > 0) && (posY < size)) {
      return int(posY);
    } else {
      return -1;
    }
  }
  // ---------------------------------------------------------------------
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