package backend.Input;

import flixel.FlxG;

/**
 * Main input system
 */
class InputManager
{
    public static function init()
    {
        KeyBindManager.init();
    }

    /**
     * Update input (optional for future use)
     */
    public static function update()
    {
        // future: mobile, controller, etc.
    }

    // --- Gameplay controls ---

    public static function left():Bool
    {
        return KeyBindManager.isPressed("left");
    }

    public static function down():Bool
    {
        return KeybindManager.isPressed("down");
    }

    public static function up():Bool
    {
        return KeyBindManager.isPressed("up");
    }

    public static function right():Bool
    {
        return KeyBindManager.isPressed("right");
    }

    public static function leftPress():Bool
    {
        return KeyBindManager.justPressed("left");
    }

    public static function downPress():Bool
    {
        return KeyBindManager.justPressed("down");
    }

    public static function upPress():Bool
    {
        return KeyBindManager.justPressed("up");
    }

    public static function rightPress():Bool
    {
        return KeyBindManager.justPressed("right");
    }

    public static function accept():Bool
    {
        return KeyBindManager.justPressed("accept");
    }

    public static function back():Bool
    {
        return KeyBindManager.justPressed("back");
    }
}
