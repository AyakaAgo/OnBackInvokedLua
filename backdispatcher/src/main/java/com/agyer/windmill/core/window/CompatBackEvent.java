/*
 * Copyright 2023 The Android Open Source Project
 * Copyright 2024 The Windmill Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.agyer.windmill.core.window;

import android.annotation.SuppressLint;
import android.os.Build;
import android.view.InputEvent;
import android.view.KeyEvent;
import android.window.BackEvent;

import androidx.annotation.FloatRange;
import androidx.annotation.IntDef;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * a backward compatibility wrapper of {@link BackEvent}
 * will NEVER constructed under {@link Build.VERSION_CODES#UPSIDE_DOWN_CAKE}
 */
public final class CompatBackEvent {
    /**
     * Indicates that the back event was not triggered by an edge swipe back gesture.
     * This applies to cases like using the back button in 3-button navigation or pressing
     * a hardware back button.
     */
    @SuppressLint("InlinedApi")
    public static final int EDGE_NONE = BackEvent.EDGE_NONE;
    /**
     * Indicates that the edge swipe starts from the left edge of the screen
     */
    @SuppressLint("InlinedApi")
    public static final int EDGE_LEFT = BackEvent.EDGE_LEFT;
    /**
     * Indicates that the edge swipe starts from the right edge of the screen
     */
    @SuppressLint("InlinedApi")
    public static final int EDGE_RIGHT = BackEvent.EDGE_RIGHT;

    @FloatRange(from = 0, to = 1)
    private final float progress;
    private final float x;
    private final float y;
    @SwipeEdge
    private final int edge;
    private final long frameTimeMillis;

    @IntDef(value = {EDGE_NONE, EDGE_LEFT, EDGE_RIGHT})
    @Retention(RetentionPolicy.SOURCE)
    public @interface SwipeEdge {
    }

    @SuppressLint("WrongConstant")
    @RequiresApi(api = Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    CompatBackEvent(@NonNull BackEvent event) {
        this(event.getTouchX(), event.getTouchY(), event.getProgress(), event.getSwipeEdge(),
                Build.VERSION.SDK_INT >= 36 ? event.getFrameTimeMillis() : 0);
    }

    CompatBackEvent(@NonNull InputEvent event) {
        this(0, 0, 0, EDGE_NONE, event.getEventTime());
    }

    public CompatBackEvent(float touchX, float touchY, float progress, int swipeEdge) {
        this(touchX, touchY, progress, swipeEdge, 0);
    }

    public CompatBackEvent(float touchX, float touchY, float progress, int swipeEdge, long frameTimeMillis) {
        this.y = touchY;
        this.x = touchX;
        this.edge = swipeEdge;
        this.progress = progress;
        this.frameTimeMillis = frameTimeMillis;
    }

    /**
     * Returns a value between 0 and 1 on how far along the back gesture is. This value is
     * driven by the horizontal location of the touch point, and should be used as the fraction to
     * seek the predictive back animation with. Specifically,
     * <ol>
     * <li>The progress is 0 when the touch is at the starting edge of the screen (left or right),
     * and animation should seek to its start state.
     * <li>The progress is approximately 1 when the touch is at the opposite side of the screen,
     * and animation should seek to its end state. Exact end value may vary depending on
     * screen size.
     * </ol>
     * <li> After the gesture finishes in cancel state, this method keeps getting invoked until the
     * progress value animates back to 0.
     * </ol>
     * In-between locations are linearly interpolated based on horizontal distance from the starting
     * edge and smooth clamped to 1 when the distance exceeds a system-wide threshold.
     */
    @FloatRange(from = 0, to = 1)
    public float getProgress() {
        return progress;
    }

    /**
     * Returns the absolute X location of the touch point, or NaN if the event is from
     * a button press.
     */
    public float getTouchX() {
        return x;
    }

    /**
     * Returns the absolute Y location of the touch point, or NaN if the event is from
     * a button press.
     */
    public float getTouchY() {
        return y;
    }

    /**
     * Returns the screen edge that the swipe starts from.
     */
    @SwipeEdge
    public int getSwipeEdge() {
        return edge;
    }

    /**
     * @return the frameTime of the BackEvent in milliseconds. Useful for calculating velocity.
     */
    public long getFrameTimeMillis() {
        return frameTimeMillis;
    }

    @Override
    @NonNull
    public String toString() {
        return "BackEvent{touchX=" + x + ", touchY=" + y + ", progress=" + progress + ", swipeEdge" + edge + "}";
    }

}