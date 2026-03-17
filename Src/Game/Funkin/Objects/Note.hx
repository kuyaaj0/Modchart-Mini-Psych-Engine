package Game.Funkin.Objects;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import Backend.Settings as ClientPrefs;
import Backend.Utils.CoolUtil;
import Backend.Timing.Conductor;

// =========================
// NOTE DIRECTION ENUM
// =========================
enum Direction {
    LEFT;
    DOWN;
    UP;
    RIGHT;
}

// =========================
// NOTE CLASS
// =========================
class Note extends FlxSprite {
    public var noteData:Int;          // Lane index or chart ID
    public var strumTime:Float;       // Time when the note should be hit
    public var isSustainNote:Bool;    // If it has a hold/tail
    public var sustainLength:Float;   // Tail length in pixels
    public var tail:Array<FlxSprite>; // Holds tail segments
    public var direction:Direction;   // Arrow direction
    public var speed:Float;           // Pixels per second
    public var hit:Bool;              // If note has been hit

    public var texture:String;        // Optional image for the note

    // =========================
    // CONSTRUCTOR
    // =========================
    public function new(strumTime:Float, noteData:Int, direction:Direction, 
                        ?isSustain:Bool=false, ?sustainLength:Float=0, ?texture:String=null) {
        super();
        this.strumTime = strumTime;
        this.noteData = noteData;
        this.direction = direction;
        this.isSustainNote = isSustain;
        this.sustainLength = sustainLength;
        this.hit = false;
        this.speed = 200; // Default speed
        this.texture = texture;

        // =========================
        // Set note head graphic
        // =========================
        if(texture != null) {
            loadGraphic(texture);
        } else {
            var color:Int;
            switch(direction) {
                case LEFT: color = FlxColor.RED;
                case DOWN: color = FlxColor.BLUE;
                case UP: color = FlxColor.GREEN;
                case RIGHT: color = FlxColor.PURPLE;
            }
            makeGraphic(40, 40, color);
        }

        // Position based on lane
        x = 100 + noteData * 60;
        y = -50;

        // =========================
        // Create tail if sustain note
        // =========================
        if(isSustainNote && sustainLength > 0) {
            tail = [];
            var tailSegments:Int = Std.int(sustainLength / height);
            for(i in 0...tailSegments) {
                var tailPiece:FlxSprite;
                if(texture != null) {
                    tailPiece = new FlxSprite(x, y + height + i * height);
                    tailPiece.loadGraphic(texture);
                } else {
                    tailPiece = new FlxSprite(x, y + height + i * height);
                    tailPiece.makeGraphic(40, height, color);
                }
                tailPiece.lane = noteData;
                tailPiece.hit = false;
                tail.push(tailPiece);
            }
        }
    }

    // =========================
    // UPDATE NOTE POSITION
    // =========================
    public function update(elapsed:Float, downScroll:Bool=true, scrollSpeed:Float=1):Void {
        super.update(elapsed);
        if(hit) return;

        // Movement logic
        y += (downScroll ? 1 : -1) * speed * elapsed * scrollSpeed;

        // Tail follows head
        if(tail != null) {
            for(i in 0...tail.length) {
                tail[i].y = y + height + i * height;
                tail[i].x = x;
            }
        }
    }

    // =========================
    // CHECK IF NOTE MISSED
    // =========================
    public function isMissed(hitLine:Float, margin:Float=50):Bool {
        return (ClientPrefs.downScroll && y > hitLine + margin) || 
               (!ClientPrefs.downScroll && y < hitLine - margin);
    }

    // =========================
    // DESTROY NOTE AND TAIL
    // =========================
    public function destroyNote():Void {
        hit = true;
        if(tail != null) {
            for(piece in tail) {
                if(piece != null) FlxG.state.remove(piece);
            }
            tail = null;
        }
        FlxG.state.remove(this);
    }
}

