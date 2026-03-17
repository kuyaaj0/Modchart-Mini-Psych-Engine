package Mobile;

import flixel.FlxG;

class TouchNotes
{
    public var touchZones:Array<VirtualButton>; // Player touch zones

    public function new(notePositions:Array<{x:Float, y:Float, width:Float, height:Float}>)
    {
        touchZones = [];
        for(pos in notePositions)
        {
            var zone = new VirtualButton(pos.x, pos.y, pos.width, pos.height);
            touchZones.push(zone);
        }
    }

    // Update each frame
    public function update():Void
    {
        for(zone in touchZones)
        {
            zone.update();
        }
    }

    // Draw touch zones (optional for debug)
    public function draw():Void
    {
        for(zone in touchZones)
            zone.draw();
    }

    // Check if a specific note index is pressed
    public function isNotePressed(noteIndex:Int):Bool
    {
        if(noteIndex < 0 || noteIndex >= touchZones.length) return false;
        return touchZones[noteIndex].isPressed;
    }

    // Check if a note rectangle is pressed
    public function checkNoteClick(noteX:Float, noteY:Float, noteWidth:Float, noteHeight:Float):Bool
    {
        for(zone in touchZones)
        {
            if(zone.checkNoteClick(noteX, noteY, noteWidth, noteHeight))
                return true;
        }
        return false;
    }

    // Move a note zone to new position (for hold notes or lane rearranging)
    public function moveNoteZone(index:Int, newX:Float, newY:Float):Void
    {
        if(index < 0 || index >= touchZones.length) return;
        touchZones[index].moveTo(newX, newY);
    }
}
