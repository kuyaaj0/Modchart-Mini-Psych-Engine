package Mobile;

import flixel.FlxSprite;
import flixel.input.touch.FlxTouch;
import flixel.FlxG;

class VirtualButton
{
    public var x:Float;
    public var y:Float;
    public var width:Float;
    public var height:Float;

    public var isPressed:Bool = false;
    public var visible:Bool = true;

    private var sprite:FlxSprite;

    public function new(x:Float, y:Float, width:Float, height:Float)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;

        sprite = new FlxSprite(x - width/2, y - height/2);
        sprite.makeGraphic(width, height, 0x77FFFFFF); // semi-transparent button
    }

    // Move the button to a new position
    public function moveTo(newX:Float, newY:Float):Void
    {
        x = newX;
        y = newY;
        sprite.x = x - width/2;
        sprite.y = y - height/2;
    }

    // Update press state
    public function update():Void
    {
        isPressed = false;

        for(touch in FlxG.touches.list)
        {
            if(!touch.justReleased && checkTouch(touch))
            {
                isPressed = true;
                break;
            }
        }
    }

    // Check if touch is inside button bounds
    private function checkTouch(touch:FlxTouch):Bool
    {
        return touch.screenX >= x - width/2 &&
               touch.screenX <= x + width/2 &&
               touch.screenY >= y - height/2 &&
               touch.screenY <= y + height/2;
    }

    // Check if note rectangle is clicked by this button
    public function checkNoteClick(noteX:Float, noteY:Float, noteWidth:Float, noteHeight:Float):Bool
    {
        if(!visible) return false;

        var btnLeft = x - width/2;
        var btnRight = x + width/2;
        var btnTop = y - height/2;
        var btnBottom = y + height/2;

        var noteLeft = noteX;
        var noteRight = noteX + noteWidth;
        var noteTop = noteY;
        var noteBottom = noteY + noteHeight;

        var overlapX = btnRight > noteLeft && btnLeft < noteRight;
        var overlapY = btnBottom > noteTop && btnTop < noteBottom;

        return overlapX && overlapY;
    }

    // Draw button
    public function draw():Void
    {
        if(visible)
            sprite.draw();
    }
} Mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.touch.FlxTouch;

class VirtualButton
{
    public var x:Float;
    public var y:Float;
    public var width:Float;
    public var height:Float;

    public var isPressed:Bool = false;
    public var visible:Bool = true;

    // Optional: visual sprite for button
    public var sprite:FlxSprite;

    public function new(x:Float, y:Float, width:Float, height:Float)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;

        sprite = new FlxSprite(x - width/2, y - height/2);
        sprite.makeGraphic(width, height, 0x7700FF00); // semi-transparent green
        sprite.visible = visible;
    }

    // Update button each frame
    public function update():Void
    {
        if(!visible) { isPressed = false; return; }

        isPressed = false;

        // Check all active touches
        for(touch in FlxG.touches.list)
        {
            if(checkTouch(touch.screenX, touch.screenY))
            {
                isPressed = true;
                break;
            }
        }

        // Update sprite visibility
        sprite.visible = visible;
    }

    // Draw the sprite if visible
    public function draw():Void
    {
        if(visible) sprite.draw();
    }

    // Move the button to a new position
    public function moveTo(newX:Float, newY:Float):Void
    {
        x = newX;
        y = newY;
        sprite.x = newX - width/2;
        sprite.y = newY - height/2;
    }

    // Check if a note area was clicked
    public function checkNoteClick(noteX:Float, noteY:Float, noteW:Float, noteH:Float):Bool
    {
        if(!visible) return false;

        return !(noteX > x + width || noteX + noteW < x || noteY > y + height || noteY + noteH < y);
    }

    private function checkTouch(touchX:Float, touchY:Float):Bool
    {
        return (touchX >= x - width/2 && touchX <= x + width/2 &&
                touchY >= y - height/2 && touchY <= y + height/2);
    }
}
