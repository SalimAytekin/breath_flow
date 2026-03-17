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

package com.breathflow.app.java.posedetector;

import static java.lang.Math.max;
import static java.lang.Math.min;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import com.google.mlkit.vision.common.PointF3D;
import com.breathflow.app.GraphicOverlay;
import com.breathflow.app.GraphicOverlay.Graphic;
import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/** Draw the detected pose in preview with EMA smoothing. */
public class PoseGraphic extends Graphic {

  private static final float DOT_RADIUS = 8.0f;
  private static final float IN_FRAME_LIKELIHOOD_TEXT_SIZE = 30.0f;
  private static final float STROKE_WIDTH = 10.0f;
  private static final float POSE_CLASSIFICATION_TEXT_SIZE = 60.0f;

  // ═══════════════════════════════════════════
  // EMA Smoothing parametreleri
  // ═══════════════════════════════════════════
  private static final float EMA_ALPHA = 0.35f; // 0.0 = çok pürüzsüz, 1.0 = raw
  private static final float DEAD_ZONE_PX = 2.0f; // Bu mesafenin altı → hareket yok say

  // Static olarak tüm frame'ler arasında tutulur
  private static final Map<Integer, float[]> smoothedPositions = new HashMap<>();

  private final Pose pose;
  private final boolean showInFrameLikelihood;
  private final boolean visualizeZ;
  private final boolean rescaleZForVisualization;
  private float zMin = Float.MAX_VALUE;
  private float zMax = Float.MIN_VALUE;

  private final List<String> poseClassification;
  private final Paint classificationTextPaint;
  private final Paint leftPaint;
  private final Paint rightPaint;
  private final Paint whitePaint;

  PoseGraphic(
      GraphicOverlay overlay,
      Pose pose,
      boolean showInFrameLikelihood,
      boolean visualizeZ,
      boolean rescaleZForVisualization,
      List<String> poseClassification) {
    super(overlay);
    this.pose = pose;
    this.showInFrameLikelihood = showInFrameLikelihood;
    this.visualizeZ = visualizeZ;
    this.rescaleZForVisualization = rescaleZForVisualization;

    this.poseClassification = poseClassification;
    classificationTextPaint = new Paint();
    classificationTextPaint.setColor(Color.WHITE);
    classificationTextPaint.setTextSize(POSE_CLASSIFICATION_TEXT_SIZE);
    classificationTextPaint.setShadowLayer(5.0f, 0f, 0f, Color.BLACK);

    whitePaint = new Paint();
    whitePaint.setStrokeWidth(STROKE_WIDTH);
    whitePaint.setColor(Color.WHITE);
    whitePaint.setTextSize(IN_FRAME_LIKELIHOOD_TEXT_SIZE);
    leftPaint = new Paint();
    leftPaint.setStrokeWidth(STROKE_WIDTH);
    leftPaint.setColor(Color.GREEN);
    rightPaint = new Paint();
    rightPaint.setStrokeWidth(STROKE_WIDTH);
    rightPaint.setColor(Color.YELLOW);
  }

  /**
   * Landmark pozisyonunu EMA ile smooth et.
   * Dead zone: hareket < DEAD_ZONE_PX ise eski pozisyonu koru.
   */
  private float[] getSmoothedPosition(PoseLandmark landmark) {
    int type = landmark.getLandmarkType();
    float rawX = landmark.getPosition3D().getX();
    float rawY = landmark.getPosition3D().getY();
    float rawZ = landmark.getPosition3D().getZ();

    float[] prev = smoothedPositions.get(type);
    if (prev == null) {
      // İlk frame — direkt raw değeri kullan
      float[] pos = new float[] { rawX, rawY, rawZ };
      smoothedPositions.put(type, pos);
      return pos;
    }

    // Dead zone kontrolü: mesafe çok küçükse güncelleme
    float dx = rawX - prev[0];
    float dy = rawY - prev[1];
    float dist = (float) Math.sqrt(dx * dx + dy * dy);

    if (dist < DEAD_ZONE_PX) {
      return prev; // Hareket yok — eski pozisyonu koru
    }

    // EMA smoothing
    float smoothX = EMA_ALPHA * rawX + (1 - EMA_ALPHA) * prev[0];
    float smoothY = EMA_ALPHA * rawY + (1 - EMA_ALPHA) * prev[1];
    float smoothZ = EMA_ALPHA * rawZ + (1 - EMA_ALPHA) * prev[2];

    float[] smoothed = new float[] { smoothX, smoothY, smoothZ };
    smoothedPositions.put(type, smoothed);
    return smoothed;
  }

  /** Smoothing arabelleğini temizle (kamera değişikliğinde vb.) */
  public static void resetSmoothing() {
    smoothedPositions.clear();
  }

    // MARK: - Gamification (Accuracy Color)
    private static double currentAccuracy = 0.0;
    
    public static void updateAccuracy(double accuracy) {
        currentAccuracy = accuracy;
    }

