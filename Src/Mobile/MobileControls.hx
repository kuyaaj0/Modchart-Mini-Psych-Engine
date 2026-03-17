package Mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.touch.FlxTouch;
import Backend.Settings;

class MobileControls
{
    public var buttons:Array<VirtualButton>;
    public var laneButtons:Array<VirtualButton>;
    public var dpadButtons:Array<VirtualButton>;

    public function new()
    {
        buttons = [];
        laneButtons = [];
        dpadButtons = [];
        setupButtons();
    }

    // =========================
    // Initialize buttons based on Settings
    // =========================
    private function setupButtons():Void
    {
        buttons = [];
        laneButtons = [];
        dpadButtons = [];

        // ===== LANE BUTTONS =====
        if(Settings.mobileLaneTiles)
        {
            // Center lanes horizontally, spaced for 4 notes
            var screenCenter:Float = FlxG.width / 2;
            var spacing:Float = 120; // space between lane buttons
            var startX:Float = screenCenter - 1.5 * spacing;
            var yPos:Float = FlxG.height - 200;

            for(i in 0...4)
            {
                var btn = new VirtualButton(startX + i*spacing, yPos, 100, 100);
                laneButtons.push(btn);
                buttons.push(btn);
            }
        }

        // ===== D-PAD BUTTONS =====
        if(Settings.mobileDPad || Settings.mobileCustomDPad)
        {
            // Default D-Pad positions (can be overridden by custom)
            var positions:Array<{x:Float, y:Float}> = [
                {x:100, y:FlxG.height - 200}, // left
                {x:200, y:FlxG.height - 100}, // down
                {x:200, y:FlxG.height - 300}, // up
                {x:300, y:FlxG.height - 200}  // right
            ];

            for(i in 0...4)
            {
                var pos = positions[i];
                var btn = new VirtualButton(pos.x, pos.y, 80, 80);
                dpadButtons.push(btn);
                buttons.push(btn);
            }
        }
    }

    // =========================
    // Update every frame
    // =========================
    public function update():Void
    {
        // Hide buttons if keyboard mode or PC keys are pressed
        if(Settings.keyboardMode || FlxG.keys.any())
        {
            for(b in buttons)
                b.visible = false;
        }
        else
        {
            for(b in buttons)
            {
                b.visible = true;
                b.update();
            }
        }
    }

    // =========================
    // Draw all visible buttons
    // =========================
    public function draw():Void
    {
        for(b in buttons)
            if(b.visible)
                b.draw();
    }

    // =========================
    // Lane button pressed
    // =========================
    public function isLanePressed(lane:Int):Bool
    {
        if(lane < 0 || lane >= laneButtons.length) return false;
        return laneButtons[lane].isPressed;
    }

    // =========================
    // D-Pad button pressed (0-left,1-down,2-up,3-right)
    // =========================
    public function isDPadPressed(index:Int):Bool
    {
        if(index < 0 || index >= dpadButtons.length) return false;
        return dpadButtons[index].isPressed;
    }

    // =========================
    // Move D-Pad for custom positions
    // =========================
    public function moveDPad(newPositions:Array<{x:Float, y:Float}>):Void
    {
        if(!Settings.mobileCustomDPadPosition) return;
        for(i in 0...dpadButtons.length)
        {
            if(i >= newPositions.length) break;
            dpadButtons[i].moveTo(newPositions[i].x, newPositions[i].y);
        }
    }

    // =========================
    // Check if a note at screen coordinates is clicked
    // =========================
    public function checkNoteClick(noteX:Float, noteY:Float, noteWidth:Float, noteHeight:Float):Bool
    {
        if(!Settings.mobileClickOnNotePosition) return false;

        for(btn in buttons)
        {
            if(btn.checkNoteClick(noteX, noteY, noteWidth, noteHeight))
                return true;
        }
        return false;
    }

    // =========================
    // Optional: align lane buttons with note positions
    // =========================
    public function alignLanesWithNotes(notePositions:Array<Float>):Void
    {
        if(!Settings.mobileLaneTiles) return;
        for(i in 0...laneButtons.length)
        {
            if(i >= notePositions.length) break;
            laneButtons[i].moveTo(notePositions[i], laneButtons[i].y);
        }
    }
}
