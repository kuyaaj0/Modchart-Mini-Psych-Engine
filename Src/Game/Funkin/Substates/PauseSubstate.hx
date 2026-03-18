package Game.Funkin.Substates;

import flixel.FlxSubState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import Editor.ChartEditorState;
import Game.Funkin.PlayState;

class PauseSubState extends FlxSubState
{
    var options:Array<String> = [
        "Resume",
        "Restart",
        "Chart Editor",
        "Exit"
    ];

    var buttons:Array<FlxText> = [];
    var curSelected:Int = 0;

    override public function create()
    {
        super.create();

        // =========================
        // BACKGROUND
        // =========================
        var bg = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        bg.alpha = 0.7;
        add(bg);

        // =========================
        // TITLE
        // =========================
        var title = new FlxText(0, 120, FlxG.width, "PAUSED", 48);
        title.alignment = "center";
        add(title);

        // =========================
        // BUTTONS
        // =========================
        for(i in 0...options.length)
        {
            var txt = new FlxText(0, 250 + i * 70, FlxG.width, options[i], 32);
            txt.alignment = "center";
            buttons.push(txt);
            add(txt);
        }

        updateSelection();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        // =========================
        // KEYBOARD NAVIGATION
        // =========================
        if(FlxG.keys.justPressed.UP)
        {
            curSelected--;
            if(curSelected < 0) curSelected = options.length - 1;
            updateSelection();
        }

        if(FlxG.keys.justPressed.DOWN)
        {
            curSelected++;
            if(curSelected >= options.length) curSelected = 0;
            updateSelection();
        }

        if(FlxG.keys.justPressed.ENTER)
            selectOption();

        // ESC = Resume
        if(FlxG.keys.justPressed.ESCAPE)
            resumeGame();

        // =========================
        // MOUSE / TOUCH INPUT
        // =========================
        for(i in 0...buttons.length)
        {
            var btn = buttons[i];

            if(FlxG.mouse.overlaps(btn) && FlxG.mouse.justPressed)
            {
                curSelected = i;
                updateSelection();
                selectOption();
            }

            for(t in FlxG.touches.list)
            {
                if(t.justPressed && btn.overlapsPoint(t.getWorldPosition()))
                {
                    curSelected = i;
                    updateSelection();
                    selectOption();
                }
            }
        }
    }

    // =========================
    // OPTION HANDLER
    // =========================
    function selectOption():Void
    {
        switch(options[curSelected])
        {
            case "Resume":
                resumeGame();

            case "Restart":
                FlxG.resetState();

            case "Chart Editor":
                FlxG.switchState(new ChartEditorState());

            case "Exit":
                // You can change this to MainMenuState later
                FlxG.switchState(new PlayState());
        }
    }

    // =========================
    // RESUME
    // =========================
    function resumeGame():Void
    {
        close();
    }

    // =========================
    // VISUAL SELECTION
    // =========================
    function updateSelection():Void
    {
        for(i in 0...buttons.length)
        {
            if(i == curSelected)
            {
                buttons[i].color = FlxColor.YELLOW;
                buttons[i].scale.set(1.2, 1.2);
            }
            else
            {
                buttons[i].color = FlxColor.WHITE;
                buttons[i].scale.set(1, 1);
            }
        }
    }
}
