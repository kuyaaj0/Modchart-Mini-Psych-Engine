package Game.Funkin.Backend;

import Backend.Timing.Conductor;
import Game.Funkin.Objects.StrumNote;
import flixel.group.FlxTypedGroup;

/**
 * NoteSpawner
 * Handles spawning notes from chart data
 */
class NoteSpawner
{
    public var unspawnNotes:Array<Dynamic> = [];
    public var spawnedNotes:FlxTypedGroup<StrumNote>;

    public var spawnTime:Float = 1500; // ms before note appears

    public function new(group:FlxTypedGroup<StrumNote>)
    {
        spawnedNotes = group;
    }

    /**
     * Load chart data
     * Format: [strumTime, lane, mustPress]
     */
    public function loadChart(chart:Array<Dynamic>)
    {
        unspawnNotes = chart.copy();

        // Sort notes by time (important!)
        unspawnNotes.sort(function(a, b)
        {
            return Std.int(a[0] - b[0]);
        });
    }

    /**
     * Update spawner every frame
     */
    public function update()
    {
        var songPos = Conductor.songPosition;

        while (unspawnNotes.length > 0)
        {
            var noteData = unspawnNotes[0];

            var strumTime:Float = noteData[0];

            // Spawn when close enough
            if (strumTime - songPos < spawnTime)
            {
                spawnNote(noteData);
                unspawnNotes.shift();
            }
            else
                break;
        }
    }

    /**
     * Spawn a single note
     */
    function spawnNote(data:Array<Dynamic>)
    {
        var strumTime:Float = data[0];
        var lane:Int = data[1];
        var mustPress:Bool = data[2];

        var note = new StrumNote(strumTime, lane, mustPress);

        spawnedNotes.add(note);
    }

    /**
     * Clear all notes
     */
    public function clear()
    {
        unspawnNotes = [];

        if (spawnedNotes != null)
            spawnedNotes.clear();
    }
}
