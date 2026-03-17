package game.funkin;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;

import Backend.Settings as ClientPrefs;
import Backend.Input.InputManager;
import Backend.Utils.CoolUtil;

class PlayState extends FlxState
{
    // =========================
    //  HEALTH SYSTEM
    // =========================

    public var health:Float = 1.0;
    public var smoothHealth:Float = 1.0;

    // =========================
    //  SCORE SYSTEM
    // =========================

    public var score:Int = 0;
    public var displayScore:Int = 0;

    // =========================
    //  UI
    // =========================

    var scoreText:FlxText;
    var healthBar:FlxSprite;

    // =========================
    //  STRUM TEST
    // =========================

    var playerStrums:Array<FlxSprite> = [];

    override public function create()
    {
        super.create();

        // Init input
        InputManager.init();

        // Background
        var bg = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        add(bg);

        // =========================
        //  STRUM LINE
        // =========================

        for (i in 0...4)
        {
            var strum = new FlxSprite(200 + (i * 120), 500);
            strum.makeGraphic(80, 80, FlxColor.GRAY);

            playerStrums.push(strum);
            add(strum);
        }

        // =========================
        //  HEALTH BAR
        // =========================

        healthBar = new FlxSprite(50, 50).makeGraphic(300, 20, FlxColor.GREEN);
        add(healthBar);

        // =========================
        //  SCORE TEXT
        // =========================

        scoreText = new FlxText(50, 80, 0, "Score: 0", 24);
        add(scoreText);

        // Apply settings at start
        applyScrollSettings();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        InputManager.update();

        handleInput();
        updateHealth();
        updateScore();
        updateUI();
    }

    // =========================
    //  INPUT
    // =========================

    function handleInput()
    {
        if (InputManager.leftPress())
            hitNote(0);

        if (InputManager.downPress())
            hitNote(1);

        if (InputManager.upPress())
            hitNote(2);

        if (InputManager.rightPress())
            hitNote(3);
    }

    function hitNote(lane:Int)
    {
        // Simple test feedback
        playerStrums[lane].color = FlxColor.WHITE;

        // Increase score
        score += 100;

        // Increase health slightly
        health += 0.02;
        health = CoolUtil.clamp(health, 0, 2);
    }

    // =========================
    //  HEALTH UPDATE
    // =========================

    function updateHealth()
    {
        if (ClientPrefs.smoothHealth)
        {
            smoothHealth = CoolUtil.smoothLerp(
                smoothHealth,
                health,
                ClientPrefs.healthLerp
            );
        }
        else
        {
            smoothHealth = health;
        }

        // Death check (REAL value)
        if (health <= 0)
        {
            trace("Player Died");
        }
    }

    // =========================
    //  SCORE UPDATE
    // =========================

    function updateScore()
    {
        if (ClientPrefs.smoothScore)
        {
            displayScore = Std.int(CoolUtil.smoothLerp(
                displayScore,
                score,
                ClientPrefs.scoreLerp
            ));
        }
        else
        {
            displayScore = score;
        }
    }

    // =========================
    //  UI UPDATE
    // =========================

    function updateUI()
    {
        // Health bar scale
        healthBar.scale.x = smoothHealth;

        // Score text
        if (ClientPrefs.scoreSeparator)
            scoreText.text = "Score: " + CoolUtil.formatNumber(displayScore);
        else
            scoreText.text = "Score: " + displayScore;
    }

    // =========================
    // ⬇️ SCROLL SETTINGS
    // =========================

    function applyScrollSettings()
    {
        if (ClientPrefs.downScroll)
        {
            for (strum in playerStrums)
                strum.y = 100;
        }
        else
        {
            for (strum in playerStrums)
                strum.y = 500;
        }

        if (ClientPrefs.middleScroll)
        {
            for (i in 0...playerStrums.length)
            {
                playerStrums[i].x = FlxG.width / 2 - 200 + (i * 120);
            }
        }
    }
}
