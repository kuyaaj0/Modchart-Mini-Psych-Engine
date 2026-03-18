package Game.Funkin.UI;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;

class PauseButton extends FlxSprite
{
    public var onPause:Void->Void;

    public function new(x:Float, y:Float, callback:Void->Void)
    {
        super(x, y);

        makeGraphic(70, 70, FlxColor.WHITE);
        alpha = 0.6; // mobile-style transparent button

        onPause = callback;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var pressed:Bool = false;

        // Mouse
        if(FlxG.mouse.overlaps(this) && FlxG.mouse.justPressed)
            pressed = true;

        // Touch (mobile)
        for(touch in FlxG.touches.list)
        {
            if(touch.justPressed && overlapsPoint(touch.getWorldPosition()))
            {
                pressed = true;
                break;
            }
        }

        if(pressed && onPause != null)
            onPause();
    }
}
