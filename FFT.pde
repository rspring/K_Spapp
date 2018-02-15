// =======================================================================
public class Mfft {
  int count = 0;
  int size;
  FloatFFT_2D fft_2D;      // The FFT object
  float[][] data;          // The K-Space
  float[][] dataInv;       // The K-Space after FFT
  float[][] dataKspace;    // The K-Space
  float[][] dataImage;     // The K-Space
  float[][] midline;

  float[] hanning;

  int[] motionRandom = new int[200];

  boolean fftChanged = true;      // if true run FFT
  boolean fftBusy = false;        // FFT busy
  boolean fftFinished = false;        // FFT busy

  // ---------------------------------------------------------------------
  //Constructor
  Mfft(int _size) {
    size = _size;
    fft_2D     = new FloatFFT_2D(size, size);
    data       = new float[size][2 * size];
    dataInv    = new float[size][2 * size];
    dataKspace = new float[size][2 * size];
    dataImage  = new float[size][2 * size];
    hanning    = new float[size];
    midline    = new float[size][10];

    int cutOff = int(size * 0.2);
    for (int i=0; i<cutOff; i++) {
      hanning[i] = 0;
    }
    for (int i=cutOff; i<size; i++) {
      hanning[i] = 1 - (0.5 * (1 + cos((PI * (i-cutOff)/(size-cutOff)))));
    }
    generateMotion();
  }

  // ---------------------------------------------------------------------
  // Initialize motion random array
  void generateMotion() {
    for (int n = 0; n < 200; n++) {
      int v = int(random(size));
      while ((v < size/2 - size*0.47) || (v > size/2 + size*0.47)) {
        v = int(random(size));
      }
      motionRandom[n] = v;
    }
  }

