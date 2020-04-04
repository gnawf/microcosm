package com.gnawf.microcosm.app;

import android.os.Bundle;
import android.view.Window;
import io.flutter.embedding.android.FlutterActivity;

import static android.graphics.Color.TRANSPARENT;
import static android.view.WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS;
import static android.view.WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION;
import static android.view.WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS;

public class MainActivity extends FlutterActivity {
    public MainActivity() {
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Set transparent status bar
        Window window = getWindow();
        window.addFlags(FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        window.clearFlags(FLAG_TRANSLUCENT_STATUS);
        window.addFlags(FLAG_TRANSLUCENT_NAVIGATION);
        window.setStatusBarColor(TRANSPARENT);
    }
}
