package Game.Funkin.Spawner;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import Backend.Settings as ClientPrefs;
import Backend.Timing.Conductor;
import Game.Funkin.Objects.Note;
import Game.Funkin.Objects.StrumNote;

class NoteSpawner
{
    // =========================
    // STRUMS
    // =========================
    public var playerStrums:Array<FlxSprite>;
    public var opponentStrums:Array<FlxSprite>;

    // =========================
    // NOTES
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
    public var noteImage:String = "note.png";

    // =========================
    // DEBUG SETTINGS
    // =========================
    public var debugMode:Bool = true;

    public function new(playerStrums:Array<FlxSprite>, opponentStrums:Array<FlxSprite>)
    {
        this.playerStrums = playerStrums;
        this.opponentStrums = opponentStrums;
        this.playerNotes = [];
        this.opponentNotes = [];
    }

    // =========================
    // INIT (AFTER PLAYSTATE CREATE)
    // =========================
    public function init():Void
    {
        spawnTimer = 0;
        if(debugMode) trace("NoteSpawner initialized with " + playerStrums.length + " player strums.");
    }

    // =========================
    // UPDATE SPAWNER (EVERY FRAME)
    // =========================
    public function update(elapsed:Float, songPos:Float = 0):Void
    {
        // Update player notes
        for(note in playerNotes)
        {
            if(note.hit) continue;

            if(note instanceof StrumNote)
                (cast note, StrumNote).followStrum(getLanePositions(playerStrums), playerStrums[note.lane].y, songPos);

            note.update(elapsed, ClientPrefs.downScroll, ClientPrefs.scrollSpeed);

            if(note.isMissed(playerStrums[note.lane].y))
                missNote(note, true);
        }

        // Update opponent notes
        for(note in opponentNotes)
        {
            if(note.hit) continue;

            if(note instanceof StrumNote)
                (cast note, StrumNote).followStrum(getLanePositions(opponentStrums), opponentStrums[note.lane].y, songPos);

            note.update(elapsed, ClientPrefs.downScroll, ClientPrefs.scrollSpeed);

            // Optional: opponent notes cannot be missed
        }
    }

    // =========================
    // SPAWN RANDOM NOTES (TEST)
    // =========================
    public function spawnRandomPlayerNote():Void
    {
        var lane = Math.floor(Math.random() * playerStrums.length);
        var tailLength = Math.floor(Math.random() * 3); // 0-2 tails
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

        // Create note (can use StrumNote or Note)
        var note:Note;
        if(ClientPrefs.useStrumNote)
            note = new StrumNote(0, lane, isPlayer);
        else
            note = new Note(strums[lane].x, startY, lane, noteSize, noteSpeed, noteColor);

        // Optional image sprite
        if(useNoteImage)
            note.loadGraphic(noteImage);
        else
            note.makeGraphic(noteSize, noteSize, noteColor);

        // Create tails if hold note
        if(tailLength > 0)
            note.createTail(tailLength, noteSize);

        // Add note to PlayState
        noteList.push(note);
        FlxG.state.add(note.sprite);

        if(note.tail != null)
            for(piece in note.tail)
                FlxG.state.add(piece);

        if(debugMode)
            trace("Spawned " + (isPlayer ? "Player" : "Opponent") + " note in lane " + lane + " with tail " + tailLength);
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

            if(debugMode)
                trace("Hit note in lane " + lane);
        }
    }

    // =========================
    // MISS NOTE
    // =========================
    public function missNote(note:Note, isPlayer:Bool):Void
    {
        note.hit = true;
        removeNote(note, if(isPlayer) playerNotes else opponentNotes);

        if(debugMode)
            trace("Missed note in lane " + note.lane);
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
    // SPAWN ON STEP / BEAT
    // =========================
    public function spawnOnStep(step:Int):Void
    {
        if(step % 4 == 0)
            spawnRandomPlayerNote();
    }

    public function spawnOnBeat(beat:Int):Void
    {
        //for(note in playerNotes)
            //note.flash(0.1);
    }

    // =========================
    // CLEAR ALL NOTES
    // =========================
    public function clearAllNotes():Void
    {
        for(note in playerNotes) removeNote(note, playerNotes);
        for(note in opponentNotes) removeNote(note, opponentNotes);

        playerNotes = [];
        opponentNotes = [];

        if(debugMode) trace("Cleared all notes.");
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
    // UTILITY: GET LANE X POSITIONS
    // =========================
    private function getLanePositions(strums:Array<FlxSprite>):Array<Float>
    {
        return strums.map(function(s) return s.x);
    }
}
