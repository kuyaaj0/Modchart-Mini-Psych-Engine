package Game.Funkin.Substates;

import flixel.FlxSubState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;

import Editor.EditorButton;
import Game.Funkin.PlayState;
import Editor.ChartEditorState;

class PauseSubState extends FlxSubState
{
    var bg:FlxSprite;
    var title:FlxText;

    var buttons:FlxGroup;

    override public function create()
    {
        super.create();

        // =========================
        // DARK BACKGROUND
        // =========================
        bg = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        bg.alpha = 0.75;
        add(bg);

        // =========================
        // TITLE
        // =========================
        title = new FlxText(0, 120, FlxG.width, "PAUSED", 48);
        title.alignment = "center";
        add(title);

        // =========================
        // BUTTON GROUP
        // =========================
        buttons = new FlxGroup();
        add(buttons);

        var centerX = FlxG.width / 2 - 100;
        var startY = 250;
        var spacing = 70;

        // RESUME
        buttons.add(new EditorButton(centerX, startY, "RESUME", function()
        {
            resumeGame();
        }));

        // RESTART
        buttons.add(new EditorButton(centerX, startY + spacing, "RESTART", function()
        {
            FlxG.resetState();
        }));

        // CHART EDITOR
        buttons.add(new EditorButton(centerX, startY + spacing * 2, "CHART EDITOR", function()
        {
            FlxG.switchState(new ChartEditorState());
        }));

        // EXIT
        buttons.add(new EditorButton(centerX, startY + spacing * 3, "EXIT", function()
        {
            FlxG.switchState(new PlayState()); // or MainMenuState later
        }));
    }

    // =========================
    // RESUME FUNCTION
    // =========================
    function resumeGame():Void
    {
        close();
    }

    // =========================
    // UPDATE
    // =========================
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        // Keyboard resume
        if(FlxG.keys.justPressed.ESCAPE)
            resumeGame();

        // Mobile quick tap resume (optional)
        for(t in FlxG.touches.list)
        {
            if(t.justPressed && t.y < 100) // top tap = quick resume
            {
                resumeGame();
                break;
            }
        }
    }
}
