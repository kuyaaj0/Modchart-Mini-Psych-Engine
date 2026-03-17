package Game.Funkin.Spawners;

import Game.Funkin.Objects.Note;
import Game.Funkin.Objects.StrumNote;
import Backend.Timing.Conductor;
import flixel.FlxG;
import flixel.util.FlxTimer;

/**
 * NoteSpawner
 * Handles spawning notes during gameplay and modcharts
 */
class NoteSpawner
{
    public var spawnedNotes:Array<Note> = [];
    public var lastNoteByLane:Array<Note> = [];

    public function new()
    {
        // Initialize lastNoteByLane for 4 lanes (or mania)
        lastNoteByLane = [null, null, null, null];
    }

    /**
     * Spawn a note
     * @param strumTime: when the note should appear
     * @param lane: 0-left, 1-down, 2-up, 3-right
     * @param isPlayer: whether this is player note
     * @param isSustain: if this note is a hold
     * @param editorMode: optional, for chart editor
     */
    public function spawnNote(strumTime:Float, lane:Int, isPlayer:Bool = true, ?isSustain:Bool = false, ?editorMode:Bool = false)
    {
        var prevNote:Note = lastNoteByLane[lane];
        var newNote:Note = new Note(strumTime, lane, prevNote, isSustain, editorMode);

        newNote.mustPress = isPlayer;

        spawnedNotes.push(newNote);

        // Update last note reference for sustain linking
        if (isSustain)
            lastNoteByLane[lane] = newNote;
        else
            lastNoteByLane[lane] = null;

        return newNote;
    }

    /**
     * Spawn multiple notes for a chart line
     * @param notesData: array of lane indices (0-3) to spawn
     * @param strumTime: time for this line
     * @param isPlayer: player or opponent
     */
    public function spawnNotesLine(notesData:Array<Int>, strumTime:Float, isPlayer:Bool = true)
    {
        for (lane in notesData)
        {
            spawnNote(strumTime, lane, isPlayer);
        }
    }

    /**
     * Clear all notes
     */
    public function clearAll()
    {
        spawnedNotes = [];
        lastNoteByLane = [null, null, null, null];
    }

    /**
     * Update notes each frame
     * Should be called inside PlayState.update()
     */
    public function update(elapsed:Float)
    {
        for (note in spawnedNotes)
        {
            if (!note.spawned && Conductor.songPosition >= note.strumTime - 2000) // 2 sec pre-load
            {
                note.spawned = true;
                // Optional: add to PlayState display group here
                // PlayState.instance.add(note);
            }

            // Follow strum notes if needed
            if (note.spawned && note.mustPress)
            {
                // example: link to lane strum position
                // note.followStrumNote(PlayState.instance.playerStrums[note.noteData], Conductor.crochet, PlayState.instance.songSpeed);
            }
        }
    }
}
