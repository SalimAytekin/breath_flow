/*
 * Copyright 2020 Google LLC. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.mlkit.vision.demo.java;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.util.Log;
import android.util.Size;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.Toast;
import java.util.concurrent.ExecutionException;
import com.google.common.util.concurrent.ListenableFuture;
import android.widget.ToggleButton;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraInfoUnavailableException;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;
import com.google.android.gms.common.annotation.KeepName;
import com.google.mlkit.common.MlKitException;
// CameraXViewModel kaldırıldı - fizik tedavi uygulaması için gereksiz
import com.google.mlkit.vision.demo.GraphicOverlay;
import com.google.mlkit.vision.demo.R;
import com.google.mlkit.vision.demo.VisionImageProcessor;
import com.google.mlkit.vision.demo.java.posedetector.PoseDetectorProcessor;
import com.google.mlkit.vision.demo.preference.PreferenceUtils;
import com.google.mlkit.vision.demo.preference.SettingsActivity;
import com.google.mlkit.vision.pose.PoseDetectorOptionsBase;
import java.util.ArrayList;
import java.util.List;

/** Fizik tedavi uygulaması için poz algılama arayüzü */
@KeepName
@RequiresApi(VERSION_CODES.LOLLIPOP)
public class CameraXLivePreviewActivity extends AppCompatActivity
    implements CompoundButton.OnCheckedChangeListener, ActivityCompat.OnRequestPermissionsResultCallback {
  private static final String TAG = "CameraXLivePreview";
  private static final int PERMISSION_REQUESTS = 1;

  // Sadece poz algılama kullanıyoruz
  private static final String POSE_DETECTION = "Pose Detection";
  
  private static final String STATE_SELECTED_MODEL = "selected_model";
  private static final String STATE_LENS_FACING = "lens_facing";
  private PreviewView previewView;
  private GraphicOverlay graphicOverlay;

  @Nullable private ProcessCameraProvider cameraProvider;
  @Nullable private androidx.camera.core.Camera camera;
  @Nullable private Preview previewUseCase;
  @Nullable private ImageAnalysis analysisUseCase;
  @Nullable private VisionImageProcessor imageProcessor;
  private boolean needUpdateGraphicOverlayImageSourceInfo;

  private String selectedModel = POSE_DETECTION;
  private int lensFacing = CameraSelector.LENS_FACING_BACK;
  private CameraSelector cameraSelector;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Log.d(TAG, "onCreate");

    cameraSelector = new CameraSelector.Builder().requireLensFacing(lensFacing).build();

    setContentView(R.layout.activity_vision_camerax_live_preview);
    
    // Poz algılama modeli için doğrudan ayarla
    selectedModel = POSE_DETECTION;

    previewView = findViewById(R.id.preview_view);
    if (previewView == null) {
      Log.d(TAG, "previewView is null");
    }
    
    graphicOverlay = findViewById(R.id.graphic_overlay);
    if (graphicOverlay == null) {
      Log.d(TAG, "graphicOverlay is null");
    }

    // Ayarlar butonu kaldırıldı - fizik tedavi uygulaması için gereksiz

    if (!allPermissionsGranted()) {
      getRuntimePermissions();
    }

    ViewModelProvider.AndroidViewModelFactory viewModelFactory =
        ViewModelProvider.AndroidViewModelFactory.getInstance(getApplication());

    // CameraXViewModel kaldırıldı, doğrudan ProcessCameraProvider alıyoruz
    ListenableFuture<ProcessCameraProvider> cameraProviderFuture = ProcessCameraProvider.getInstance(this);
    cameraProviderFuture.addListener(
        () -> {
          try {
            cameraProvider = cameraProviderFuture.get();
            bindAllCameraUseCases();
          } catch (ExecutionException | InterruptedException e) {
            Log.e(TAG, "Error initializing camera: ", e);
          }
        },
        ContextCompat.getMainExecutor(this));
  }

  @Override
  public void onSaveInstanceState(@NonNull Bundle bundle) {
    super.onSaveInstanceState(bundle);
    bundle.putString(STATE_SELECTED_MODEL, selectedModel);
    bundle.putInt(STATE_LENS_FACING, lensFacing);
  }

  @Override
  public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
    if (cameraProvider == null) {
      return;
    }
    int newLensFacing =
        lensFacing == CameraSelector.LENS_FACING_FRONT
            ? CameraSelector.LENS_FACING_BACK
            : CameraSelector.LENS_FACING_FRONT;
    CameraSelector newCameraSelector =
        new CameraSelector.Builder().requireLensFacing(newLensFacing).build();
    try {
      if (cameraProvider.hasCamera(newCameraSelector)) {
        lensFacing = newLensFacing;
        cameraSelector = newCameraSelector;
        bindAllCameraUseCases();
        return;
      }
    } catch (CameraInfoUnavailableException e) {
      // Kamera değiştirilemediğinde hata mesajı göster
    }
    Toast.makeText(
            getApplicationContext(),
            "Bu cihaz kamera değiştirmeyi desteklemiyor",
            Toast.LENGTH_SHORT)
        .show();
  }

  @Override
  public void onResume() {
    super.onResume();
    bindAllCameraUseCases();
  }

  @Override
  public void onPause() {
    super.onPause();
    if (imageProcessor != null) {
      imageProcessor.stop();
    }
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    if (imageProcessor != null) {
      imageProcessor.stop();
    }
  }

  private void bindAllCameraUseCases() {
    if (cameraProvider != null) {
      // Mevcut bağlı kullanım durumlarının tümünü iptal et
      cameraProvider.unbindAll();
      bindPreviewUseCase();
      bindAnalysisUseCase();
    }
  }

  private void bindPreviewUseCase() {
    if (!PreferenceUtils.isCameraLiveViewportEnabled(this)) {
      return;
    }
    if (cameraProvider == null) {
      return;
    }
    if (previewUseCase != null) {
      cameraProvider.unbind(previewUseCase);
    }

    Preview.Builder builder = new Preview.Builder();
    Size targetResolution = PreferenceUtils.getCameraXTargetResolution(this, lensFacing);
    if (targetResolution != null) {
      builder.setTargetResolution(targetResolution);
    }
    previewUseCase = builder.build();
    previewUseCase.setSurfaceProvider(previewView.getSurfaceProvider());
    camera =
        cameraProvider.bindToLifecycle(/* lifecycleOwner= */ this, cameraSelector, previewUseCase);
  }

  private void bindAnalysisUseCase() {
    if (cameraProvider == null) {
      return;
    }
    if (analysisUseCase != null) {
      cameraProvider.unbind(analysisUseCase);
    }
    if (imageProcessor != null) {
      imageProcessor.stop();
    }

    try {
      // Sadece poz algılama için işleyici oluştur
      PoseDetectorOptionsBase poseDetectorOptions =
          PreferenceUtils.getPoseDetectorOptionsForLivePreview(this);
      boolean shouldShowInFrameLikelihood =
          PreferenceUtils.shouldShowPoseDetectionInFrameLikelihoodLivePreview(this);
      boolean visualizeZ = PreferenceUtils.shouldPoseDetectionVisualizeZ(this);
      boolean rescaleZ = PreferenceUtils.shouldPoseDetectionRescaleZForVisualization(this);
      boolean runClassification = PreferenceUtils.shouldPoseDetectionRunClassification(this);
      imageProcessor =
          new PoseDetectorProcessor(
              this,
              poseDetectorOptions,
              shouldShowInFrameLikelihood,
              visualizeZ,
              rescaleZ,
              runClassification,
              /* isStreamMode = */ true);

      ImageAnalysis.Builder builder = new ImageAnalysis.Builder();
      Size targetResolution = PreferenceUtils.getCameraXTargetResolution(this, lensFacing);
      if (targetResolution != null) {
        builder.setTargetResolution(targetResolution);
      }
      analysisUseCase = builder.build();

      needUpdateGraphicOverlayImageSourceInfo = true;
      analysisUseCase.setAnalyzer(
          // imageProcessor.processImageProxy bir arka plan thread'inde çalışıyor
          ContextCompat.getMainExecutor(this),
          imageProxy -> {
            if (needUpdateGraphicOverlayImageSourceInfo) {
              boolean isImageFlipped = lensFacing == CameraSelector.LENS_FACING_FRONT;
              int rotationDegrees = imageProxy.getImageInfo().getRotationDegrees();
              if (rotationDegrees == 0 || rotationDegrees == 180) {
                graphicOverlay.setImageSourceInfo(
                    imageProxy.getWidth(), imageProxy.getHeight(), isImageFlipped);
              } else {
                graphicOverlay.setImageSourceInfo(
                    imageProxy.getHeight(), imageProxy.getWidth(), isImageFlipped);
              }
              needUpdateGraphicOverlayImageSourceInfo = false;
            }
            try {
              imageProcessor.processImageProxy(imageProxy, graphicOverlay);
            } catch (MlKitException e) {
              Log.e(TAG, "Failed to process image. Error: " + e.getLocalizedMessage());
              Toast.makeText(getApplicationContext(), e.getLocalizedMessage(), Toast.LENGTH_SHORT)
                  .show();
            }
          });

      cameraProvider.bindToLifecycle(/* lifecycleOwner= */ this, cameraSelector, analysisUseCase);
    } catch (Exception e) {
      Log.e(TAG, "Analiz kullanım durumu bağlanamadı: " + e);
      if (imageProcessor != null) {
        imageProcessor.stop();
      }
    }
  }
  
  private boolean allPermissionsGranted() {
    for (String permission : getRequiredPermissions()) {
      if (!isPermissionGranted(this, permission)) {
        return false;
      }
    }
    return true;
  }

  private String[] getRequiredPermissions() {
    try {
      PackageInfo info =
          this.getPackageManager()
              .getPackageInfo(this.getPackageName(), PackageManager.GET_PERMISSIONS);
      String[] ps = info.requestedPermissions;
      if (ps != null && ps.length > 0) {
        return ps;
      } else {
        return new String[0];
      }
    } catch (Exception e) {
      return new String[0];
    }
  }

  private static boolean isPermissionGranted(Context context, String permission) {
    if (ContextCompat.checkSelfPermission(context, permission)
        == PackageManager.PERMISSION_GRANTED) {
      Log.i(TAG, "Permission granted: " + permission);
      return true;
    }
    Log.i(TAG, "Permission NOT granted: " + permission);
    return false;
  }

  private void getRuntimePermissions() {
    List<String> allNeededPermissions = new ArrayList<>();
    for (String permission : getRequiredPermissions()) {
      if (!isPermissionGranted(this, permission)) {
        allNeededPermissions.add(permission);
      }
    }

    if (!allNeededPermissions.isEmpty()) {
      ActivityCompat.requestPermissions(
          this, allNeededPermissions.toArray(new String[0]), PERMISSION_REQUESTS);
    }
  }

  @Override
  public void onRequestPermissionsResult(
      int requestCode, String[] permissions, int[] grantResults) {
    Log.i(TAG, "İzin sonucu alındı.");
    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    if (requestCode == PERMISSION_REQUESTS) {
      if (allPermissionsGranted()) {
        bindAllCameraUseCases();
      }
    }
  }
}
