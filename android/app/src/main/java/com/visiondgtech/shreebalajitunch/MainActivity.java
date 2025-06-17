package com.visiondgtech.shreebalajitunch;

import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.shreebalajitunch/developer_mode";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("isDeveloperModeEnabled")) {
                                boolean isDeveloperModeEnabled = isDeveloperModeEnabled();
                                result.success(isDeveloperModeEnabled);
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    private boolean isDeveloperModeEnabled() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            return Settings.Global.getInt(getContentResolver(),
                    Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) != 0;
        } else {
            return Settings.Secure.getInt(getContentResolver(),
                    Settings.Secure.DEVELOPMENT_SETTINGS_ENABLED, 0) != 0;
        }
    }
}
