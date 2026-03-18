package Game.Funkin.Substates;

import flixel.FlxSubState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PauseSubState extends FlxSubState
{
    override public function create()
    {
        super.create();

        var bg = new flixel.FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        bg.alpha = 0.7;
        add(bg);

        var text = new FlxText(0, 300, FlxG.width,
            "PAUSED\nTap Anywhere to Resume",
            32
        );
        text.alignment = "center";
        add(text);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        // Resume
        if(FlxG.mouse.justPressed || FlxG.keys.justPressed.ESCAPE)
        {
            close();
        }

        // Touch resume
        for(touch in FlxG.touches.list)
        {
            if(touch.justPressed)
            {
                close();
                break;
            }
        }
    }
}
