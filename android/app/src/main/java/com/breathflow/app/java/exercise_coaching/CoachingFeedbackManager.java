package com.breathflow.app.java.exercise_coaching;

import android.util.Log;

/**
 * Koçluk geri bildirimlerini yöneten ve stabilize eden sınıf.
 *
 * Sorun: Her frame'de farklı bir feedback mesajı üretiliyordu ve
 * 300ms throttling yeterli değildi → kullanıcı sürekli değişen mesajlar
 * görüyordu.
 *
 * Çözüm:
 * 1. Minimum görüntülenme süresi: Mesaj en az 2 saniye ekranda kalır
 * 2. Öncelik sistemi: Güvenlik > Tekrar > Koçluk > Bilgi
 * 3. Aynı kategori mesaj supression: Kategori değişmedikçe mesajı güncelleme
 * 4. Geçiş debounce: Yeni mesajın en az 500ms boyunca tutarlı olması gerekir
 */
public class CoachingFeedbackManager {
    private static final String TAG = "CoachFeedback";

    // ═══════════════════════════════════════════
    // Feedback Parametreleri
    // ═══════════════════════════════════════════

    /** Mesajın ekranda kalma minimum süresi (ms) */
    private static final long MIN_DISPLAY_DURATION_MS = 2000;

    /** Düşük öncelikli mesaj değişikliği için gereken tutarlılık süresi (ms) */
    private static final long DEBOUNCE_DURATION_MS = 500;

    /**
     * Yüksek öncelikli mesajlar anında gösterilir (güvenlik uyarıları, tekrar
     * sayımı)
     */
    private static final int PRIORITY_CRITICAL = 100; // Güvenlik uyarısı
    private static final int PRIORITY_REP_COUNT = 80; // Tekrar tamamlandı
    private static final int PRIORITY_STATE_CHANGE = 60; // Durum değişikliği (tut, bırak vb.)
    private static final int PRIORITY_COACHING = 40; // Koçluk yönergesi
    private static final int PRIORITY_INFO = 20; // Genel bilgi

    // ═══════════════════════════════════════════
    // State
    // ═══════════════════════════════════════════

    /** Şu an ekranda gösterilen mesaj */
    private String currentMessage = "";
    private int currentPriority = 0;
    private long currentMessageStartTime = 0;

    /** Sıradaki aday mesaj (debounce için) */
    private String pendingMessage = "";
    private int pendingPriority = 0;
    private long pendingStartTime = 0;

    /** Feedback değişikliği listener */
    private FeedbackListener listener;

    public interface FeedbackListener {
        void onFeedbackChanged(String message);
    }

    public void setListener(FeedbackListener listener) {
        this.listener = listener;
    }

    /**
     * Yeni bir feedback mesajı öner.
     * Mesaj hemen gösterilmeyebilir — debounce ve minimum display süresi kontrol
     * edilir.
     *
     * @param message  Görüntülenecek mesaj
     * @param priority Mesaj önceliği (yüksek = daha acil)
     */
    public void proposeFeedback(String message, int priority) {
        if (message == null || message.isEmpty())
            return;

        long now = System.currentTimeMillis();

        // Aynı mesaj tekrarı → yok say
        if (message.equals(currentMessage)) {
            return;
        }

        // Yüksek öncelikli mesaj → anında göster (güvenlik uyarısı, tekrar sayımı)
        if (priority >= PRIORITY_REP_COUNT) {
            showMessage(message, priority, now);
            return;
        }

        // Mevcut mesaj henüz minimum süresini doldurmadıysa VE yeni mesaj daha
        // düşük/eşit öncelikli
        long elapsed = now - currentMessageStartTime;
        if (elapsed < MIN_DISPLAY_DURATION_MS && priority <= currentPriority) {
            return; // Mevcut mesajı koru
        }

        // Debounce: yeni mesajın tutarlı olup olmadığını kontrol et
        if (!message.equals(pendingMessage)) {
            // Yeni aday mesaj — debounce timer başlat
            pendingMessage = message;
            pendingPriority = priority;
            pendingStartTime = now;
            return;
        }

        // Aynı aday mesaj tekrar geldi — debounce süresi doldu mu?
        if (now - pendingStartTime >= DEBOUNCE_DURATION_MS) {
            showMessage(message, priority, now);
            pendingMessage = "";
        }
    }

    /**
     * Mesajı göster ve state'i güncelle.
     */
    private void showMessage(String message, int priority, long now) {
        currentMessage = message;
        currentPriority = priority;
        currentMessageStartTime = now;
        pendingMessage = "";

        Log.d(TAG, "📢 Feedback gösteriliyor (P=" + priority + "): " + message);

        if (listener != null) {
            listener.onFeedbackChanged(message);
        }
    }

    // ═══════════════════════════════════════════
    // Convenience metodlar — öncelik otomatik belirlenir
    // ═══════════════════════════════════════════

    /** Güvenlik uyarısı (anında gösterilir) */
    public void safetyWarning(String message) {
        proposeFeedback(message, PRIORITY_CRITICAL);
    }

    /** Tekrar tamamlandı bildirimi (anında gösterilir) */
    public void repCompleted(String message) {
        proposeFeedback(message, PRIORITY_REP_COUNT);
    }

    /** Durum değişikliği (tut, bırak, eğ, dön vb.) */
    public void stateChange(String message) {
        proposeFeedback(message, PRIORITY_STATE_CHANGE);
    }

    /** Koçluk yönergesi (biraz daha eğ, devam et vb.) */
    public void coaching(String message) {
        proposeFeedback(message, PRIORITY_COACHING);
    }

    /** Genel bilgi (düz dur, hazırlan vb.) */
    public void info(String message) {
        proposeFeedback(message, PRIORITY_INFO);
    }

    /** Mevcut gösterilen mesaj */
    public String getCurrentMessage() {
        return currentMessage;
    }

    /** Tüm state'i sıfırla */
    public void reset() {
        currentMessage = "";
        currentPriority = 0;
        currentMessageStartTime = 0;
        pendingMessage = "";
        pendingPriority = 0;
        pendingStartTime = 0;
    }

    // ═══════════════════════════════════════════
    // Static helper: Mesaj içeriğinden öncelik çıkar
    // ═══════════════════════════════════════════

    /**
     * Mesaj içeriğinden otomatik öncelik belirle.
     * Analyzer'lar doğrudan proposeFeedback çağırdığında kullanılır.
     */
    public static int detectPriority(String message) {
        if (message == null)
            return PRIORITY_INFO;

        // Güvenlik / uyarı
        if (message.contains("⚠️") || message.contains("DİKKAT") ||
                message.contains("Dikkat") || message.contains("fazla")) {
            return PRIORITY_CRITICAL;
        }

        // Tekrar tamamlandı
        if (message.contains("tamamlandı") || message.contains("TEBRİKLER") ||
                message.contains("🏆") || message.contains("👏")) {
            return PRIORITY_REP_COUNT;
        }

        // Durum değişikliği
        if (message.contains("Şimdi") || message.contains("tutun") ||
                message.contains("eğilin") || message.contains("dönün") ||
                message.contains("Mükemmel açı")) {
            return PRIORITY_STATE_CHANGE;
        }

        // Koçluk
        if (message.contains("Devam") || message.contains("Güzel") ||
                message.contains("iyi") || message.contains("daha")) {
            return PRIORITY_COACHING;
        }

        return PRIORITY_INFO;
    }
}
