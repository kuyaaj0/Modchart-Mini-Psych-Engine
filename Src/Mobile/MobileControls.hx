package Mobile;

import flixel.FlxG;
import backend.Settings;

class MobileControls
{
    public var laneTiles:Array<VirtualButton>;       // Visual lane guides
    public var laneTouchZones:Array<VirtualButton>; // Actual touchable zones
    public var dpadButtons:Array<VirtualButton>;    // Optional dpad buttons
    public var opponentZones:Array<VirtualButton>;  // Invisible opponent zones

    public function new()
    {
        laneTiles = [];
        laneTouchZones = [];
        dpadButtons = [];
        opponentZones = [];
        setupButtons();
    }

    // =========================
    // Initialize all buttons
    // =========================
    private function setupButtons():Void
    {
        laneTiles = [];
        laneTouchZones = [];
        dpadButtons = [];
        opponentZones = [];

        // ===== Player Lane Tiles (Visual Only) =====
        if(Settings.mobileLaneTiles)
        {
            var screenCenterX = FlxG.width / 2;
            var baseY = FlxG.height - 150;
            var laneSpacing = 120;

            var tilePositions:Array<Float> = [
                screenCenterX - laneSpacing,
                screenCenterX - laneSpacing/2,
                screenCenterX + laneSpacing/2,
                screenCenterX + laneSpacing
            ];

            for(i in 0...4)
            {
                var tile = new VirtualButton(tilePositions[i], baseY, 80, 80);
                tile.visible = true;
                laneTiles.push(tile);

                // Player touch zones overlap tiles
                var touchZone = new VirtualButton(tilePositions[i], baseY, 80, 80);
                laneTouchZones.push(touchZone);
            }
        }

        // ===== D-Pad Buttons =====
        if(Settings.mobileDPad || Settings.mobileCustomDPad)
        {
            var dpadPos:Array<{x:Float, y:Float}> = [
                {x:100, y:600}, // left
                {x:200, y:600}, // down
                {x:300, y:500}, // up
                {x:400, y:600}  // right
            ];

            for(i in 0...4)
            {
                var btn = new VirtualButton(dpadPos[i].x, dpadPos[i].y, 80, 80);
                dpadButtons.push(btn);
            }
        }

        // ===== Opponent Invisible Zones =====
        if(Settings.mobileLaneTiles)
        {
            var oppX = 50;
            var oppY = 50;
            var oppSpacing = 60;
            for(i in 0...4)
            {
                var zone = new VirtualButton(oppX + i*oppSpacing, oppY, 80, 80);
                zone.visible = false; // invisible for opponent
                opponentZones.push(zone);
            }
        }
    }

    // =========================
    // Update all buttons each frame
    // =========================
    public function update():Void
    {
        // Disable mobile buttons if using keyboard
        if(Settings.keyboardMode || FlxG.keys.any())
        {
            hideAll();
            return;
        }

        for(tile in laneTiles)
            tile.update();

        for(zone in laneTouchZones)
            zone.update();

        for(btn in dpadButtons)
            btn.update();

        for(zone in opponentZones)
            zone.update();
    }

    // =========================
    // Draw all buttons
    // =========================
    public function draw():Void
    {
        for(tile in laneTiles)
            tile.draw();

        for(zone in laneTouchZones)
            zone.draw();

        for(btn in dpadButtons)
            btn.draw();
    }

    // =========================
    // Utility Functions
    // =========================
    public function hideAll():Void
    {
        for(tile in laneTiles) tile.visible = false;
        for(zone in laneTouchZones) zone.visible = false;
        for(btn in dpadButtons) btn.visible = false;
    }

    public function showAll():Void
    {
        for(tile in laneTiles) tile.visible = true;
        for(zone in laneTouchZones) zone.visible = true;
        for(btn in dpadButtons) btn.visible = true;
    }

    public function moveDPad(newPos:Array<{x:Float, y:Float}>):Void
    {
        if(!Settings.mobileCustomDPadPosition) return;
        for(i in 0...dpadButtons.length)
        {
            if(i >= newPos.length) break;
            dpadButtons[i].moveTo(newPos[i].x, newPos[i].y);
        }
    }

    public function isLanePressed(lane:Int):Bool
    {
        if(lane < 0 || lane >= laneTouchZones.length) return false;
        return laneTouchZones[lane].isPressed;
    }

    public function isDPadPressed(index:Int):Bool
    {
        if(index < 0 || index >= dpadButtons.length) return false;
        return dpadButtons[index].isPressed;
    }

    public function checkNoteClick(noteX:Float, noteY:Float, noteWidth:Float, noteHeight:Float):Bool
    {
        for(zone in laneTouchZones)
        {
            if(zone.checkNoteClick(noteX, noteY, noteWidth, noteHeight))
                return true;
        }
        return false;
    }
}
