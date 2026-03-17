package Mobile;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.input.touch.FlxTouch;

class VirtualButton
{
    public var x:Float;
    public var y:Float;
    public var width:Float;
    public var height:Float;

    public var isPressed:Bool = false;
    public var visible:Bool = true;

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

    // Move the button to a new position
    public function moveTo(newX:Float, newY:Float):Void
    {
        x = newX;
        y = newY;
        sprite.x = x - width/2;
        sprite.y = y - height/2;
    }

    // Update button every frame
    public function update():Void
    {
        if(!visible) { isPressed = false; return; }

        isPressed = false;

        for(touch in FlxG.touches.list)
        {
            if(checkTouch(touch.screenX, touch.screenY))
            {
                isPressed = true;
                break;
            }
        }

        sprite.visible = visible;
    }

    // Draw the sprite
    public function draw():Void
    {
        if(visible) sprite.draw();
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
