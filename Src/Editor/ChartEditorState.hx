package Editor;

import flixel.*;
import flixel.group.*;
import flixel.util.*;
import flixel.text.FlxText;
import flixel.sound.FlxSound;

import openfl.media.Sound;
import openfl.utils.ByteArray;

import sys.FileSystem;
import sys.io.File;
import haxe.Json;

import Editor.EditorButton;

class ChartEditorState extends FlxState
{
    var song:FlxSound;
    var soundData:Sound;

    var waveform:FlxSprite;
    var grid:FlxGroup;
    var notes:FlxGroup;
    var sustains:FlxGroup;

    var bpm:Float = 120;
    var beatLength:Float;

    var strumLineY:Float = 500;
    var scrollSpeed:Float = 120;

    var lanes:Int = 4;
    var laneWidth:Float;

    var snap:Int = 4;

    var placingHold:Bool = false;
    var holdStartTime:Float = 0;
    var holdLane:Int = 0;

    // =========================
    // ZOOM
    // =========================
    var zoom:Float = 1.0;
    var minZoom:Float = 0.5;
    var maxZoom:Float = 3.0;
    var zoomSpeed:Float = 0.1;

    // =========================
    // UI BUTTONS
    // =========================
    var zoomInBtn:EditorButton;
    var zoomOutBtn:EditorButton;
    var saveBtn:EditorButton;
    var loadBtn:EditorButton;
    var pauseBtn:EditorButton;

    var isPaused:Bool = false;

    override public function create()
    {
        super.create();

        FlxG.bgColor = FlxColor.BLACK;

        beatLength = 60 / bpm;
        laneWidth = FlxG.width / lanes;

        // Load music
        soundData = Sound.fromFile("assets/music/test.ogg");
        song = FlxG.sound.load("assets/music/test.ogg");
        song.play();

        grid = new FlxGroup();
        notes = new FlxGroup();
        sustains = new FlxGroup();

        add(grid);
        add(sustains);
        add(notes);

        waveform = new FlxSprite(0, 0);
        waveform.makeGraphic(FlxG.width, 200, FlxColor.TRANSPARENT);
        add(waveform);

        generateWaveform();
        drawGrid();

        // =========================
        // ADD BUTTONS
        // =========================
        zoomInBtn = new EditorButton(20, 20, 50, 40, "+", function() {
            zoom = Math.min(maxZoom, zoom + zoomSpeed);
        });
        zoomOutBtn = new EditorButton(80, 20, 50, 40, "-", function() {
            zoom = Math.max(minZoom, zoom - zoomSpeed);
        });
        saveBtn = new EditorButton(140, 20, 80, 40, "Save", saveChart);
        loadBtn = new EditorButton(230, 20, 80, 40, "Load", loadChart);
        pauseBtn = new EditorButton(320, 20, 80, 40, "Pause", togglePause);

        add(zoomInBtn);
        add(zoomOutBtn);
        add(saveBtn);
        add(loadBtn);
        add(pauseBtn);
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

            var h = Std.int(sample * 100 * zoom); // apply zoom

            for(y in -h...h)
            {
                var drawY = 100 + y;
                if(drawY >= 0 && drawY < 200)
                    gfx.setPixel32(i, drawY, FlxColor.WHITE);
            }
        }

