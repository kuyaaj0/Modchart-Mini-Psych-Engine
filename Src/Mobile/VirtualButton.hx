package Mobile;

import flixel.FlxSprite;
import flixel.FlxG;
import backend.Settings;

class VirtualButton extends FlxSprite
{
    public var isPressed:Bool = false;

    public function new(x:Float, y:Float, width:Int = 80, height:Int = 80)
    {
        super(x, y);
        makeGraphic(width, height, 0x7F00FF00); // semi-transparent green
        visible = true;
    }

    // Update touch status
    public function update():Void
    {
        isPressed = false;

        // Only check touch if visible
        if(!visible) return;

        for(touch in FlxG.touches.list)
        {
            if(touch.screenX >= x && touch.screenX <= x + width &&
               touch.screenY >= y && touch.screenY <= y + height)
            {
                isPressed = true;
                break;
            }
        }
    }

    // Check if a note at this position is clicked (latest mobile feature)
    public function checkNoteClick(noteX:Float, noteY:Float, noteWidth:Float, noteHeight:Float):Bool
    {
        if(!Settings.mobileClickOnNotePosition || !visible) return false;

        for(touch in FlxG.touches.list)
        {
            if(touch.screenX >= noteX && touch.screenX <= noteX + noteWidth &&
               touch.screenY >= noteY && touch.screenY <= noteY + noteHeight)
            {
                return true;
            }
        }

        return false;
    }

    // Optional: move button dynamically (for custom D-Pad position)
    public function moveTo(newX:Float, newY:Float):Void
    {
        x = newX;
        y = newY;
    }
}
