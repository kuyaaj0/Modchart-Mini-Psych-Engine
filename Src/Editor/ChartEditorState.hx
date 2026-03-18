package Editor;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.sound.FlxSound;

import openfl.media.Sound;
import openfl.utils.ByteArray;

import haxe.Json;
import sys.io.File;

class ChartEditorState extends FlxState
{
    var song:FlxSound;
    var soundData:Sound;

    var waveform:FlxSprite;
    var grid:FlxGroup;
    var notes:FlxGroup;
    var lanes:FlxGroup;

    var bpm:Float = 120;
    var beatLength:Float;

    var strumLineY:Float = 500;
    var scrollSpeed:Float = 120;

    var snap:Int = 4;

    var laneWidth:Int = 120;
    var laneCount:Int = 4;

    var currentHold:FlxSprite;
    var holdStartTime:Float;

    override public function create()
    {
        super.create();

        FlxG.bgColor = FlxColor.BLACK;

        beatLength = 60 / bpm;

        soundData = Sound.fromFile("assets/music/test.ogg");
        song = FlxG.sound.load("assets/music/test.ogg");
        song.play();

        grid = new FlxGroup();
        add(grid);

        notes = new FlxGroup();
        add(notes);

        lanes = new FlxGroup();
        add(lanes);

        waveform = new FlxSprite(0, 0);
        waveform.makeGraphic(FlxG.width, 200, FlxColor.TRANSPARENT);
        add(waveform);

        generateWaveform();
        drawLanes();
        drawBeatGrid();
    }

    // =========================
    // 🎵 REAL WAVEFORM
    // =========================
    function generateWaveform()
    {
        var bytes = new ByteArray();
        soundData.extract(bytes, 44100 * 10);

        var gfx = waveform.pixels;
        gfx.fillRect(gfx.rect, FlxColor.TRANSPARENT);

        var samples = bytes.length / 4;
        var step = Math.floor(samples / FlxG.width);

        for(i in 0...FlxG.width)
        {
            var index = i * step * 4;
            if(index >= bytes.length) break;

            bytes.position = index;
            var sample:Float = bytes.readFloat();

            var height = Std.int(sample * 100);

            for(y in -height...height)
            {
                var drawY = 100 + y;
                if(drawY >= 0 && drawY < 200)
                    gfx.setPixel32(i, drawY, FlxColor.WHITE);
            }
        }

        waveform.dirty = true;
    }

    // =========================
    // 🎹 LANES
    // =========================
    function drawLanes()
    {
        lanes.clear();

        for(i in 0...laneCount)
        {
            var lane = new FlxSprite(i * laneWidth, 0);
            lane.makeGraphic(laneWidth - 2, FlxG.height, FlxColor.fromRGB(30,30,30));

            lane.ID = i;
            lanes.add(lane);
        }
    }

    // =========================
    // 🟩 GRID
    // =========================
    function drawBeatGrid()
    {
        grid.clear();

        var time:Float = 0;
        var id:Int = 0;

        while(time < 60)
        {
            var y = strumLineY - (time * scrollSpeed);

            var line = new FlxSprite(0, y).makeGraphic(FlxG.width, 2, FlxColor.GRAY);

            if(id % 4 == 0)
                line.color = FlxColor.WHITE;

            line.ID = id;
            grid.add(line);

            time += beatLength;
            id++;
        }
    }

    // =========================
    // 🎯 PLACE NOTE
    // =========================
    function placeNote(x:Float, y:Float)
    {
        var lane = Std.int(x / laneWidth);
        if(lane < 0 || lane >= laneCount) return;

        var songTime = (strumLineY - y) / scrollSpeed;

        var snapStep = beatLength / snap;
        var snapped = Math.round(songTime / snapStep) * snapStep;

        var note = new FlxSprite(lane * laneWidth + 20, strumLineY - snapped * scrollSpeed);
        note.makeGraphic(laneWidth - 40, 40, FlxColor.RED);

        note.ID = Std.int(snapped * 1000);
        note.alpha = lane;

        notes.add(note);
    }

    // =========================
    // ⏱️ HOLD NOTES
    // =========================
    function startHold(x:Float, y:Float)
    {
        var lane = Std.int(x / laneWidth);
        if(lane < 0 || lane >= laneCount) return;

        var songTime = (strumLineY - y) / scrollSpeed;

        currentHold = new FlxSprite(lane * laneWidth + 20, y);
        currentHold.makeGraphic(laneWidth - 40, 10, FlxColor.BLUE);

        holdStartTime = songTime;
        currentHold.alpha = lane;

        add(currentHold);
    }

    function updateHold(y:Float)
    {
        if(currentHold == null) return;

        currentHold.scale.y = Math.abs((currentHold.y - y) / 10);
    }

    function finishHold(x:Float, y:Float)
    {
        if(currentHold == null) return;

        var endTime = (strumLineY - y) / scrollSpeed;

        var length = endTime - holdStartTime;

        currentHold.ID = Std.int(holdStartTime * 1000);
        currentHold.scale.y = length * scrollSpeed / 10;

        notes.add(currentHold);
        currentHold = null;
    }

    // =========================
    // 💾 SAVE
    // =========================
    function saveChart()
    {
        var data:Array<Dynamic> = [];

        for(n in notes.members)
        {
            if(n != null)
            {
                data.push({
                    time: n.ID,
                    lane: Std.int(n.alpha),
                    sustain: Std.int(n.scale.y * 10)
                });
            }
        }

        var json = Json.stringify(data);
        File.saveContent("chart.json", json);
        trace("Chart Saved!");
    }

    // =========================
    // 📂 LOAD
    // =========================
    function loadChart()
    {
        if(!FileSystem.exists("chart.json")) return;

        var json = File.getContent("chart.json");
        var data:Array<Dynamic> = Json.parse(json);

        notes.clear();

        for(noteData in data)
        {
            var time = noteData.time / 1000;
            var lane = noteData.lane;

            var note = new FlxSprite(lane * laneWidth + 20, strumLineY - time * scrollSpeed);
            note.makeGraphic(laneWidth - 40, 40, FlxColor.RED);

            note.ID = noteData.time;
            note.alpha = lane;
            note.scale.y = noteData.sustain / 10;

            notes.add(note);
        }

        trace("Chart Loaded!");
    }

    // =========================
    // 🎮 UPDATE
    // =========================
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var songPos = song.time / 1000;

        for(n in notes.members)
        {
            if(n != null)
            {
                var noteTime = n.ID / 1000;
                n.y = strumLineY - ((noteTime - songPos) * scrollSpeed);
            }
        }

        // CLICK / TAP
        if(FlxG.mouse.justPressed)
        {
            startHold(FlxG.mouse.x, FlxG.mouse.y);
        }

        if(FlxG.mouse.pressed)
        {
            updateHold(FlxG.mouse.y);
        }

        if(FlxG.mouse.justReleased)
        {
            finishHold(FlxG.mouse.x, FlxG.mouse.y);
        }

        for(t in FlxG.touches.list)
        {
            if(t.justPressed)
                startHold(t.x, t.y);

            if(t.pressed)
                updateHold(t.y);

            if(t.justReleased)
                finishHold(t.x, t.y);
        }

        // SHORT TAP = normal note
        if(FlxG.mouse.justPressed && !FlxG.mouse.pressed)
        {
            placeNote(FlxG.mouse.x, FlxG.mouse.y);
        }

        // SAVE / LOAD
        if(FlxG.keys.justPressed.S)
            saveChart();

        if(FlxG.keys.justPressed.L)
            loadChart();
    }
}
