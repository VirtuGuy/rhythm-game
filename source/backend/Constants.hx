package backend;

/**
 * A class with constant variables that will stay the same.
 */
class Constants
{
    public static final IMAGE_EXT = 'png';
    public static final SOUND_EXT = 'wav';
    public static final JSON_EXT = 'json';

    public static final NOTE_WIDTH = 18;
    public static final NOTE_HEIGHT = 18;

    public static final HOLD_WIDTH = 14;
    public static final HOLD_HEIGHT = 14;
    
    public static final NOTE_SCALE = 4.75;
    public static final NOTE_COUNT = 4;
    public static final STRUM_SPACING = 10;
    public static final STRUM_YOFF = 10;

    public static final PIXELS_PER_MS = 0.45;
    public static final FRAMES_PER_SEC = 60;
    public static final MS_PER_SEC = 1000;
    public static final BEATS_PER_MIN = 60;
    public static final STEPS_PER_BEAT = 4;
    public static final STEPS_PER_SECTION = 16;

    public static final DEFAULT_BPM = 100;
    public static final DEFAULT_SPEED = 1;

    public static final HIT_FRAMES = 10;
    public static final HIT_ZONE = (HIT_FRAMES / FRAMES_PER_SEC) * MS_PER_SEC;

    public static final SYNC_CHECK = 200;

    public static final CHARTING_GRID_SIZE = 48;
}