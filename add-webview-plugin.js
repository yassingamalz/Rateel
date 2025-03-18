// add-webview-plugin.js
const fs = require('fs');
const path = require('path');

// Define the path where the WebViewPlugin.java file should be created
const pluginPath = path.join(
  process.cwd(),
  'android',
  'app',
  'src',
  'main',
  'java',
  'com',
  'novavista',
  'rateel',
  'WebViewPlugin.java'
);

// Create directory structure if it doesn't exist
const dirPath = path.dirname(pluginPath);
if (!fs.existsSync(dirPath)) {
  fs.mkdirSync(dirPath, { recursive: true });
}

// WebViewPlugin.java content
const pluginContent = `package com.novavista.rateel;

import android.os.Build;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.getcapacitor.Bridge;
import com.getcapacitor.BridgeActivity;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "WebViewConfig")
public class WebViewPlugin extends Plugin {

    @PluginMethod
    public void disableFontScaling(PluginCall call) {
        getBridge().executeOnMainThread(() -> {
            try {
                BridgeActivity activity = (BridgeActivity) getActivity();
                WebView webView = getBridge().getWebView();
                
                // Disable text auto-sizing
                WebSettings settings = webView.getSettings();
                settings.setTextZoom(100);
                
                // Disable smart text sizing on newer Android versions
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    settings.setForceDark(WebSettings.FORCE_DARK_OFF);
                }
                
                // Additional WebView optimizations
                settings.setLoadWithOverviewMode(true);
                settings.setUseWideViewPort(true);
                settings.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.NORMAL);
                
                call.resolve();
            } catch (Exception e) {
                call.reject("Error configuring WebView: " + e.getMessage());
            }
        });
    }
    
    @Override
    protected void handleOnStart() {
        // Apply settings on start
        getBridge().executeOnMainThread(() -> {
            WebView webView = getBridge().getWebView();
            WebSettings settings = webView.getSettings();
            settings.setTextZoom(100);
        });
    }
}`;

// Write the file
fs.writeFileSync(pluginPath, pluginContent);

console.log(`WebViewPlugin.java created at ${pluginPath}`);

// Update MainActivity.java to register the plugin
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

if (fs.existsSync(mainActivityPath)) {
  let mainActivityContent = fs.readFileSync(mainActivityPath, 'utf8');
  
  // Check if the plugin is already registered
  if (!mainActivityContent.includes('registerPlugin(WebViewPlugin.class)')) {
    // Find the onCreate method
    const onCreateRegex = /public void onCreate\(Bundle savedInstanceState\) \{[\s\S]*?super\.onCreate\(savedInstanceState\);/;
    
    // Add the plugin registration after super.onCreate
    mainActivityContent = mainActivityContent.replace(
      onCreateRegex,
      match => `${match}\n        // Register WebViewPlugin\n        registerPlugin(WebViewPlugin.class);`
    );
    
    // Write the updated MainActivity
    fs.writeFileSync(mainActivityPath, mainActivityContent);
    console.log(`Updated MainActivity.java to register WebViewPlugin`);
  } else {
    console.log('WebViewPlugin already registered in MainActivity.java');
  }
} else {
  console.log(`MainActivity.java not found at ${mainActivityPath}`);
}
