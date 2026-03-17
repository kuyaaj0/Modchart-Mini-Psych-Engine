package Game.Funkin.Objects;

import Backend.Settings as ClientPrefs;
import Backend.Timing.Conductor;

class StrumNote extends Note {
    public var strumX:Float;
    public var strumY:Float;

    public function new(strumTime:Float, lane:Int, direction:Direction,
        ?isSustain:Bool=false, ?sustainLength:Float=0, ?texture:String=null)
    {
        super(strumTime, lane, direction, isSustain, sustainLength, texture);
    }

    public function followStrum(laneX:Array<Float>, strumY:Float):Void {
        this.strumX = laneX[noteData];
        this.strumY = strumY;

        x = strumX;

        var distance = (Conductor.songPosition - strumTime) * 0.45;
        if(!ClientPrefs.downScroll) distance *= -1;

        y = strumY + distance;

        updateTail();
    }
}
