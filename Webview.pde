import android.app.Activity;
import android.content.Context;
import android.widget.FrameLayout;
import android.view.ViewParent;
import android.widget.RelativeLayout;
import android.text.Editable;
import android.graphics.Color;
import android.widget.Toast;
import android.os.Looper;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.view.ViewGroup;

import   android.webkit.WebView;
import   android.webkit.WebViewClient;

Activity act;
FrameLayout fl;

WebView webview; 
WebViewClient wbc;

@Override
public void onStart() {
  super.onStart();
  if (width > height) {
    tS = width/16.0;
  } else {
    tS = height/16.0;
  }
  int x = int(tS);
  int y = int(tS);
  int w = int(width - 2*tS);
  int h = int(height - 2*tS);

  super.onStart();
  act = this.getActivity();
  wbc = new WebViewClient();

  webview = new WebView(act);
  webview.setVisibility(View.GONE);
  webview.setLayoutParams(new RelativeLayout.LayoutParams( w, h ));
  webview.setX(x);
  webview.setY(y);
  webview.setWebViewClient(wbc);
  webview.getSettings().setJavaScriptEnabled(true);
  webview.loadUrl("file:///android_asset/html/help.html");

  fl = (FrameLayout)act.findViewById(0x1000);
  fl.addView(webview);
}

@Override
public void onStop() {
  super.onStop();
  webview.setVisibility(View.GONE);
}

public void showHelp(final boolean _value, final String _topic ) {
  println("showHelp(): ", _value);
  act.runOnUiThread(new Runnable() {
    public void run() {
      if (_value) {
        webview.loadUrl("file:///android_asset/html/help.html#"+_topic);
        webview.setVisibility(View.VISIBLE);
      } else {
        webview.setVisibility(View.GONE);
      }
    }
  }
  );
}