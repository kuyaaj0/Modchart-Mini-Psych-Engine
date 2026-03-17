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

    // =========================
    // 🎨 VISUAL SETTINGS
    // =========================

    public static var laneAlpha:Float = 1.0;
    public static var noteScale:Float = 1.0;

    // =========================
    // 📊 UI SETTINGS
    // =========================

    public static var showAccuracy:Bool = true;
    public static var showNPS:Bool = true;

    // =========================
    // ⚙️ SMOOTH SYSTEMS
    // =========================

    public static var smoothHealth:Bool = true;
    public static var smoothScore:Bool = true;

    // =========================
    // 🔊 FUTURE SETTINGS (optional)
    // =========================

    public static var noteOffset:Float = 0;
    public static var safeFrames:Int = 10;

    // =========================
    // 🔄 RESET FUNCTION
    // =========================

    public static function reset()
    {
        downScroll = false;
        middleScroll = false;

        scrollSpeed = 1.0;

        laneAlpha = 1.0;
        noteScale = 1.0;

        showAccuracy = true;
        showNPS = true;

        smoothHealth = true;
        smoothScore = true;

        noteOffset = 0;
        safeFrames = 10;
    }
}