        waveform.dirty = true;
    }

    // =========================
    // 🟩 GRID + LANES
    // =========================
    function drawGrid()
    {
        grid.clear();

        // Vertical lanes
        for(i in 0...lanes)
        {
            var x = i * laneWidth;
            var lane = new FlxSprite(x, 0).makeGraphic(2, FlxG.height, FlxColor.DARK_GRAY);
            grid.add(lane);
        }

        // Beat lines
        var time:Float = 0;
        var id:Int = 0;

        while(time < 60)
        {
            var y = strumLineY - (time * scrollSpeed * zoom);

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
        var time = (strumLineY - y) / (scrollSpeed * zoom);

        var snapStep = beatLength / snap;
        var snapped = Math.round(time / snapStep) * snapStep;

        var note = new FlxSprite(lane * laneWidth + laneWidth/2 - 20, strumLineY - snapped * scrollSpeed * zoom);
        note.makeGraphic(40, 40, FlxColor.RED);

        note.ID = Std.int(snapped * 1000);
        note.alpha = lane; // store lane

        notes.add(note);
    }

    // =========================
    // 🟪 HOLD NOTES
    // =========================
    function startHold(x:Float, y:Float)
    {
        placingHold = true;
        holdLane = Std.int(x / laneWidth);
        holdStartTime = (strumLineY - y) / (scrollSpeed * zoom);
    }

    function endHold(y:Float)
    {
        if(!placingHold) return;

        placingHold = false;

        var endTime = (strumLineY - y) / (scrollSpeed * zoom);

        var startSnap = Math.round(holdStartTime / (beatLength / snap)) * (beatLength / snap);
        var endSnap = Math.round(endTime / (beatLength / snap)) * (beatLength / snap);

        var height = (endSnap - startSnap) * scrollSpeed * zoom;

        var sustain = new FlxSprite(holdLane * laneWidth + laneWidth/2 - 10,
            strumLineY - startSnap * scrollSpeed * zoom);

        sustain.makeGraphic(20, Std.int(height), FlxColor.GREEN);

        sustain.ID = Std.int(startSnap * 1000);
        sustain.alpha = holdLane;
        sustain.angle = endSnap * 1000; // store end

        sustains.add(sustain);
    }

    // =========================
    // 💾 SAVE CHART
    // =========================
    function saveChart()
    {
        var data:Array<Dynamic> = [];

        for(n in notes.members)
        {
            if(n != null)
                data.push({time:n.ID, lane:n.alpha, type:"tap"});
        }

        for(s in sustains.members)
        {
            if(s != null)
                data.push({
                    time:s.ID,
                    lane:s.alpha,
                    type:"hold",
                    end:s.angle
                });
        }

        var json = Json.stringify(data, "\t");
        File.saveContent("chart.json", json);
        FlxG.log("Chart saved!");
    }

    // =========================
    // 📂 LOAD CHART
    // =========================
    function loadChart()
    {
        if(!FileSystem.exists("chart.json")) return;

        notes.clear();
        sustains.clear();

        var raw = File.getContent("chart.json");
        var data:Array<Dynamic> = Json.parse(raw);

        for(d in data)
        {
            if(d.type == "tap")
            {
                var n = new FlxSprite(d.lane * laneWidth + laneWidth/2 - 20,
                    strumLineY - (d.time/1000) * scrollSpeed * zoom);

                n.makeGraphic(40, 40, FlxColor.RED);
                n.ID = d.time;
                n.alpha = d.lane;

                notes.add(n);
            }
            else
            {
                var height = ((d.end/1000) - (d.time/1000)) * scrollSpeed * zoom;

                var s = new FlxSprite(d.lane * laneWidth + laneWidth/2 - 10,
                    strumLineY - (d.time/1000) * scrollSpeed * zoom);

                s.makeGraphic(20, Std.int(height), FlxColor.GREEN);

                s.ID = d.time;
                s.alpha = d.lane;
                s.angle = d.end;

                sustains.add(s);
            }
        }
        FlxG.log("Chart loaded!");
    }

    // =========================
    // PAUSE
    // =========================
    function togglePause()
    {
        isPaused = !isPaused;
        if(isPaused) song.pause();
        else song.play();
    }

    // =========================
    // UPDATE LOOP
    // =========================
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(!isPaused)
        {
            var songPos = song.time / 1000;

            for(line in grid.members)
            {
                if(line != null && line.height == 2)
                    line.y = strumLineY - (songPos * scrollSpeed * zoom) + (line.ID * beatLength * scrollSpeed * zoom);
            }

            for(n in notes.members)
            {
                if(n != null)
                    n.y = strumLineY - ((n.ID/1000 - songPos) * scrollSpeed * zoom);
            }

            for(s in sustains.members)
            {
                if(s != null)
                    s.y = strumLineY - ((s.ID/1000 - songPos) * scrollSpeed * zoom);
            }
        }

        // CLICK / TAP
        if(FlxG.mouse.justPressed)
            placeNote(FlxG.mouse.x, FlxG.mouse.y);

        if(FlxG.mouse.justPressedRight)
            startHold(FlxG.mouse.x, FlxG.mouse.y);

        if(FlxG.mouse.justReleasedRight)
            endHold(FlxG.mouse.y);

        for(t in FlxG.touches.list)
        {
            if(t.justPressed)
                placeNote(t.x, t.y);

            if(t.justPressed && t.pressed)
                startHold(t.x, t.y);

            if(t.justReleased)
                endHold(t.y);
        }

        // SAVE / LOAD
        if(FlxG.keys.justPressed.S)
            saveChart();

        if(FlxG.keys.justPressed.L)
            loadChart();

        // SCROLL
        if(FlxG.mouse.wheel != 0)
        {
            strumLineY += FlxG.mouse.wheel * 20;
            drawGrid();
        }

        // UPDATE BUTTONS
        zoomInBtn.update(elapsed);
        zoomOutBtn.update(elapsed);
        saveBtn.update(elapsed);
        loadBtn.update(elapsed);
        pauseBtn.update(elapsed);
    }
}
