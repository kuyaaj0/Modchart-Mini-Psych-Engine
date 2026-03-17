package Backend;

import flixel.FlxG;
import haxe.ds.StringMap;

/**
 * Handles customizable keybinds
 */
class KeyBindManager
{
    public static var binds:StringMap<Array<Int>> = new StringMap();

    /**
     * Initialize default keybinds
     */
    public static function init()
    {
        binds.set("left",  [65, 37]);  // A, LEFT ARROW
        binds.set("down",  [83, 40]);  // S, DOWN
        binds.set("up",    [87, 38]);  // W, UP
        binds.set("right", [68, 39]);  // D, RIGHT

        binds.set("accept", [13, 32]); // ENTER, SPACE
        binds.set("back",   [27]);     // ESC
    }

    /**
     * Change keybind
     */
    public static function setBind(action:String, keys:Array<Int>)
    {
        binds.set(action, keys);
    }

    /**
     * Get keybind
     */
    public static function getBind(action:String):Array<Int>
    {
        return binds.get(action);
    }

    /**
     * Check if action is pressed
     */
    public static function isPressed(action:String):Bool
    {
        var keys = binds.get(action);
        if (keys == null) return false;

        for (key in keys)
        {
            if (FlxG.keys.checkStatus(key, JUST_PRESSED) || FlxG.keys.checkStatus(key, PRESSED))
                return true;
        }

        return false;
    }

    /**
     * Check just pressed
     */
    public static function justPressed(action:String):Bool
    {
        var keys = binds.get(action);
        if (keys == null) return false;

        for (key in keys)
        {
            if (FlxG.keys.checkStatus(key, JUST_PRESSED))
                return true;
        }

        return false;
    }

    /**
     * Check released
     */
    public static function justReleased(action:String):Bool
    {
        var keys = binds.get(action);
        if (keys == null) return false;

        for (key in keys)
        {
            if (FlxG.keys.checkStatus(key, JUST_RELEASED))
                return true;
        }

        return false;
    }
}