  // ---------------------------------------------------------------------
  // Add artificial noise
  void addNoise() {
    for (int y = 0; y < size; y++) {
      midline[y][0] = data[0][y*2];
    }
    //println("> Noise: ", parameters[iNoise].valueX);
    int noise = parameters[iNoise].valueX*5000;
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        data[x][y*2]   = data[x][y*2]   + random(noise) -noise/2;
        data[x][y*2+1] = data[x][y*2+1] + random(noise) -noise/2;
      }
    }
  }

  // ---------------------------------------------------------------------
  // Skip lines
  void skipLines() {
    int skip = parameters[iSkip].valueX;
    int x, y;
    if (skip > 1) {
      for (x = 0; x < size/2; x++) {
        if ((x % skip) > 0) {
          for (y = 0; y < size; y++) {
            data[x][y*2]   = 0;
            data[x][y*2+1] = 0;
          }
        }
      }
      for (x = size-1; x >= size/2; x=x-1) {
        if (((size-x) % skip) > 0) {
          for (y = 0; y < size; y++) {
            data[x][y*2]   = 0;
            data[x][y*2+1] = 0;
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------
  // Add spikes
  void addSpikes() {
    for (spike sp : spikes) {
      data[sp.y][sp.x*2] = -sp.v * parameters[iSpike].valueX;
    }
  }

  // ---------------------------------------------------------------------
  // Add artificial motion
  void addMotion() {
    //println("> Motion: ", parameters[iMotion].valueX);
    int motion = parameters[iMotion].valueX*2;
    int amount = 5;
    for (int n = 0; n < motion; n++) {
      int x = motionRandom[n];
      if (x < amount) x = amount;
      for (int y = 0; y < size; y++) {
        data[x-amount][y*2]   = data[x][y*2];
        data[x-amount][y*2+1] = data[x][y*2+1];
        data[x][y*2]   = 0;
        data[x][y*2+1] = 0.1;
      }
    }
  }

  // ---------------------------------------------------------------------
  // Apply K-Space scanPerc & shutters
  void applyShutter() {
    int perc     = int(parameters[iPerc].valueX * size/200.0);
    int halfscan = (100-parameters[iHalf].valueX) * size/200;
    float hann = parameters[iHann].valueX/100.0;
    int half = size/2;                        // half the image size
    int dist, distBorder, distPerc, distOuter;                               // distance from center
    int shutter   = (100-parameters[iShutOut].valueX) * size/141;      // outer shutter
    int shutterIn = parameters[iShutIn].valueX * size/141;    // center shutter
    int x2, y2;

    distBorder = min(shutter, perc);

    for (int x = 0; x < half; x++) {
      for (int y = 0; y < half; y++) {
        distOuter = int(dist(0, 0, x, y));
        //distPerc  = int(dist(0, y, x, y));
        //dist = min(distOuter, distPerc);
        if (x > halfscan) {
          x2 = size-x; 
          y2 = size-y;
          if ((x2<size-1) && (y2<size-1)) {
            data[x][y*2]   =  data[x2][y2*2]; //Re
            data[x][y*2+1] = -data[x2][y2*2+1]; //Im
          }
        }
        if (distOuter > shutter || distOuter < shutterIn || x > perc) { // || x > halfscan) {
          data[x][y*2]   = 0;
          data[x][y*2+1] = 0.1;
        } else {
          data[x][y*2] = data[x][y*2] * (1.0 - hann * hanning[int(map(x, 0, perc, 0, 255))]);
          data[x][y*2+1] = data[x][y*2+1] * (1.0 - hann * hanning[int(map(x, 0, perc, 0, 255))]);
          //data[x][y*2] = data[x][y*2] * (1.0 - hann * hanning[int(map(dist, 0, distBorder, 0, 255))]);
          //data[x][y*2+1] = data[x][y*2+1] * (1.0 - hann * hanning[int(map(dist, 0, distBorder, 0, 255))]);
        }
      }
    }
    for (int x = half; x < size; x++) {
      for (int y = 0; y < half; y++) {
        //dist = sqrt((size-x)*(size-x)+y*y);
        distOuter = int(dist(size-1, 0, x, y));
        if (distOuter > shutter || distOuter < shutterIn || (size-x) > perc) {
          data[x][y*2]   = 0;
          data[x][y*2+1] = 0.1;
        } else {
          data[x][y*2] = data[x][y*2] * (1.0 - hann * hanning[int(map(x, size, size-perc, 0, 255))]);
          data[x][y*2+1] = data[x][y*2+1] * (1.0 - hann * hanning[int(map(x, size, size-perc, 0, 255))]);
        }
      }
    }
    for (int x = 0; x < half; x++) {
      for (int y = half; y < size; y++) {
        //dist = sqrt(x*x+(size-y)*(size-y));
        distOuter = int(dist(0, size-1, x, y));
        if (x > halfscan) {
          x2 = size-x; 
          y2 = size-y;
          if ((x2<size-1) && (y2<size-1)) {
            data[x][y*2]   =  data[x2][y2*2]  ; //Re
            data[x][y*2+1] = -data[x2][y2*2+1]; //Im
          }
        }
        if (distOuter > shutter || distOuter < shutterIn || x > perc) { // || x > halfscan) {
          data[x][y*2]   = 0;    // Real
          data[x][y*2+1] = 0.1;  // Imaginary
        } else {
          data[x][y*2] = data[x][y*2] * (1.0 - hann * hanning[int(map(x, 0, perc, 0, 255))]);
          data[x][y*2+1] = data[x][y*2+1] * (1.0 - hann * hanning[int(map(x, 0, perc, 0, 255))]);
        }
      }
    }
    for (int x = half; x < size; x++) {
      for (int y = half; y < size; y++) {
        //dist = sqrt((size-x)*(size-x)+(size-y)*(size-y));
        distOuter = int(dist(size-1, size-1, x, y));
        if (distOuter > shutter || distOuter < shutterIn || (size-x) > perc) {
          data[x][y*2]   = 0;    // Real
          data[x][y*2+1] = 0.1;  // Imaginary
        } else {
          data[x][y*2] = data[x][y*2] * (1.0 - hann * hanning[int(map(x, size, size-perc, 0, 255))]);
          data[x][y*2+1] = data[x][y*2+1] * (1.0 - hann * hanning[int(map(x, size, size-perc, 0, 255))]);
        }
      }
    }
  }

  // ---------------------------------------------------------------------
  void copy2dataInv() {
    //println("  copy from data to dataInv");
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size*2; y++) {
        dataInv[x][y] = data[x][y];       // Real
      }
    }
  }

  // ---------------------------------------------------------------------
  public void copy2dataImage() {    // copy data
    //println("  copy from data to dataImage");
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size*2; y++) {
        dataImage[x][y] = data[x][y];     // Real
      }
    }
  }

  // ---------------------------------------------------------------------
  public void copy2dataKspace() {    // copy data
    //println("  copy from data to dataKspace");
    int x2, y2;
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        if ( x < size/2 ) x2 = x + size/2; 
        else x2 = x - size/2;
        if ( y < size/2 ) y2 = y + size/2; 
        else y2 = y - size/2;
        dataKspace[y][x*2]   = dataInv[x2][y2*2];
        dataKspace[y][x*2+1] = dataInv[x2][y2*2+1];
      }
    }
  }

  // ---------------------------------------------------------------------
  public void copy2dataKspaceOLD() {    // copy data
    //println("  copy from data to dataKspace");
    int x2, y2;
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size*2; y++) {
        if ( x < size/2 ) x2 = x + size/2; 
        else x2 = x - size/2;
        if ( y < size ) y2 = y + size; 
        else y2 = y - size;
        dataKspace[x][y] = dataInv[x2][y2];
      }
    }
  }
}

// =======================================================================
// Class spike
class spike {
  int x, y;
  float v;

  // Constructor
  spike(int tX, int tY, float tV) {
    x = tX;
    y = tY;
    v = tV;
  }
}

// =======================================================================
void reconstruct_thread() {
  fft.count++;
  int milliStart = millis();
  println("FFT number: ", fft.count);

  // Perform forward FFT to create K-space from image
  fft.fft_2D.complexForward(fft.data);

  // Apply changes to K-space
  milliStart = millis();
  fft.addNoise();
  fft.addSpikes();
  //fft.addMotion();
  fft.skipLines();
  fft.applyShutter();
  fft.addMotion();
  println("FFT: K-space changes took: ", millis()-milliStart, " ms");
  // Copy data from K-space to 
  fft.copy2dataInv();

  // Perform Inverse FFT
  fft.fft_2D.complexInverse(fft.data, true);


  imgDest.changed = true;
  imgKspace.changed = true;
  fft.fftFinished = true;
}