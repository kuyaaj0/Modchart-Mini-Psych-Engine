package Game.Funkin.Objects;

import Backend.Settings as ClientPrefs;
import flixel.FlxSprite;

class StrumNote extends Note
{
    public var strumX:Float = 0;
    public var strumY:Float = 0;

    public var speed:Float = 1.0;

    public function new(strumTime:Float, lane:Int, mustPress:Bool)
    {
        super(strumTime, lane, mustPress);
    }

    /**
     * Makes the note follow the strum line (Mini Psych style)
     */
    public function followStrum(laneX:Array<Float>, strumY:Float, songPos:Float)
    {
        // Set base position
        this.strumX = laneX[noteData];
        this.strumY = strumY;

        // Apply lane position
        x = strumX;

        // Calculate distance from strum line
        var distance:Float = (songPos - strumTime) * 0.45 * speed;

        // Handle scroll direction
        if (!ClientPrefs.downScroll)
            distance *= -1;

        // Apply vertical position
        y = strumY + distance;
    }
}
