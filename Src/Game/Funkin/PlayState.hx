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
import Game.Funkin.Objects.Note;
import Game.Funkin.Spawner.NoteSpawner;

import Mobile.MobileControls;
import Mobile.TouchNotes;
import Mobile.VirtualButton;

class PlayState extends FlxState
{
    // =========================
    // HEALTH & SCORE SYSTEM
    // =========================
    public var health:Float = 1.0;
    public var smoothHealth:Float = 1.0;
    public var score:Int = 0;
    public var displayScore:Int = 0;
    public var combo:Int = 0;
    public var misses:Int = 0;

    // =========================
    // UI ELEMENTS
    // =========================
    var scoreText:FlxText;
    var healthBar:FlxSprite;
    var comboText:FlxText;
    var missText:FlxText;
    var debugText:FlxText;

    // =========================
    // STRUM LINES
    // =========================
    var playerStrums:Array<FlxSprite> = [];
    var opponentStrums:Array<FlxSprite> = [];

    // =========================
    // NOTE SPAWNER
    // =========================
    var spawner:NoteSpawner;

    // =========================
    // MOBILE INPUT
    // =========================
    var mobileControls:MobileControls;
    var touchNotes:TouchNotes;

    // =========================
    // SPAWN TIMER
    // =========================
    var spawnTimer:Float = 0;

    override public function create()
    {
        super.create();

        InputManager.init();

        // BACKGROUND
        var bg = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        add(bg);

        // CREATE STRUM LINES
        createStrums();

        // HEALTH BAR
        healthBar = new FlxSprite(50, 50).makeGraphic(300, 20, FlxColor.GREEN);
        add(healthBar);

        // SCORE & COMBO
        scoreText = new FlxText(50, 80, 300, "Score: 0", 24);
        add(scoreText);
        comboText = new FlxText(50, 110, 300, "Combo: 0", 20);
        add(comboText);
        missText = new FlxText(50, 140, 300, "Misses: 0", 20);
        add(missText);

        // DEBUG
        debugText = new FlxText(800, 50, 400, "", 16);
        add(debugText);

        // INIT NOTE SPAWNER
        spawner = new NoteSpawner(playerStrums);
        spawner.init(ClientPrefs.useNoteImage);

        // MOBILE CONTROLS
        mobileControls = new MobileControls();
        touchNotes = new TouchNotes(mobileControls);
        for(strum in playerStrums) touchNotes.addNote(strum);

        // SCROLL SETTINGS
        applyScrollSettings();

        // START CONDUCTOR
        Conductor.init(120);
        Conductor.onBeat = function() onBeat();
        Conductor.onStep = function() onStep();
        Conductor.start();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        InputManager.update();
        mobileControls.update();
        touchNotes.update();

        // SPAWN TEST NOTES
        spawnTimer += elapsed;
        if(spawnTimer >= 1.0)
        {
            spawnTimer = 0;
            spawner.spawnRandomNote();
        }

        // UPDATE NOTES
        spawner.update(elapsed);

        // HANDLE INPUT
        handleInput();

        // HEALTH & SCORE
        updateHealth();
        updateScore();
        updateUI();

        // DEBUG
        updateDebug();
    }

    // =========================
    // CREATE STRUMS
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
            for(opp in opponentStrums) opp.visible = false;
    }

    // =========================
    // INPUT HANDLING
    // =========================
    function handleInput():Void
    {
        for(lane in 0...4)
        {
            if(InputManager.lanePress(lane) || mobileControls.isLanePressed(lane))
                spawner.hitNoteInLane(lane);
        }
    }

    // =========================
    // HEALTH & SCORE
    // =========================
    function updateHealth():Void
    {
        smoothHealth = ClientPrefs.smoothHealth
            ? CoolUtil.smoothLerp(smoothHealth, health, ClientPrefs.healthLerp)
            : health;

        if(health <= 0) trace("Player Died");
    }

    function updateScore():Void
    {
        displayScore = ClientPrefs.smoothScore
            ? Std.int(CoolUtil.smoothLerp(displayScore, score, ClientPrefs.scoreLerp))
            : score;
    }

    function updateUI():Void
    {
        healthBar.scale.x = smoothHealth;
        scoreText.text = ClientPrefs.scoreSeparator ? "Score: " + CoolUtil.formatNumber(displayScore) : "Score: " + displayScore;
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
            var yPos = ClientPrefs.downScroll ? 100 : (ClientPrefs.mobileOfficialLayout ? FlxG.height - 200 : 500);
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
    // CONDUCTOR CALLBACKS
    // =========================
    function onBeat():Void
    {
        for(strum in playerStrums)
        {
            strum.color = FlxColor.YELLOW;
            FlxTween.color(strum, strum.color, FlxColor.GRAY, 0.1);
        }
    }

    function onStep():Void
    {
        // Optional: spawn notes based on chart steps
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
            "Player Notes: " + spawner.notes.length + "\n" +
            "Combo: " + combo + "\n" +
            "Misses: " + misses;
    }
}
