package com.example.dcscodex;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class Main2Activity extends AppCompatActivity {
    private Button button;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main2);
//
       button = (Button) findViewById(R.id.register2);
       button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
               openActivity2();
           }
        });
    }

   public void openActivity2(){
        Intent intent = new Intent(this, Main3Activity.class);
        startActivity(intent);
    }
}
