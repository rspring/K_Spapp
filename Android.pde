import android.content.Intent;
import android.provider.MediaStore;
import android.graphics.Bitmap;
import android.net.Uri;
import android.graphics.BitmapFactory;
import android.content.ContentResolver;
import android.os.Bundle;
import android.os.Environment;
import android.content.Context;
import android.media.*;
import java.io.FileNotFoundException;
import android.provider.MediaStore.Images.Media;
import android.os.Vibrator;
import android.app.Activity;
import android.content.ActivityNotFoundException;

/*import android.app.Activity;
 import android.widget.FrameLayout;
 import android.webkit.WebView;
 import android.widget.RelativeLayout;
 import android.view.View;
 */

Bitmap bmpPick;
PImage imgRaw;
Vibrator v;

static final int REQUEST_IMAGE_GALLERY = 2;
static final int REQUEST_PHOTO = 1;
static final int RESULT_OK = -1;

void vibrate(int n) {
  Vibrator v = (Vibrator) getActivity().getSystemService(Context.VIBRATOR_SERVICE); 
  v.vibrate(n);
}

// =======================================================================
public void rateApp() {
  Uri uri = Uri.parse("market://details?id=" + getActivity().getPackageName());
  Intent goToMarket = new Intent(Intent.ACTION_VIEW, uri);
  goToMarket.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY |
    //Intent.FLAG_ACTIVITY_NEW_DOCUMENT |
    Intent.FLAG_ACTIVITY_MULTIPLE_TASK);
  try {
    startActivity(goToMarket);
  } 
  catch (ActivityNotFoundException e) {
    startActivity(new Intent(Intent.ACTION_VIEW, 
      Uri.parse("http://play.google.com/store/apps/details?id=" + getActivity().getPackageName())));
  }
}

// =======================================================================
public void takePhoto() {
  Intent camera = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
  startActivityForResult(camera, REQUEST_PHOTO);
}

// =======================================================================
public void pickImage() {
  Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.INTERNAL_CONTENT_URI);
  intent.setType("image/*");
  //intent.putExtra("crop", "true");
  intent.putExtra("scale", true);
  intent.putExtra("outputX", 256);
  intent.putExtra("outputY", 256);
  intent.putExtra("aspectX", 1);
  intent.putExtra("aspectY", 1);
  intent.putExtra("return-data", true);
  startActivityForResult(intent, REQUEST_IMAGE_GALLERY);
}

// =======================================================================
@Override
  public void onActivityResult(int requestCode, int resultCode, Intent data) {
  if (requestCode == REQUEST_PHOTO && resultCode == RESULT_OK) {
    bmpPick = (Bitmap)data.getExtras().get("data");
    imgRaw = new PImage(bmpPick);
    resizeImage();
  }

  if (requestCode == REQUEST_IMAGE_GALLERY && resultCode == RESULT_OK) {
    if (data != null) {
      try {
        Uri selectedImage = data.getData();
        InputStream imageStream = getActivity().getContentResolver().openInputStream(selectedImage);
        bmpPick = BitmapFactory.decodeStream(imageStream);
        imgRaw = new PImage(bmpPick);
        resizeImage();
      }
      catch (IOException e) {
        imgSelected = false;
      }
    }
  }
}

// =======================================================================
private void resizeImage() {
  //PImage imgTemp = new PImage();
  int w = imgRaw.width;
  int h = imgRaw.height;
  if (imgPick == null) {
    imgPick = new PImage();
    imgPick = createImage(256, 256, RGB);
  }
  if (w > h) {
    imgPick.copy(imgRaw, (w-h)/2, 0, h, h, 0, 0, 256, 256);
  } else {
    imgPick.copy(imgRaw, 0, (h-w)/2, w, w, 0, 0, 256, 256);
  }
  imgPick.filter(GRAY);
  imgSelected = true;
}