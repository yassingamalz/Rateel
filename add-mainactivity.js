// add-mainactivity.js
const fs = require('fs');
const path = require('path');

// Define path to MainActivity.java
const mainActivityPath = path.join(
  process.cwd(),
  'android',
  'app',
  'src',
  'main',
  'java',
  'com',
  'novavista',
  'rateel',
  'MainActivity.java'
);

// Create directory structure if it doesn't exist
const dirPath = path.dirname(mainActivityPath);
if (!fs.existsSync(dirPath)) {
  fs.mkdirSync(dirPath, { recursive: true });
}

// MainActivity.java content - this is the key fix for Android font scaling
const mainActivityContent = `package com.novavista.rateel;

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
}`;

// Write the file
fs.writeFileSync(mainActivityPath, mainActivityContent);

console.log(`MainActivity.java created at ${mainActivityPath}`);