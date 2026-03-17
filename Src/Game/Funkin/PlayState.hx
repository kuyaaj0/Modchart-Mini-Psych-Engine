package Game.Funkin;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

import Backend.Settings as ClientPrefs;
import Backend.Input.InputManager;
import Backend.Utils.CoolUtil;
import Backend.Timing.Conductor;

import Game.Funkin.Spawner.NoteSpawner;

import Mobile.MobileControls;
import Mobile.TouchNotes;

class PlayState extends FlxState
{
    // =========================
    // GAMEPLAY STATS
    // =========================
    public var health:Float = 1.0;
    public var smoothHealth:Float = 1.0;

    public var score:Int = 0;
    public var displayScore:Int = 0;

    public var combo:Int = 0;
    public var misses:Int = 0;

    // =========================
    // UI
    // =========================
    var healthBar:FlxSprite;
    var scoreText:FlxText;
    var comboText:FlxText;
    var missText:FlxText;
    var debugText:FlxText;

    // =========================
    // STRUMS
    // =========================
    var playerStrums:Array<FlxSprite> = [];
    var opponentStrums:Array<FlxSprite> = [];

    // =========================
    // NOTE SYSTEM
    // =========================
    var spawner:NoteSpawner;

    // =========================
    // MOBILE
    // =========================
    var mobileControls:MobileControls;
    var touchNotes:TouchNotes;

    // =========================
    // TIMER
    // =========================
    var spawnTimer:Float = 0;

    // =========================
    // CREATE
    // =========================
    override public function create()
    {
        super.create();

        InputManager.init();

        // BACKGROUND
        var bg = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        add(bg);

        // STRUMS
        createStrums();

        // UI
        createUI();

        // NOTE SPAWNER
        spawner = new NoteSpawner(playerStrums, opponentStrums);

        // MOBILE
        mobileControls = new MobileControls();
        touchNotes = new TouchNotes(mobileControls);
        for(strum in playerStrums)
            touchNotes.addNote(strum);

        applyScrollSettings();

        // CONDUCTOR
        Conductor.init(120);
        Conductor.start();
    }

    // =========================
    // UPDATE
    // =========================
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        InputManager.update();
        mobileControls.update();
        touchNotes.update();

        // TEST SPAWN (replace later with chart system)
        spawnTimer += elapsed;
        if(spawnTimer >= 1.0)
        {
            spawnTimer = 0;
            spawner.spawnPlayer(Std.random(4), Conductor.songPosition);
        }

        // UPDATE NOTES
        spawner.update(elapsed);

        // INPUT
        handleInput();

        // SYNC VALUES
        health = ClientPrefs.health;
        score = ClientPrefs.score;

        updateHealth();
        updateScore();
        updateUI();
        updateDebug();
    }

    // =========================
    // STRUM CREATION
    // =========================
    function createStrums():Void
    {
        var spacing:Float = 120;

        for(i in 0...4)
        {
            var opp = new FlxSprite(200 + i * spacing, 100);
            opp.makeGraphic(80, 80, FlxColor.RED);
            opponentStrums.push(opp);
            add(opp);
        }

        for(i in 0...4)
        {
            var yPos:Float = ClientPrefs.mobileOfficialLayout ? FlxG.height - 200 : 500;

            var strum = new FlxSprite(200 + i * spacing, yPos);
            strum.makeGraphic(80, 80, FlxColor.GRAY);

            playerStrums.push(strum);
            add(strum);
        }

        if(ClientPrefs.mobileOfficialLayout)
            for(opp in opponentStrums)
                opp.visible = false;
    }

    // =========================
    // UI
    // =========================
    function createUI():Void
    {
        healthBar = new FlxSprite(50, 50).makeGraphic(300, 20, FlxColor.GREEN);
        add(healthBar);

        scoreText = new FlxText(50, 80, 400, "Score: 0", 24);
        add(scoreText);

        comboText = new FlxText(50, 110, 400, "Combo: 0", 20);
        add(comboText);

        missText = new FlxText(50, 140, 400, "Misses: 0", 20);
        add(missText);

        debugText = new FlxText(800, 50, 400, "", 16);
        add(debugText);
    }

    // =========================
    // INPUT SYSTEM (FIXED)
    // =========================
    function handleInput():Void
    {
        for(lane in 0...4)
        {
            var pressed = InputManager.lanePress(lane) || mobileControls.isLanePressed(lane);
            var holding = InputManager.laneHold(lane) || mobileControls.isLanePressed(lane);

            if(pressed)
                spawner.pressLane(lane, holding);

            // HOLD CHECK
            spawner.updateHold(lane, holding);
        }
    }

    // =========================
    // HEALTH
    // =========================
    function updateHealth():Void
    {
        smoothHealth = ClientPrefs.smoothHealth
            ? CoolUtil.smoothLerp(smoothHealth, health, ClientPrefs.healthLerp)
            : health;

        healthBar.scale.x = smoothHealth;

        if(health <= 0)
        {
            trace("Player Died");
            // TODO: Game Over logic
        }
    }

    // =========================
    // SCORE
    // =========================
    function updateScore():Void
    {
        displayScore = ClientPrefs.smoothScore
            ? Std.int(CoolUtil.smoothLerp(displayScore, score, ClientPrefs.scoreLerp))
            : score;
    }

    function updateUI():Void
    {
        scoreText.text = ClientPrefs.scoreSeparator
            ? "Score: " + CoolUtil.formatNumber(displayScore)
            : "Score: " + displayScore;

        comboText.text = "Combo: " + combo;
        missText.text = "Misses: " + misses;
    }

    // =========================
    // SCROLL SETTINGS
    // =========================
    function applyScrollSettings():Void
    {
        for(i in 0...playerStrums.length)
        {
            var yPos = ClientPrefs.downScroll
                ? 100
                : (ClientPrefs.mobileOfficialLayout ? FlxG.height - 200 : 500);

            playerStrums[i].y = yPos;

            if(ClientPrefs.middleScroll)
                playerStrums[i].x = FlxG.width / 2 - 200 + i * 120;
        }

        if(ClientPrefs.mobileLaneTiles)
        {
            var positions = playerStrums.map(function(s) return s.x);
            mobileControls.alignLanesWithNotes(positions);
        }
    }

    // =========================
    // DEBUG
    // =========================
    function updateDebug():Void
    {
        debugText.text =
            "BPM: " + Conductor.bpm + "\n" +
            "Beat: " + Conductor.curBeat + "\n" +
            "Step: " + Conductor.curStep + "\n" +
            "Notes: " + spawner.playerNotes.length + "\n" +
            "Health: " + health + "\n" +
            "Combo: " + combo + "\n" +
            "Misses: " + misses;
    }
}
