package Game.Funkin.Objects;

import flixel.FlxSprite;

class Note extends FlxSprite
{
    public var strumTime:Float = 0;
    public var noteData:Int = 0;

    public var mustPress:Bool = false;

    public var canBeHit:Bool = false;
    public var tooLate:Bool = false;

    public var wasGoodHit:Bool = false;
    public var missed:Bool = false;

    public var isSustainNote:Bool = false;
    public var sustainLength:Float = 0;

    public var hitHealth:Float = 0.02;
    public var missHealth:Float = 0.05;

    public function new(strumTime:Float, noteData:Int, mustPress:Bool)
    {
        super();

        this.strumTime = strumTime;
        this.noteData = noteData;
        this.mustPress = mustPress;

        makeGraphic(80, 80);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var songPos = Conductor.songPosition;
        var safeZone = Conductor.safeZoneOffset;

        // Hit window
        canBeHit = (strumTime > songPos - safeZone &&
                    strumTime < songPos + safeZone);

        // Too late = miss
        if (strumTime < songPos - safeZone && !wasGoodHit)
        {
            tooLate = true;
        }
    }
}