// =========================
// NOTE SPAWNER CLASS
// =========================
class NoteSpawner {
    public var playerNotes:Array<Note>;
    public var opponentNotes:Array<Note>;
    public var playerStrums:Array<FlxSprite>;
    public var opponentStrums:Array<FlxSprite>;
    public var spawnTimer:Float;

    public function new(playerStrums:Array<FlxSprite>, opponentStrums:Array<FlxSprite>) {
        this.playerStrums = playerStrums;
        this.opponentStrums = opponentStrums;
        this.playerNotes = [];
        this.opponentNotes = [];
        this.spawnTimer = 0;
    }

    // =========================
    // SPAWN PLAYER NOTE
    // =========================
    public function spawnPlayerNote(lane:Int, strumTime:Float, ?isSustain:Bool=false, ?sustainLength:Float=0, ?texture:String=null):Note {
        if(lane < 0 || lane >= playerStrums.length) return null;
        var note = new Note(strumTime, lane, Direction.values()[lane], isSustain, sustainLength, texture);
        playerNotes.push(note);
        FlxG.state.add(note);
        if(note.tail != null) for(piece in note.tail) FlxG.state.add(piece);
        return note;
    }

    // =========================
    // SPAWN RANDOM PLAYER NOTE
    // =========================
    public function spawnRandomPlayerNote():Void {
        var lane = Math.floor(Math.random() * playerStrums.length);
        spawnPlayerNote(lane, Conductor.songPosition);
    }

    // =========================
    // SPAWN OPPONENT NOTE
    // =========================
    public function spawnOpponentNote(lane:Int, strumTime:Float, ?isSustain:Bool=false, ?sustainLength:Float=0, ?texture:String=null):Note {
        if(lane < 0 || lane >= opponentStrums.length) return null;
        var note = new Note(strumTime, lane, Direction.values()[lane], isSustain, sustainLength, texture);
        opponentNotes.push(note);
        FlxG.state.add(note);
        if(note.tail != null) for(piece in note.tail) FlxG.state.add(piece);
        return note;
    }

    // =========================
    // SPAWN RANDOM OPPONENT NOTE
    // =========================
    public function spawnRandomOpponentNote():Void {
        var lane = Math.floor(Math.random() * opponentStrums.length);
        spawnOpponentNote(lane, Conductor.songPosition);
    }

    // =========================
    // UPDATE ALL NOTES
    // =========================
    public function update(elapsed:Float):Void {
        for(note in playerNotes) {
            if(note != null) note.update(elapsed, ClientPrefs.downScroll, ClientPrefs.scrollSpeed);
            if(note.isMissed(playerStrums[note.noteData].y)) handleMiss(note);
        }

        for(note in opponentNotes) {
            if(note != null) note.update(elapsed, ClientPrefs.downScroll, ClientPrefs.scrollSpeed);
        }
    }

    // =========================
    // HIT NOTE
    // =========================
    public function hitPlayerNote(lane:Int):Void {
        var closest:Note = null;
        var minDist:Float = 9999;
        for(note in playerNotes) {
            if(note.noteData == lane && !note.hit) {
                var dist = Math.abs(note.y - playerStrums[lane].y);
                if(dist < minDist) {
                    closest = note;
                    minDist = dist;
                }
            }
        }
        if(closest != null) {
            closest.destroyNote();
            playerNotes.remove(closest);
            ClientPrefs.score += 100;
            ClientPrefs.health += 0.02;
            ClientPrefs.health = CoolUtil.clamp(ClientPrefs.health, 0, 2);
        }
    }

    // =========================
    // HANDLE MISSED NOTES
    // =========================
    private function handleMiss(note:Note):Void {
        note.destroyNote();
        playerNotes.remove(note);
        ClientPrefs.health -= 0.05;
        ClientPrefs.health = CoolUtil.clamp(ClientPrefs.health, 0, 2);
        trace("Missed note lane: " + note.noteData);
    }
}
