package Game.Funkin.Objects;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import Backend.Settings as ClientPrefs;

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
    public var noteData:Int;
    public var strumTime:Float;
    public var isSustainNote:Bool;
    public var sustainLength:Float;
    public var tail:Array<FlxSprite>;
    public var direction:Direction;
    public var speed:Float = 200;
    public var hit:Bool = false;
    public var beingHeld:Bool = false;
    public var texture:String;

    public function new(strumTime:Float, noteData:Int, direction:Direction,
        ?isSustain:Bool=false, ?sustainLength:Float=0, ?texture:String=null)
    {
        super();

        this.strumTime = strumTime;
        this.noteData = noteData;
        this.direction = direction;
        this.isSustainNote = isSustain;
        this.sustainLength = sustainLength;
        this.texture = texture;

        setupGraphic();
        setupPosition();
        createTail();
    }

    function setupGraphic():Void {
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
    }

    function setupPosition():Void {
        x = 100 + noteData * 60;
        y = -100;
    }

    function createTail():Void {
        if(!isSustainNote || sustainLength <= 0) return;

        tail = [];
        var segments = Std.int(sustainLength / height);

        for(i in 0...segments) {
            var piece = new FlxSprite(x, y + height + i * height);
            piece.makeGraphic(40, height, FlxColor.WHITE);
            tail.push(piece);
        }
    }

    public function updateNote(elapsed:Float):Void {
        if(hit && !isSustainNote) return;

        y += (ClientPrefs.downScroll ? 1 : -1) * speed * elapsed * ClientPrefs.scrollSpeed;

        updateTail();
    }

    function updateTail():Void {
        if(tail == null) return;

        for(i in 0...tail.length) {
            tail[i].x = x;
            tail[i].y = y + height + (i * height);
        }
    }

    public function canBeHit(strumY:Float, window:Float=50):Bool {
        return Math.abs(y - strumY) <= window;
    }

    public function isLate(strumY:Float):Bool {
        return (ClientPrefs.downScroll && y > strumY + 60)
            || (!ClientPrefs.downScroll && y < strumY - 60);
    }

    public function destroyNote():Void {
        hit = true;

        if(tail != null) {
            for(t in tail) FlxG.state.remove(t);
            tail = null;
        }

        FlxG.state.remove(this);
    }
}
