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
import Game.Funkin.Objects.NoteSpawner;

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
    // NOTES
    // =========================
    var playerNotes:Array<Note> = [];
    var opponentNotes:Array<Note> = [];
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

        // Initialize input system
        InputManager.init();

        // Initialize background
        var bg = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        add(bg);

        // =========================
        // CREATE STRUMS
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
        scoreText = new FlxText(50, 80, 300, "Score: 0", 24);
        add(scoreText);

        // =========================
        // COMBO & MISS TEXT
        // =========================
        comboText = new FlxText(50, 110, 300, "Combo: 0", 20);
        add(comboText);

        missText = new FlxText(50, 140, 300, "Misses: 0", 20);
        add(missText);

        // =========================
        // DEBUG INFO
        // =========================
        debugText = new FlxText(800, 50, 400, "", 16);
        add(debugText);

        // =========================
        // NOTE SPAWNER
        // =========================
        spawner = new NoteSpawner(playerStrums, opponentStrums);
        spawner.init();

        // =========================
        // MOBILE CONTROLS
        // =========================
        mobileControls = new MobileControls();
        touchNotes = new TouchNotes(mobileControls);

        for(strum in playerStrums)
            touchNotes.addNote(strum);

        // =========================
        // APPLY SETTINGS
        // =========================
        applyScrollSettings();

        // =========================
        // START CONDUCTOR
        // =========================
        Conductor.init(120);
        Conductor.onBeat = function() { onBeat(); };
        Conductor.onStep = function() { onStep(); };
        Conductor.start();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        InputManager.update();
        mobileControls.update();
        touchNotes.update();

        // =========================
        // SPAWN NOTES (PLAYER + OPPONENT)
        // =========================
        spawnTimer += elapsed;
        if(spawnTimer >= 1.0) // test spawn every second
        {
            spawnTimer = 0;
            spawner.spawnRandomPlayerNote();
            spawner.spawnRandomOpponentNote();
        }

        // =========================
        // UPDATE NOTES
        // =========================
        updateNotes(elapsed);

        // =========================
        // HANDLE INPUT
        // =========================
        handleInput();

        // =========================
        // UPDATE HEALTH & SCORE
        // =========================
        updateHealth();
        updateScore();
        updateUI();

        // =========================
        // DEBUG DISPLAY
        // =========================
        updateDebug();
    }

    // =========================
    // CREATE STRUM LINES
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
                hitNote(lane);
        }
    }

    function hitNote(lane:Int):Void
    {
        var closest:Note = null;
        var minDistance = 9999;

        for(note in playerNotes)
        {
            if(note.lane == lane && !note.hit)
            {
                var dist = Math.abs(note.y - playerStrums[lane].y);
                if(dist < minDistance)
                {
                    closest = note;
                    minDistance = dist;
                }
            }
        }

        if(closest != null)
        {
            closest.hit = true;
            remove(closest.sprite);
            playerNotes.remove(closest);

            // Visual feedback
            var strum = playerStrums[lane];
            strum.color = FlxColor.WHITE;
            FlxTween.color(strum, strum.color, FlxColor.GRAY, 0.15);

            // Score & health
            score += 100;
            combo += 1;
            health += 0.02;
            health = CoolUtil.clamp(health, 0, 2);
        }
        else
        {
            // Penalty for pressing wrong
            combo = 0;
            health -= 0.02;
        }
    }

    // =========================
    // UPDATE NOTES
    // =========================
    function updateNotes(elapsed:Float):Void
    {
        // Update player notes
        for(note in playerNotes)
        {
            if(note.hit) continue;
            note.update(elapsed, ClientPrefs.downScroll, ClientPrefs.scrollSpeed);

            if(note.isMissed(playerStrums[note.lane].y))
            {
                missNote(note);
            }
        }

        // Update opponent notes
        for(note in opponentNotes)
        {
            note.update(elapsed, ClientPrefs.downScroll, ClientPrefs.scrollSpeed);
        }
    }

    function missNote(note:Note):Void
    {
        note.hit = true;
        remove(note.sprite);
        playerNotes.remove(note);

        misses += 1;
        combo = 0;
        health -= 0.05;
        health = CoolUtil.clamp(health, 0, 2);
        trace("Missed note lane: " + note.lane);
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
    // CONDUCTOR CALLBACKS
    // =========================
    function onBeat():Void
    {
        // Example: flash strums on beat
        for(strum in playerStrums)
        {
            strum.color = FlxColor.YELLOW;
            FlxTween.color(strum, strum.color, FlxColor.GRAY, 0.1);
        }
    }

    function onStep():Void
    {
        // Could spawn notes based on chart step
    }

    // =========================
    // DEBUG UPDATE
    // =========================
    function updateDebug():Void
    {
        debugText.text =
            "BPM: " + Conductor.bpm + "\n" +
            "Beat: " + Conductor.curBeat + "\n" +
            "Step: " + Conductor.curStep + "\n" +
            "Player Notes: " + playerNotes.length + "\n" +
            "Combo: " + combo + "\n" +
            "Misses: " + misses;
    }
}
