package Editor;

import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;

class EditorButton extends FlxGroup
{
    public var bg:FlxSprite;
    public var label:FlxText;
    public var onClick:Void->Void;

    var baseColor:Int = FlxColor.GRAY;
    var hoverColor:Int = FlxColor.LIGHT_GRAY;
    var pressColor:Int = FlxColor.WHITE;

    var widthSize:Int;
    var heightSize:Int;

    public function new(x:Float, y:Float, text:String, callback:Void->Void, ?w:Int = 150, ?h:Int = 50)
    {
        super();

        widthSize = w;
        heightSize = h;

        bg = new FlxSprite(x, y).makeGraphic(widthSize, heightSize, baseColor);

        label = new FlxText(x, y, widthSize, text, 16);
        label.alignment = "center";
        centerLabel();

        onClick = callback;

        add(bg);
        add(label);
    }

    function centerLabel()
    {
        label.x = bg.x;
        label.y = bg.y + (heightSize - label.height) / 2;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var hover = false;
        var pressed = false;

        // Mouse
        if(FlxG.mouse.overlaps(bg))
        {
            hover = true;
            if(FlxG.mouse.pressed) pressed = true;
            if(FlxG.mouse.justReleased && onClick != null) onClick();
        }

        // Touch
        for(t in FlxG.touches.list)
        {
            var pos = t.getWorldPosition();
            if(bg.overlapsPoint(pos))
            {
                hover = true;
                if(t.pressed) pressed = true;
                if(t.justReleased && onClick != null) onClick();
            }
        }

        // Visual feedback
        if(pressed)
        {
            bg.color = pressColor;
            bg.scale.set(0.95, 0.95);
        }
        else if(hover)
        {
            bg.color = hoverColor;
            bg.scale.set(1.05, 1.05);
        }
        else
        {
            bg.color = baseColor;
            bg.scale.set(1, 1);
        }

        centerLabel();
    }
}
