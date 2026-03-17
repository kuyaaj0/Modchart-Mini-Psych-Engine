package Game.Funkin.Objects;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import backend.timing.Conductor;

enum Direction {
    LEFT;
    DOWN;
    UP;
    RIGHT;
}

class Note extends FlxSprite {
    public var noteData:Int;
    public var strumTime:Float;
    public var isSustainNote:Bool;
    public var sustainLength:Float;
    public var tail:FlxSprite;
    public var direction:Direction;

    public function new(strumTime:Float, noteData:Int, direction:Direction, ?isSustain:Bool=false, ?sustainLength:Float=0) {
        super();
        this.strumTime = strumTime;
        this.noteData = noteData;
        this.direction = direction;
        this.isSustainNote = isSustain;
        this.sustainLength = sustainLength;

        // Set color for testing
        var color:Int;
        switch(direction) {
            case LEFT: color = FlxColor.RED;
            case DOWN: color = FlxColor.BLUE;
            case UP: color = FlxColor.GREEN;
            case RIGHT: color = FlxColor.PURPLE;
        }

        makeGraphic(40, 40, color); // Arrow head rectangle
        x = 100 + noteData * 60; // lane position
        y = -50; // start above screen

        if (isSustainNote && sustainLength > 0) {
            tail = new FlxSprite(x, y + height);
            tail.makeGraphic(40, sustainLength, color);
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        // Move note down over time
        var speed:Float = 200; // pixels/sec
        y += speed * elapsed;
        if (tail != null) tail.y = y + height; // keep tail following head
    }
}

class NoteSpawner {
    public var notes:FlxGroup;

    public function new() {
        notes = new FlxGroup();
    }

    public function spawnNote(strumTime:Float, noteData:Int, direction:Direction, ?isSustain:Bool=false, ?sustainLength:Float=0):Note {
        var note = new Note(strumTime, noteData, direction, isSustain, sustainLength);
        notes.add(note);
        if (isSustain && note.tail != null) notes.add(note.tail);
        return note;
    }

    public function update(elapsed:Float):Void {
        notes.members.forEach(function(n) { if(n != null) n.update(elapsed); });
    }
}
