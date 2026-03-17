package Backend;

import flixel.util.FlxColor;

/**
 * Global game settings & runtime values
 * Full ClientPrefs replacement compatible with your PlayState and NoteSpawner
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
    public static var noteSize:Int = 80; // size for NoteSpawner
    public static var laneColors:Array<Int> = [FlxColor.RED, FlxColor.GREEN, FlxColor.YELLOW, FlxColor.BLUE];

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
    // 💖 RUNTIME VARIABLES
    // =========================
    public static var health:Float = 1.0; // 0 to 2
    public static var score:Int = 0;
    public static var combo:Int = 0;
    public static var misses:Int = 0;

    // =========================
    // 📱 MOBILE INPUT OPTIONS
    // =========================
    public static var mobileLaneTiles:Bool = true;
    public static var mobileDPad:Bool = false;
    public static var mobileCustomDPad:Bool = false;
    public static var mobileCustomDPadPosition:Bool = false;
    public static var mobileClickOnNotePosition:Bool = true;
    public static var keyboardMode:Bool = false;

    // Use official FNF mobile note layout (centered & spaced)
    public static var mobileOfficialLayout:Bool = true;

    // =========================
    // 🔧 DEBUG / TESTING
    // =========================
    public static var debugMode:Bool = false;
    public static var showHitboxes:Bool = false;

    // =========================
    // 🖼 IMAGE / SPRITE OPTIONS
    // =========================
    public static var useNoteImage:Bool = false;
    public static var noteImage:String = "note.png"; // path for NoteSpawner

    // =========================
    // 🔄 RESET FUNCTION
    // =========================
    public static function reset():Void
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
        noteSize = 80;
        laneColors = [FlxColor.RED, FlxColor.GREEN, FlxColor.YELLOW, FlxColor.BLUE];

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

        // Runtime
        health = 1.0;
        score = 0;
        combo = 0;
        misses = 0;

        // Mobile
        mobileLaneTiles = true;
        mobileDPad = false;
        mobileCustomDPad = false;
        mobileCustomDPadPosition = false;
        mobileClickOnNotePosition = true;
        keyboardMode = false;
        mobileOfficialLayout = true;

        // Debug
        debugMode = false;
        showHitboxes = false;

        // Image
        useNoteImage = false;
        noteImage = "note.png";
    }
}
