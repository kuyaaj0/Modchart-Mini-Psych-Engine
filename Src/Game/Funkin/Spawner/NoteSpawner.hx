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

    // Hit timing window
    public var hitWindow:Float = 45;

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
        spawnTimer += elapsed;

        for(note in notes)
        {
            if(note.hit) continue;

            // Move note
            note.y += (ClientPrefs.downScroll ? 1 : -1) * noteSpeed * elapsed * ClientPrefs.scrollSpeed;

            // Miss detection
            var hitLine = playerStrums[note.lane].y;
            if((ClientPrefs.downScroll && note.y > hitLine + hitWindow) || (!ClientPrefs.downScroll && note.y < hitLine - hitWindow))
            {
                missNote(note);
            }

            // Optional: remove off-screen notes
            if(note.y < -noteSize*2 || note.y > FlxG.height + noteSize*2)
            {
                removeNote(note);
            }
        }
    }

    // =========================
    // SPAWN RANDOM NOTE (FOR TESTING)
    // =========================
    public function spawnRandomNote():Void
    {
        var lane = Math.floor(Math.random() * playerStrums.length);
        var tailLength = Math.floor(Math.random() * 3); // random tail 0-2
        spawnNoteOnStep(lane, tailLength);
    }

    // =========================
    // SPAWN NOTE ON STEP / BEAT
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
    // REMOVE NOTE
    // =========================
    private function removeNote(note:FlxSprite):Void
    {
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
    }

    // =========================
    // MISS NOTE HANDLER
    // =========================
    private function missNote(note:FlxSprite):Void
    {
        removeNote(note);

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
            removeNote(closest);

            // Score & health
            ClientPrefs.score += 100;
            ClientPrefs.health += 0.02;
            ClientPrefs.health = Math.max(0, Math.min(ClientPrefs.health, 2));

            // Optional: visual feedback
            var strum = playerStrums[lane];
            strum.color = FlxColor.WHITE;
            FlxTween.color(strum, strum.color, getLaneColor(lane), 0.15);
        }
    }

    // =========================
    // GET LANE COLOR
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
    // DEBUG: REMOVE ALL NOTES
    // =========================
    public function clearAllNotes():Void
    {
        for(note in notes)
            removeNote(note);

        notes = [];
    }
}
