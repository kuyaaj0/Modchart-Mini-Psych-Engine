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
    public static var ghostTapping:Bool = true;

    // =========================
    // 🎨 VISUAL SETTINGS
    // =========================
    public static var laneAlpha:Float = 1.0;
    public static var noteScale:Float = 1.0;
    public static var noteSplashes:Bool = true;

    // =========================
    // 📊 UI SETTINGS
    // =========================
    public static var showAccuracy:Bool = true;
    public static var showNPS:Bool = true;
    public static var scoreSeparator:Bool = true; // 1,000,000 vs 1000000
    public static var accuracyDecimals:Int = 2;

    // =========================
    // ⚙️ SMOOTH SYSTEMS
    // =========================
    public static var smoothHealth:Bool = true;
    public static var smoothScore:Bool = true;
    public static var healthLerp:Float = 0.1;
    public static var scoreLerp:Float = 0.1;

    // =========================
    // 🔊 TIMING / HIT WINDOWS
    // =========================
    public static var noteOffset:Float = 0;
    public static var safeFrames:Int = 10;

    // =========================
    // 🔧 DEBUG / TESTING
    // =========================
    public static var debugMode:Bool = false;
    public static var showHitboxes:Bool = false;

    // =========================
    // 📱 MOBILE INPUT OPTIONS
    // =========================
    public static var mobileLaneTiles:Bool = true;
    public static var mobileDPad:Bool = false;
    public static var mobileCustomDPad:Bool = false;
    public static var mobileCustomDPadPosition:Bool = false;
    public static var mobileClickOnNotePosition:Bool = true;
    public static var keyboardMode:Bool = false;

    // ===== NEW =====
    // Use official FNF mobile note layout (centered & spaced)
    public static var mobileOfficialLayout:Bool = true;

    // =========================
    // 🔄 RESET FUNCTION
    // =========================
    public static function reset()
    {
        downScroll = false;
        middleScroll = false;
        scrollSpeed = 1.0;
        ghostTapping = true;

        laneAlpha = 1.0;
        noteScale = 1.0;
        noteSplashes = true;

        showAccuracy = true;
        showNPS = true;
        scoreSeparator = true;
        accuracyDecimals = 2;

        smoothHealth = true;
        smoothScore = true;
        healthLerp = 0.1;
        scoreLerp = 0.1;

        noteOffset = 0;
        safeFrames = 10;

        debugMode = false;
        showHitboxes = false;

        mobileLaneTiles = true;
        mobileDPad = false;
        mobileCustomDPad = false;
        mobileCustomDPadPosition = false;
        mobileClickOnNotePosition = true;
        keyboardMode = false;

        mobileOfficialLayout = true;
    }
}
