package Backend;

/**
 * Global game settings
 * Compatible with Psych-style ClientPrefs naming
 */
class Settings
{
    // =========================
    // 🎮 GAMEPLAY SETTINGS
    // =========================

    public static var downScroll:Bool = false;
    public static var middleScroll:Bool = false;

    public static var scrollSpeed:Float = 1.0;

    // Ghost tapping (future gameplay logic)
    public static var ghostTapping:Bool = true;

    // =========================
    // 🎨 VISUAL SETTINGS
    // =========================

    public static var laneAlpha:Float = 1.0;
    public static var noteScale:Float = 1.0;

    // Note splash / effects (future)
    public static var noteSplashes:Bool = true;

    // =========================
    // 📊 UI SETTINGS
    // =========================

    public static var showAccuracy:Bool = true;
    public static var showNPS:Bool = true;

    // Score display formatting
    public static var scoreSeparator:Bool = true; // 1,000,000 vs 1000000
    public static var accuracyDecimals:Int = 2;   // 98.53%

    // =========================
    // ⚙️ SMOOTH SYSTEMS
    // =========================

    public static var smoothHealth:Bool = true;
    public static var smoothScore:Bool = true;

    // Smooth intensity (important for your lerp tuning 👀)
    public static var healthLerp:Float = 0.1;
    public static var scoreLerp:Float = 0.1;

    // =========================
    // 🔊 TIMING / HIT WINDOWS
    // =========================

    public static var noteOffset:Float = 0;
    public static var safeFrames:Int = 10;

    // =========================
    // 🔧 DEBUG / TESTING (VERY USEFUL FOR YOU)
    // =========================

    public static var debugMode:Bool = false;
    public static var showHitboxes:Bool = false;

    // =========================
    // 🔄 RESET FUNCTION
    // =========================

    public static function reset()
    {
        // Gameplay
        downScroll = false;
        middleScroll = false;
        scrollSpeed = 1.0;
        ghostTapping = true;

        // Visual
        laneAlpha = 1.0;
        noteScale = 1.0;
        noteSplashes = true;

        // UI
        showAccuracy = true;
        showNPS = true;
        scoreSeparator = true;
        accuracyDecimals = 2;

        // Smooth
        smoothHealth = true;
        smoothScore = true;
        healthLerp = 0.1;
        scoreLerp = 0.1;

        // Timing
        noteOffset = 0;
        safeFrames = 10;

        // Debug
        debugMode = false;
        showHitboxes = false;
    }
}
