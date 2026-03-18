package Editor;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import Backend.Timing.Conductor;

import Editor.EditorButton;

class ChartEditorState extends FlxState
{
    // =========================
    // GRID
    // =========================
    var grid:Array<FlxSprite> = [];

    // =========================
    // NOTES
    // =========================
    var notes:Array<Dynamic> = [];
    var noteSprites:Array<FlxSprite> = [];

    // =========================
    // SETTINGS
    // =========================
    var laneWidth:Int = 120;
    var startX:Int = 200;

    var currentHold:Bool = false;

    // =========================
    // UI
    // =========================
    var timeText:FlxText;
    var holdText:FlxText;

    override public function create()
    {
        super.create();

        Conductor.init(120);

        createGrid();
        createUI();
        createButtons();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        // Advance song time manually
        Conductor.songPosition += elapsed * 1000;

        timeText.text = "Time: " + Std.int(Conductor.songPosition);

        handleInput();
    }

    // =========================
    // GRID
    // =========================
    function createGrid():Void
    {
        for(lane in 0...4)
        {
            for(row in 0...20)
            {
                var tile = new FlxSprite(startX + lane * laneWidth, row * 40);
                tile.makeGraphic(100, 38, FlxColor.DARK_GRAY);
                add(tile);

                grid.push(tile);
            }
        }
    }

    // =========================
    // UI
    // =========================
    function createUI():Void
    {
        timeText = new FlxText(20, 20, 300, "Time: 0", 20);
        add(timeText);

        holdText = new FlxText(20, 40, 300, "Hold: OFF", 20);
        add(holdText);
    }

    // =========================
    // BUTTONS
    // =========================
    function createButtons():Void
    {
        // SAVE
        add(new EditorButton(20, 80, "Save", function()
        {
            saveChart();
        }));

        // CLEAR
        add(new EditorButton(20, 140, "Clear", function()
        {
            clearNotes();
        }));

        // PLAY TEST
        add(new EditorButton(20, 200, "Play", function()
        {
            FlxG.switchState(new Game.Funkin.PlayState());
        }));

        // TOGGLE HOLD
        add(new EditorButton(20, 260, "Toggle Hold", function()
        {
            currentHold = !currentHold;
            holdText.text = "Hold: " + (currentHold ? "ON" : "OFF");
        }));
    }

    // =========================
    // INPUT
    // =========================
    function handleInput():Void
    {
        // Mouse click
        if(FlxG.mouse.justPressed)
        {
            tryPlaceNote(FlxG.mouse.x, FlxG.mouse.y);
        }

        // Touch input
        for(touch in FlxG.touches.list)
        {
            if(touch.justPressed)
            {
                var pos = touch.getWorldPosition();
                tryPlaceNote(pos.x, pos.y);
            }
        }
    }

    function tryPlaceNote(mx:Float, my:Float):Void
    {
        var lane = Std.int((mx - startX) / laneWidth);

        if(lane >= 0 && lane < 4)
        {
            addNote(lane, my);
        }
    }

    // =========================
    // ADD NOTE
    // =========================
    function addNote(lane:Int, yPos:Float):Void
    {
        var note = {
            time: Conductor.songPosition,
            lane: lane,
            hold: currentHold,
            length: currentHold ? 300 : 0
        };

        notes.push(note);

        var visual = new FlxSprite(startX + lane * laneWidth, yPos);

        if(currentHold)
            visual.makeGraphic(80, 60, FlxColor.BLUE);
        else
            visual.makeGraphic(80, 20, FlxColor.YELLOW);

        add(visual);
        noteSprites.push(visual);
    }

    // =========================
    // CLEAR NOTES
    // =========================
    function clearNotes():Void
    {
        notes = [];

        for(sprite in noteSprites)
            sprite.kill();

        noteSprites = [];
    }

    // =========================
    // SAVE CHART
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

        trace("Chart Saved!");
    }
}
