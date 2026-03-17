package Game.Funkin.Spawner;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import Backend.Settings as ClientPrefs;
import Backend.Timing.Conductor;

class NoteSpawner
{
    // =========================
    // SPAWNER SETTINGS
    // =========================
    public var playerStrums:Array<FlxSprite>;
    public var notes:Array<FlxSprite>;
    public var spawnTimer:Float = 0;

    // =========================
    // NOTE CONFIG
    // =========================
    public var noteSpeed:Float = 300; // pixels per second
    public var laneWidth:Float = 120;
    public var noteSize:Int = 80;

    public function new(playerStrums:Array<FlxSprite>)
    {
        this.playerStrums = playerStrums;
        this.notes = [];
    }

    // =========================
    // UPDATE SPAWNER (CALL EVERY FRAME)
    // =========================
    public function update(elapsed:Float):Void
    {
        // Update all notes
        for(note in notes)
        {
            if(note.hit) continue;

            // Move note
            note.y += (ClientPrefs.downScroll ? 1 : -1) * noteSpeed * elapsed * ClientPrefs.scrollSpeed;

            // Miss detection
            var hitLine = playerStrums[note.lane].y;
            if((ClientPrefs.downScroll && note.y > hitLine + 50) || (!ClientPrefs.downScroll && note.y < hitLine - 50))
            {
                missNote(note);
            }
        }
    }

    // =========================
    // SPAWN RANDOM NOTE (TEST)
    // =========================
    public function spawnRandomNote():Void
    {
        var lane = Math.floor(Math.random() * playerStrums.length);
        var startY = ClientPrefs.downScroll ? -noteSize : FlxG.height + noteSize;
        var color = getLaneColor(lane);

        var note = createNote(playerStrums[lane].x, startY, lane, color, 0);
        addNote(note);
    }

    // =========================
    // SPAWN NOTE ON BEAT (SYNCED TO STEP)
    // =========================
    public function spawnNoteOnStep(lane:Int, tailLength:Int = 0):Void
    {
        if(lane < 0 || lane >= playerStrums.length) return;

        var startY = ClientPrefs.downScroll ? -noteSize : FlxG.height + noteSize;
        var color = getLaneColor(lane);

        var note = createNote(playerStrums[lane].x, startY, lane, color, tailLength);
        addNote(note);
    }

    // =========================
    // CREATE NOTE INSTANCE
    // =========================
    private function createNote(x:Float, y:Float, lane:Int, color:Int, tailLength:Int):FlxSprite
    {
        var note = new FlxSprite(x, y);
        note.makeGraphic(noteSize, noteSize, color);
        note.lane = lane;
        note.hit = false;

        // Tail (hold notes)
        if(tailLength > 0)
        {
            note.tail = [];
            for(i in 1...tailLength + 1)
            {
                var tailPiece = new FlxSprite(x, y + i * noteSize);
                tailPiece.makeGraphic(noteSize, noteSize, FlxColor.DARK_BLUE);
                tailPiece.lane = lane;
                tailPiece.hit = false;
                note.tail.push(tailPiece);
            }
        }

        return note;
    }

    // =========================
    // ADD NOTE TO LIST
    // =========================
    private function addNote(note:FlxSprite):Void
    {
        notes.push(note);
        FlxG.state.add(note);

        // Add tail pieces if any
        if(note.tail != null)
        {
            for(piece in note.tail)
                FlxG.state.add(piece);
        }
    }

    // =========================
    // MISS NOTE HANDLER
    // =========================
    private function missNote(note:FlxSprite):Void
    {
        note.hit = true;
        notes.remove(note);
        FlxG.state.remove(note);

        // Remove tail
        if(note.tail != null)
        {
            for(piece in note.tail)
            {
                piece.hit = true;
                FlxG.state.remove(piece);
            }
        }

        // Penalty
        ClientPrefs.health -= 0.05;
        ClientPrefs.health = Math.max(0, Math.min(ClientPrefs.health, 2));

        trace("Missed note on lane: " + note.lane);
    }

    // =========================
    // HIT NOTE (CALL WHEN INPUT)
    // =========================
    public function hitNoteInLane(lane:Int):Void
    {
        var closest:FlxSprite = null;
        var minDistance = 9999;

        for(note in notes)
        {
            if(note.lane == lane && !note.hit)
            {
                var dist = Math.abs(note.y - playerStrums[lane].y);
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
            notes.remove(closest);
            FlxG.state.remove(closest);

            // Remove tail pieces
            if(closest.tail != null)
            {
                for(piece in closest.tail)
                    FlxG.state.remove(piece);
            }

            // Score & health
            ClientPrefs.score += 100;
            ClientPrefs.health += 0.02;
            ClientPrefs.health = Math.max(0, Math.min(ClientPrefs.health, 2));
        }
    }

    // =========================
    // UTILITY: LANE COLORS
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
}
