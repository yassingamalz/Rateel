package com.novavista.rateel;

import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Force text zoom to 100% to prevent system font scaling
        WebView webView = getBridge().getWebView();
        WebSettings settings = webView.getSettings();
        settings.setTextZoom(100);
    }
}