package Mobile;

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
