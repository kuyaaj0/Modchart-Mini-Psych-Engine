package Mobile;

import flixel.FlxG;
import flixel.FlxSprite;
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

    private function setupButtons():Void
    {
        buttons = [];
        laneButtons = [];
        dpadButtons = [];

        // ===== LANE BUTTONS =====
        if(Settings.mobileLaneTiles)
        {
            var yPos:Float = FlxG.height - 200;
            var positions:Array<Float>;

            if(Settings.mobileOfficialLayout)
            {
                // Centered & spaced like official FNF mobile
                var screenCenter = FlxG.width / 2;
                var spacing:Float = 120;
                positions = [
                    screenCenter - 1.5 * spacing,
                    screenCenter - 0.5 * spacing,
                    screenCenter + 0.5 * spacing,
                    screenCenter + 1.5 * spacing
                ];
            }
            else
            {
                // Classic: right side lanes
                positions = [800, 920, 1040, 1160];
            }

            for(i in 0...4)
            {
                var btn = new VirtualButton(positions[i], yPos, 100, 100);
                laneButtons.push(btn);
                buttons.push(btn);
            }
        }

        // ===== D-PAD BUTTONS =====
        if(Settings.mobileDPad || Settings.mobileCustomDPad)
        {
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

    public function update():Void
    {
        if(Settings.keyboardMode || FlxG.keys.any())
        {
            for(b in buttons) b.visible = false;
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

    public function draw():Void
    {
        for(b in buttons)
            if(b.visible) b.draw();
    }

    public function isLanePressed(lane:Int):Bool
    {
        if(lane < 0 || lane >= laneButtons.length) return false;
        return laneButtons[lane].isPressed;
    }

    public function isDPadPressed(index:Int):Bool
    {
        if(index < 0 || index >= dpadButtons.length) return false;
        return dpadButtons[index].isPressed;
    }

    public function moveDPad(newPositions:Array<{x:Float, y:Float}>):Void
    {
        if(!Settings.mobileCustomDPadPosition) return;
        for(i in 0...dpadButtons.length)
        {
            if(i >= newPositions.length) break;
            dpadButtons[i].moveTo(newPositions[i].x, newPositions[i].y);
        }
    }

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
