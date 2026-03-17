package Game.Funkin.Objects;

import flixel.FlxG;
import flixel.group.FlxTypedGroup;
import flixel.math.FlxMath;
import Backend.Timing.Conductor;

/**
 * NoteSpawner
 * Handles spawning and updating notes during gameplay
 */
class NoteSpawner
{
    public var notes:FlxTypedGroup<Note>;
    public var laneX:Array<Float>; // X positions for each lane
    public var hitZoneY:Float; // Y position where player hits notes
    public var speedFactor:Float = 0.5; // multiplier for note speed

    public function new(?hitZoneY:Float = 400)
    {
        notes = new FlxTypedGroup<Note>();
        this.hitZoneY = hitZoneY;

        // Default lane positions (LEFT, DOWN, UP, RIGHT)
        laneX = [100, 160, 220, 280];
    }

    /**
     * Spawn a note
     * @param strumTime - time in ms when note should be hit
     * @param noteData - lane index (0=LEFT,1=DOWN,2=UP,3=RIGHT)
     * @param holdLength - optional hold length in ms for sustain notes
     */
    public function spawnNote(strumTime:Float, noteData:Int, ?holdLength:Float = 0):Note
    {
        var n = new Note();
        n.strumTime = strumTime;
        n.noteData = noteData;
        n.mustPress = true; // player note
        n.isSustainNote = holdLength > 0;
        n.sustainLength = holdLength;

        n.x = laneX[noteData];
        n.y = hitZoneY - ((strumTime - Conductor.songPosition) * speedFactor);

        if(n.isSustainNote)
        {
            // Create tail for sustain note
            var tail = new Note();
            tail.isSustainNote = true;
            tail.parent = n;
            tail.x = n.x;
            tail.y = n.y;
            n.tail.push(tail);
            notes.add(tail);
        }

        notes.add(n);
        return n;
    }

    /**
     * Update all notes
     */
    public function update(elapsed:Float):Void
    {
        for(n in notes.members)
        {
            if(n == null) continue;

            // Update Y position based on Conductor
            var timeToHit = n.strumTime - Conductor.songPosition;
            n.y = hitZoneY - (timeToHit * speedFactor);

            // Update tail position
            for(tail in n.tail)
            {
                tail.y = n.y + n.height; // simple tail placement
            }

            // Remove off-screen or passed notes
            if(n.y > 600) // screen bottom
            {
                notes.remove(n, true);
            }
        }
    }

    /**
     * Simple hit detection
     * @param note - note to check
     * @param tolerance - how far from hit zone is allowed
     */
    public function canHit(note:Note, ?tolerance:Float = 45):Bool
    {
        return Math.abs(note.y - hitZoneY) <= tolerance;
    }

    /**
     * Remove a note (hit or miss)
     */
    public function removeNote(note:Note):Void
    {
        if(note.tail != null)
        {
            for(t in note.tail)
                notes.remove(t, true);
        }
        notes.remove(note, true);
    }
}
