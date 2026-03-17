package Game.Funkin.Objects;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;

class NoteSplash extends FlxSprite
{
    public function new(x:Float, y:Float)
    {
        super(x, y);
        makeGraphic(60, 60, FlxColor.YELLOW);
        alpha = 0.8;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        alpha -= elapsed * 3;

        if(alpha <= 0)
            kill();
    }
}