  @Override
  public void draw(Canvas canvas) {
    List<PoseLandmark> landmarks = pose.getAllPoseLandmarks();
    if (landmarks.isEmpty()) {
      return;
    }

    // Draw pose classification text.
    float classificationX = POSE_CLASSIFICATION_TEXT_SIZE * 0.5f;
    for (int i = 0; i < poseClassification.size(); i++) {
      float classificationY = (canvas.getHeight()
          - POSE_CLASSIFICATION_TEXT_SIZE * 1.5f * (poseClassification.size() - i));
      canvas.drawText(
          poseClassification.get(i), classificationX, classificationY, classificationTextPaint);
    }

    // Tüm landmark'ları smooth et ve z range hesapla
    for (PoseLandmark landmark : landmarks) {
      float[] smoothed = getSmoothedPosition(landmark);
      if (visualizeZ && rescaleZForVisualization) {
        zMin = min(zMin, smoothed[2]);
        zMax = max(zMax, smoothed[2]);
      }
    }

    // Dinamik Renk Hesaplama (Gamification)
    // 0.0 (Beyaz) -> 1.0 (Parlak/Neon Yeşil)
    float greenVal = (float) Math.max(0.0, Math.min(1.0, currentAccuracy));
    
    // Ara renk: Beyaz (255,255,255) -> Yeşil yaklaştıkça kırmızı ve mavi azalıyor
    int redVal = (int) (255 * (1.0f - greenVal));
    int blueVal = (int) (255 * (1.0f - greenVal));
    int alphaVal = (int) (255 * 0.8f);

    int dynamicColor = Color.argb(alphaVal, redVal, 255, blueVal);
    
    Paint dynamicPaint = new Paint();
    dynamicPaint.setStrokeWidth(STROKE_WIDTH);
    dynamicPaint.setColor(dynamicColor);
    dynamicPaint.setStyle(Paint.Style.FILL_AND_STROKE);
    
    // Glow (Neon) Efekti Ekle
    int shadowAlpha = (int) (255 * (currentAccuracy * 0.8f));
    int shadowColor = Color.argb(shadowAlpha, 0, 255, 0);
    dynamicPaint.setShadowLayer(10.0f + (float)(currentAccuracy * 15.0f), 0f, 0f, shadowColor);
    
    // Sadece Burun ve Omuz Hizasını Çiz
    PoseLandmark nose = pose.getPoseLandmark(PoseLandmark.NOSE);
    PoseLandmark leftShoulder = pose.getPoseLandmark(PoseLandmark.LEFT_SHOULDER);
    PoseLandmark rightShoulder = pose.getPoseLandmark(PoseLandmark.RIGHT_SHOULDER);
    
    if (nose != null) {
      drawSmoothedPoint(canvas, nose, dynamicPaint);
    }
    
    if (leftShoulder != null && rightShoulder != null) {
      // Omuz çizgisini yarı saydam yap
      Paint semiTransparentPaint = new Paint(dynamicPaint);
      semiTransparentPaint.setAlpha((int)(255 * 0.5f));
      drawSmoothedLine(canvas, leftShoulder, rightShoulder, semiTransparentPaint);
    }

    // Draw inFrameLikelihood for all points (smoothed positions)
    if (showInFrameLikelihood) {
        // İsteğe bağlı olarak korunabilir ama sade UI istendiğinde textleri debug modda göster
        for (PoseLandmark landmark : landmarks) {
            float[] sp = getSmoothedPosition(landmark);
            canvas.drawText(
                String.format(Locale.US, "%.2f", landmark.getInFrameLikelihood()),
                translateX(sp[0]),
                translateY(sp[1]),
                whitePaint);
        }
    }
  }

  /** Smoothed pozisyon ile nokta çiz */
  void drawSmoothedPoint(Canvas canvas, PoseLandmark landmark, Paint paint) {
    if (landmark.getInFrameLikelihood() < 0.75f) return; // Düşük güvenilirlik filtresi
      
    float[] sp = getSmoothedPosition(landmark);
    updatePaintColorByZValue(
        paint, canvas, visualizeZ, rescaleZForVisualization, sp[2], zMin, zMax);
    canvas.drawCircle(translateX(sp[0]), translateY(sp[1]), DOT_RADIUS, paint);
  }

  /** Smoothed pozisyonlar ile çizgi çiz */
  void drawSmoothedLine(Canvas canvas, PoseLandmark startLandmark, PoseLandmark endLandmark, Paint paint) {
    if (startLandmark.getInFrameLikelihood() < 0.75f || endLandmark.getInFrameLikelihood() < 0.75f) return;
      
    float[] start = getSmoothedPosition(startLandmark);
    float[] end = getSmoothedPosition(endLandmark);

    float avgZInImagePixel = (start[2] + end[2]) / 2;
    updatePaintColorByZValue(
        paint, canvas, visualizeZ, rescaleZForVisualization, avgZInImagePixel, zMin, zMax);

    canvas.drawLine(
        translateX(start[0]),
        translateY(start[1]),
        translateX(end[0]),
        translateY(end[1]),
        paint);
  }

  void drawPoint(Canvas canvas, PoseLandmark landmark, Paint paint) {
    PointF3D point = landmark.getPosition3D();
    updatePaintColorByZValue(
        paint, canvas, visualizeZ, rescaleZForVisualization, point.getZ(), zMin, zMax);
    canvas.drawCircle(translateX(point.getX()), translateY(point.getY()), DOT_RADIUS, paint);
  }

  void drawLine(Canvas canvas, PoseLandmark startLandmark, PoseLandmark endLandmark, Paint paint) {
    PointF3D start = startLandmark.getPosition3D();
    PointF3D end = endLandmark.getPosition3D();

    float avgZInImagePixel = (start.getZ() + end.getZ()) / 2;
    updatePaintColorByZValue(
        paint, canvas, visualizeZ, rescaleZForVisualization, avgZInImagePixel, zMin, zMax);

    canvas.drawLine(
        translateX(start.getX()),
        translateY(start.getY()),
        translateX(end.getX()),
        translateY(end.getY()),
        paint);
  }
}
