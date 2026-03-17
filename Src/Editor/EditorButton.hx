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

    public function new(x:Float, y:Float, text:String, callback:Void->Void)
    {
        super();

        bg = new FlxSprite(x, y);
        bg.makeGraphic(150, 50, FlxColor.GRAY);

        label = new FlxText(x, y + 15, 150, text, 16);
        label.alignment = "center";

        onClick = callback;

        add(bg);
        add(label);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var clicked:Bool = false;

        // Mouse
        if(FlxG.mouse.overlaps(bg) && FlxG.mouse.justPressed)
            clicked = true;

        // Touch (mobile)
        for(touch in FlxG.touches.list)
        {
            if(touch.justPressed && bg.overlapsPoint(touch.getWorldPosition()))
            {
                clicked = true;
                break;
            }
        }

        if(clicked && onClick != null)
            onClick();
    }
}
