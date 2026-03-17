package Objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Note extends FlxSprite
{
    public var lane:Int;     // 0-3
    public var hit:Bool = false;  // whether note has been hit
    public var judged:Bool = false; // to avoid double scoring

    public function new(x:Float, y:Float, lane:Int)
    {
        super(x, y);
        this.lane = lane;

        makeGraphic(80, 80, FlxColor.BLUE);
        centerOffsets();
    }

    // Call when the note is hit
    public function hitNote():Void
    {
        hit = true;
        judged = true;
        // Add visual feedback here if needed
    }

    // Call when note is missed
    public function missNote():Void
    {
        hit = true;
        judged = true;
        // Add miss visual feedback here if needed
    }
}
