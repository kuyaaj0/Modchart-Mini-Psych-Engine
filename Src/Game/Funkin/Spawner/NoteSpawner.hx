package Game.Funkin.Objects;

import flixel.FlxG;
import flixel.FlxSprite;
import Backend.Settings as ClientPrefs;
import Backend.Utils.CoolUtil;
import Backend.Timing.Conductor;

class NoteSpawner {
    public var playerNotes:Array<StrumNote> = [];
    public var opponentNotes:Array<StrumNote> = [];

    public var playerStrums:Array<FlxSprite>;
    public var opponentStrums:Array<FlxSprite>;

    public function new(playerStrums:Array<FlxSprite>, opponentStrums:Array<FlxSprite>) {
        this.playerStrums = playerStrums;
        this.opponentStrums = opponentStrums;
    }

    // =========================
    // SPAWN
    // =========================
    public function spawnPlayer(lane:Int, time:Float, ?hold:Bool=false, ?len:Float=0):Void {
        var note = new StrumNote(time, lane, Direction.values()[lane], hold, len);
        playerNotes.push(note);

        FlxG.state.add(note);
        if(note.tail != null) for(t in note.tail) FlxG.state.add(t);
    }

    public function spawnOpponent(lane:Int, time:Float):Void {
        var note = new StrumNote(time, lane, Direction.values()[lane]);
        opponentNotes.push(note);

        FlxG.state.add(note);
    }

    // =========================
    // UPDATE
    // =========================
    public function update(elapsed:Float):Void {
        updatePlayer(elapsed);
        updateOpponent(elapsed);
    }

    function updatePlayer(elapsed:Float):Void {
        for(note in playerNotes) {
            note.updateNote(elapsed);

            if(note.isLate(playerStrums[note.noteData].y)) {
                miss(note);
            }
        }
    }

    function updateOpponent(elapsed:Float):Void {
        for(note in opponentNotes) {
            note.updateNote(elapsed);
        }
    }

    // =========================
    // INPUT
    // =========================
    public function pressLane(lane:Int, isHolding:Bool):Void {
        var hitNote:StrumNote = null;

        for(note in playerNotes) {
            if(note.noteData == lane && !note.hit) {
                if(note.canBeHit(playerStrums[lane].y)) {
                    hitNote = note;
                    break;
                }
            }
        }

        if(hitNote != null) {
            handleHit(hitNote, isHolding);
        } else {
            if(!ClientPrefs.ghostTapping) {
                ClientPrefs.health -= 0.05;
            }
        }
    }

    function handleHit(note:StrumNote, isHolding:Bool):Void {
        note.hit = true;

        if(note.isSustainNote) {
            note.beingHeld = true;
        } else {
            note.destroyNote();
            playerNotes.remove(note);
        }

        ClientPrefs.score += 100;
        ClientPrefs.health = CoolUtil.clamp(ClientPrefs.health + 0.02, 0, 2);
    }

    // =========================
    // HOLD LOGIC
    // =========================
    public function updateHold(lane:Int, isHolding:Bool):Void {
        for(note in playerNotes) {
            if(note.noteData == lane && note.isSustainNote && note.beingHeld) {

                if(!isHolding) {
                    miss(note);
                }

                if(note.tail == null || note.tail.length == 0) {
                    note.destroyNote();
                    playerNotes.remove(note);
                }
            }
        }
    }

    // =========================
    // MISS
    // =========================
    function miss(note:StrumNote):Void {
        note.destroyNote();
        playerNotes.remove(note);

        ClientPrefs.health = CoolUtil.clamp(ClientPrefs.health - 0.05, 0, 2);
    }
}
