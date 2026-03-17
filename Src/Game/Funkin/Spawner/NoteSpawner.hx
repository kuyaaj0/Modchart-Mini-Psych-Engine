package Game.Funkin.Spawner;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import Backend.Settings as ClientPrefs;
import Backend.Timing.Conductor;
import Game.Funkin.Objects.Note;

class NoteSpawner
{
    // =========================
    // STRUMS
    // =========================
    public var playerStrums:Array<FlxSprite>;
    public var opponentStrums:Array<FlxSprite>;

    // =========================
    // NOTE LISTS
    // =========================
    public var playerNotes:Array<Note>;
    public var opponentNotes:Array<Note>;

    // =========================
    // SPAWNER SETTINGS
    // =========================
    public var spawnTimer:Float = 0;
    public var noteSpeed:Float = 300;
    public var noteSize:Int = 80;
    public var laneWidth:Float = 120;

    // =========================
    // IMAGE SPRITE OPTION
    // =========================
    public var useNoteImage:Bool = false;
    public var noteImage:String = "note.png"; // path to sprite image if needed

    public function new(playerStrums:Array<FlxSprite>, opponentStrums:Array<FlxSprite>)
    {
        this.playerStrums = playerStrums;
        this.opponentStrums = opponentStrums;
        this.playerNotes = [];
        this.opponentNotes = [];
    }

    // =========================
    // INIT (CALL AFTER PLAYSTATE CREATE)
    // =========================
    public function init():Void
    {
        spawnTimer = 0;
    }

    // =========================
    // UPDATE (CALL EVERY FRAME)
    // =========================
    public function update(elapsed:Float):Void
    {
        // =========================
        // PLAYER NOTES
        // =========================
        for(note in playerNotes)
        {
            if(note.hit) continue;

            note.update(elapsed, ClientPrefs.downScroll, ClientPrefs.scrollSpeed);

            if(note.isMissed(playerStrums[note.lane].y))
                missNote(note, true);
        }

        // =========================
        // OPPONENT NOTES
        // =========================
        for(note in opponentNotes)
        {
            if(note.hit) continue;

            note.update(elapsed, ClientPrefs.downScroll, ClientPrefs.scrollSpeed);

            // Optional: opponent notes can’t be missed
        }
    }

    // =========================
    // SPAWN RANDOM NOTES (TEST)
    // =========================
    public function spawnRandomPlayerNote():Void
    {
        var lane = Math.floor(Math.random() * playerStrums.length);
        var tailLength = Math.floor(Math.random() * 3); // optional random tail
        spawnNote(playerStrums, playerNotes, lane, tailLength, true);
    }

    public function spawnRandomOpponentNote():Void
    {
        var lane = Math.floor(Math.random() * opponentStrums.length);
        var tailLength = Math.floor(Math.random() * 2);
        spawnNote(opponentStrums, opponentNotes, lane, tailLength, false);
    }

    // =========================
    // SPAWN NOTE FUNCTION
    // =========================
    public function spawnNote(strums:Array<FlxSprite>, noteList:Array<Note>, lane:Int, tailLength:Int = 0, isPlayer:Bool = true):Void
    {
        if(lane < 0 || lane >= strums.length) return;

        var startY:Float = ClientPrefs.downScroll ? -noteSize : FlxG.height + noteSize;
        var noteColor:Int = getLaneColor(lane);

        var note = new Note(strums[lane].x, startY, lane, noteSize, noteSpeed, noteColor);

        // Use image sprite if enabled
        if(useNoteImage)
        {
            note.loadGraphic(noteImage);
        }
        else
        {
            note.makeGraphic(noteSize, noteSize, noteColor);
        }

        // Tail creation for hold notes
        if(tailLength > 0)
            note.createTail(tailLength, noteSize);

        // Add to PlayState
        noteList.push(note);
        FlxG.state.add(note.sprite);

        if(note.tail != null)
            for(piece in note.tail)
                FlxG.state.add(piece);
    }

    // =========================
    // HIT NOTE IN LANE
    // =========================
    public function hitNoteInLane(lane:Int, isPlayer:Bool = true):Void
    {
        var notesList = if(isPlayer) playerNotes else opponentNotes;
        var strums = if(isPlayer) playerStrums else opponentStrums;

        var closest:Note = null;
        var minDistance:Float = 9999;

        for(note in notesList)
        {
            if(note.lane == lane && !note.hit)
            {
                var dist = Math.abs(note.y - strums[lane].y);
                if(dist < minDistance)
                {
                    closest = note;
                    minDistance = dist;
                }
            }
        }

        if(closest != null)
        {
            closest.hit = true;
            removeNote(closest, notesList);

            // Optional: score/health handled by PlayState
        }
    }

    // =========================
    // MISS NOTE
    // =========================
    public function missNote(note:Note, isPlayer:Bool):Void
    {
        note.hit = true;
        removeNote(note, if(isPlayer) playerNotes else opponentNotes);
    }

    // =========================
    // REMOVE NOTE FUNCTION
    // =========================
    private function removeNote(note:Note, notesList:Array<Note>):Void
    {
        notesList.remove(note);
        FlxG.state.remove(note.sprite);

        if(note.tail != null)
            for(piece in note.tail)
                FlxG.state.remove(piece);
    }

    // =========================
    // LANE COLORS
    // =========================
    private function getLaneColor(lane:Int):Int
    {
        switch(lane)
        {
            case 0: return FlxColor.RED;
            case 1: return FlxColor.GREEN;
            case 2: return FlxColor.YELLOW;
            case 3: return FlxColor.BLUE;
            default: return FlxColor.WHITE;
        }
    }

    // =========================
    // OPTIONAL: SPAWN ON STEP/BEAT
    // =========================
    public function spawnOnStep(step:Int):Void
    {
        // Example: spawn note every 4 steps
        if(step % 4 == 0)
            spawnRandomPlayerNote();
    }

    public function spawnOnBeat(beat:Int):Void
    {
        // Example: flash notes or spawn optional notes
        for(note in playerNotes)
            note.flash(0.1);
    }
}
