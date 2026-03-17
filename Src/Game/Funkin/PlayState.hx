package game.funkin;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

import Backend.Settings as ClientPrefs;
import Backend.Input.InputManager;
import Backend.Utils.CoolUtil;

import Mobile.MobileControls;
import Mobile.TouchNotes;
import Mobile.VirtualButton;

class PlayState extends FlxState
{
    // =========================
    // HEALTH SYSTEM
    // =========================
    public var health:Float = 1.0;
    public var smoothHealth:Float = 1.0;

    // =========================
    // SCORE SYSTEM
    // =========================
    public var score:Int = 0;
    public var displayScore:Int = 0;

    // =========================
    // UI
    // =========================
    var scoreText:FlxText;
    var healthBar:FlxSprite;

    // =========================
    // STRUM LINES
    // =========================
    var playerStrums:Array<FlxSprite> = [];
    var opponentStrums:Array<FlxSprite> = [];

    // =========================
    // MOBILE INPUT
    // =========================
    var mobileControls:MobileControls;
    var touchNotes:TouchNotes;

    override public function create()
    {
        super.create();

        // Init input
        InputManager.init();

        // Background
        var bg = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        add(bg);

        // =========================
        // STRUM LINES
        // =========================
        createStrums();

        // =========================
        // HEALTH BAR
        // =========================
        healthBar = new FlxSprite(50, 50).makeGraphic(300, 20, FlxColor.GREEN);
        add(healthBar);

        // =========================
        // SCORE TEXT
        // =========================
        scoreText = new FlxText(50, 80, 0, "Score: 0", 24);
        add(scoreText);

        // =========================
        // MOBILE CONTROLS SETUP
        // =========================
        mobileControls = new MobileControls();
        touchNotes = new TouchNotes(mobileControls);

        // Add all player notes to touchNotes for detection
        for(strum in playerStrums)
            touchNotes.addNote(strum);

        // =========================
        // APPLY SETTINGS
        // =========================
        applyScrollSettings();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        InputManager.update();

        // Update mobile controls
        mobileControls.update();
        touchNotes.update();

        handleInput();
        updateHealth();
        updateScore();
        updateUI();
    }

    // =========================
    // CREATE STRUMS
    // =========================
    function createStrums():Void
    {
        var spacing:Float = 120;

        // Opponent strums (optional)
        for(i in 0...4)
        {
            var opp = new FlxSprite(200 + i * spacing, 100);
            opp.makeGraphic(80, 80, FlxColor.RED);
            opponentStrums.push(opp);
            add(opp);
        }

        // Player strums
        for(i in 0...4)
        {
            var yPos:Float = 500;
            if(ClientPrefs.mobileOfficialLayout)
                yPos = FlxG.height - 200;

            var strum = new FlxSprite(200 + i * spacing, yPos);
            strum.makeGraphic(80, 80, FlxColor.GRAY);
            playerStrums.push(strum);
            add(strum);
        }

        // Hide opponent if official mobile layout
        if(ClientPrefs.mobileOfficialLayout)
        {
            for(opp in opponentStrums)
                opp.visible = false;
        }
    }

    // =========================
    // INPUT HANDLING (KEYBOARD + MOBILE)
    // =========================
    function handleInput():Void
    {
        for(lane in 0...4)
        {
            if(InputManager.lanePress(lane) || mobileControls.isLanePressed(lane))
                hitNote(lane);
        }
    }

    function hitNote(lane:Int):Void
    {
        var strum = playerStrums[lane];

        // Visual feedback
        strum.color = FlxColor.WHITE;
        FlxTween.color(strum, strum.color, FlxColor.GRAY, 0.15); // fade back

        // Increase score
        score += 100;

        // Increase health slightly
        health += 0.02;
        health = CoolUtil.clamp(health, 0, 2);
    }

    // =========================
    // HEALTH UPDATE
    // =========================
    function updateHealth():Void
    {
        smoothHealth = ClientPrefs.smoothHealth
            ? CoolUtil.smoothLerp(smoothHealth, health, ClientPrefs.healthLerp)
            : health;

        if(health <= 0)
            trace("Player Died");
    }

    // =========================
    // SCORE UPDATE
    // =========================
    function updateScore():Void
    {
        displayScore = ClientPrefs.smoothScore
            ? Std.int(CoolUtil.smoothLerp(displayScore, score, ClientPrefs.scoreLerp))
            : score;
    }

    // =========================
    // UI UPDATE
    // =========================
    function updateUI():Void
    {
        healthBar.scale.x = smoothHealth;

        scoreText.text = ClientPrefs.scoreSeparator
            ? "Score: " + CoolUtil.formatNumber(displayScore)
            : "Score: " + displayScore;
    }

    // =========================
    // SCROLL SETTINGS
    // =========================
    function applyScrollSettings():Void
    {
        if(ClientPrefs.downScroll)
        {
            for(strum in playerStrums)
                strum.y = 100;
        }
        else
        {
            for(strum in playerStrums)
                strum.y = ClientPrefs.mobileOfficialLayout ? FlxG.height - 200 : 500;
        }

        if(ClientPrefs.middleScroll)
        {
            for(i in 0...playerStrums.length)
                playerStrums[i].x = FlxG.width / 2 - 200 + (i * 120);
        }

        // Align mobile lane buttons with player notes
        if(ClientPrefs.mobileLaneTiles)
        {
            var positions = playerStrums.map(function(s) return s.x);
            mobileControls.alignLanesWithNotes(positions);
        }
    }
}
