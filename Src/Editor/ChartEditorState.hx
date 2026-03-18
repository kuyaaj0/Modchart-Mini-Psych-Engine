package Editor;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;

import Backend.Timing.Conductor;
import Editor.EditorButton;

class ChartEditorState extends FlxState
{
    // =========================
    // DATA
    // =========================
    var notes:Array<Dynamic> = [];
    var noteSprites:Array<FlxSprite> = [];

    // =========================
    // VISUALS
    // =========================
    var waveformGroup:FlxGroup;
    var beatLineGroup:FlxGroup;

    // =========================
    // SETTINGS
    // =========================
    var laneWidth:Int = 120;
    var startX:Int = 200;

    var snapStep:Float = 1;
    var currentHold:Bool = false;

    // =========================
    // TIMELINE
    // =========================
    var scrollY:Float = 0;

    // =========================
    // MUSIC
    // =========================
    var music:FlxSound;
    var isPlaying:Bool = false;

    // =========================
    // HOLD SYSTEM
    // =========================
    var holdStartTime:Float = 0;

    // =========================
    // UI
    // =========================
    var timeText:FlxText;
    var infoText:FlxText;

    override public function create()
    {
        super.create();

        Conductor.init(120);

        waveformGroup = new FlxGroup();
        beatLineGroup = new FlxGroup();

        add(waveformGroup);
        add(beatLineGroup);

        loadMusic();
        createUI();
        createButtons();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        handleScroll();
        handleInput();

        if(isPlaying && music != null)
            scrollY = music.time;

        Conductor.songPosition = scrollY;

        updateTimeline();
        drawWaveform();
        drawBeatLines();

        timeText.text = "Time: " + Std.int(scrollY);
        infoText.text = "Snap: " + snapStep + " | Hold: " + (currentHold ? "ON" : "OFF");
    }

    // =========================
    // MUSIC
    // =========================
    function loadMusic():Void
    {
        music = FlxG.sound.load("assets/music/song.ogg");
    }

    function togglePlay():Void
    {
        if(music == null) return;

        if(isPlaying)
        {
            music.pause();
            isPlaying = false;
        }
        else
        {
            music.play();
            isPlaying = true;
        }
    }

    // =========================
    // SCROLL
    // =========================
    function handleScroll():Void
    {
        if(!isPlaying)
        {
            if(FlxG.mouse.pressed)
                scrollY -= FlxG.mouse.deltaY;

            for(touch in FlxG.touches.list)
                if(touch.pressed)
                    scrollY -= touch.deltaY;
        }
    }

    // =========================
    // TIMELINE
    // =========================
    function updateTimeline():Void
    {
        for(i in 0...noteSprites.length)
        {
            var note = notes[i];
            var spr = noteSprites[i];

            spr.y = (note.time - scrollY) * 0.5 + 300;
        }
    }

    // =========================
    // 🎵 WAVEFORM
    // =========================
    function drawWaveform():Void
    {
        waveformGroup.clear();

        for(i in 0...80)
        {
            var t = scrollY + i * 20;

            var height = Math.sin(t * 0.01) * 40 + 40;

            var bar = new FlxSprite(startX - 40, i * 10);
            bar.makeGraphic(30, Std.int(height), FlxColor.GREEN);

            waveformGroup.add(bar);
        }
    }

    // =========================
    // 📏 BEAT LINES
    // =========================
    function drawBeatLines():Void
    {
        beatLineGroup.clear();

        var beat = 60000 / Conductor.bpm;

        for(i in -20...40)
        {
            var time = scrollY + i * beat;

            var y = (time - scrollY) * 0.5 + 300;

            var line = new FlxSprite(startX, y);

            // Strong beat
            if(i % 4 == 0)
                line.makeGraphic(500, 3, FlxColor.RED);
            else
                line.makeGraphic(500, 1, FlxColor.WHITE);

            beatLineGroup.add(line);
        }
    }

    // =========================
    // UI
    // =========================
    function createUI():Void
    {
        timeText = new FlxText(20, 20, 300, "", 20);
        add(timeText);

        infoText = new FlxText(20, 45, 400, "", 16);
        add(infoText);
    }

    // =========================
    // BUTTONS
    // =========================
    function createButtons():Void
    {
        add(new EditorButton(20, 80, "Play", togglePlay));
        add(new EditorButton(20, 140, "Save", saveChart));
        add(new EditorButton(20, 200, "Load", loadChart));

        add(new EditorButton(20, 260, "Hold", function() {
            currentHold = !currentHold;
        }));

        add(new EditorButton(20, 320, "Snap", function() {
            switch(snapStep)
            {
                case 1: snapStep = 0.5;
                case 0.5: snapStep = 0.25;
                default: snapStep = 1;
            }
        }));
    }

    // =========================
    // INPUT
    // =========================
    function handleInput():Void
    {
        for(touch in FlxG.touches.list)
        {
            var pos = touch.getWorldPosition();

            if(touch.justPressed)
                holdStartTime = getSnappedTime();

            if(touch.justReleased)
                placeNote(pos.x, holdStartTime, getSnappedTime());
        }

        if(FlxG.mouse.justPressed)
            holdStartTime = getSnappedTime();

        if(FlxG.mouse.justReleased)
            placeNote(FlxG.mouse.x, holdStartTime, getSnappedTime());

        if(FlxG.mouse.justPressedRight)
            removeNoteAt(FlxG.mouse.x, FlxG.mouse.y);
    }

    function getSnappedTime():Float
    {
        var beat = 60000 / Conductor.bpm;
        return Math.floor(scrollY / (beat * snapStep)) * (beat * snapStep);
    }

    // =========================
    // NOTES
    // =========================
    function placeNote(x:Float, start:Float, end:Float):Void
    {
        var lane = Std.int((x - startX) / laneWidth);
        if(lane < 0 || lane >= 4) return;

        var length = Math.max(0, end - start);

        var note = {
            time: start,
            lane: lane,
            hold: currentHold,
            length: currentHold ? length : 0
        };

        notes.push(note);

        var spr = new FlxSprite(startX + lane * laneWidth, 0);

        if(currentHold)
            spr.makeGraphic(80, Std.int(length * 0.5), FlxColor.BLUE);
        else
            spr.makeGraphic(80, 20, FlxColor.YELLOW);

        add(spr);
        noteSprites.push(spr);
    }

    function removeNoteAt(x:Float, y:Float):Void
    {
        for(i in 0...noteSprites.length)
        {
            var spr = noteSprites[i];

            if(spr.overlapsPoint(new FlxPoint(x, y)))
            {
                spr.kill();
                noteSprites.splice(i, 1);
                notes.splice(i, 1);
                break;
            }
        }
    }

    // =========================
    // SAVE / LOAD
    // =========================
    function saveChart():Void
    {
        var data = {
            bpm: Conductor.bpm,
            notes: notes
        };

        var json = haxe.Json.stringify(data, "\t");

        #if sys
        sys.io.File.saveContent("assets/data/chart.json", json);
        #end
    }

    function loadChart():Void
    {
        #if sys
        var raw = sys.io.File.getContent("assets/data/chart.json");
        var data:Dynamic = haxe.Json.parse(raw);

        clearNotes();

        for(note in data.notes)
        {
            placeNote(
                startX + note.lane * laneWidth,
                note.time,
                note.time + note.length
            );
        }
        #end
    }

    function clearNotes():Void
    {
        for(s in noteSprites)
            s.kill();

        notes = [];
        noteSprites = [];
    }
}
