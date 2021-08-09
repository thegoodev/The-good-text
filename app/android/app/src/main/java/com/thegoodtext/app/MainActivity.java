package com.thegoodtext.app;

import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.ParcelFileDescriptor;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private Uri data;
    private String type;
    private Intent intent;
    private Cursor cursor;
    private  static final String CHANNEL = "com.the-good-text";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        intent = getIntent();
        String action = intent.getAction();
        String scheme = intent.getScheme();
        data = intent.getData();

        if(Intent.ACTION_VIEW.equals(action)&&data!=null){

            if("https".equals(scheme)){
                type = "link";
            }else{
                type = intent.getScheme();
            }
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result)->{
                    if(call.method.contentEquals("getIntent")){
                        HashMap intentData = new HashMap<>();
                        if(data!=null){
                            intentData.put("data",data.toString());
                        }
                        intentData.put("type",type);
                        result.success(intentData);
                        data = null;
                        type = null;
                    }else if(call.method.contentEquals("getContent")){
                        try {
                            ParcelFileDescriptor PFD = getContentResolver().openFileDescriptor(intent.getData(), "r");
                            FileInputStream fin = new FileInputStream(PFD.getFileDescriptor());
                            byte[] bytes = new byte[(int) PFD.getStatSize()];
                            fin.read(bytes);
                            fin.close();
                            result.success(new String(bytes));
                        } catch (IOException e) {
                            result.error("Error", e.getMessage(), e.getCause().toString());
                        }
                    }else {
                        result.notImplemented();
                    }
                });
    }
}
