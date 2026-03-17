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
    // PLAYER NOTES
    // =========================
    var playerNotes:Array<FlxSprite> = [];

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
        // MOBILE CONTROLS
        // =========================
        mobileControls = new MobileControls();
        touchNotes = new TouchNotes(mobileControls);

        // Add all player strums to touchNotes
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

        // Update mobile input
        mobileControls.update();
        touchNotes.update();

        // Spawn notes
        spawnTimer += elapsed;
        if(spawnTimer >= 1.0) // spawn every second for test
        {
            spawnTimer = 0;
            spawnRandomNote();
        }

        // Update notes
        updateNotes(elapsed);

        // Handle input
        handleInput();

        // Update health and score
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

        // Opponent strums
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
            var yPos:Float = ClientPrefs.mobileOfficialLayout ? FlxG.height - 200 : 500;
            var strum = new FlxSprite(200 + i * spacing, yPos);
            strum.makeGraphic(80, 80, FlxColor.GRAY);
            playerStrums.push(strum);
            add(strum);
        }

        // Hide opponent strums if official mobile layout
        if(ClientPrefs.mobileOfficialLayout)
        {
            for(opp in opponentStrums)
                opp.visible = false;
        }
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
        // Hit nearest note in lane
        var closest:FlxSprite = null;
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
            remove(closest);
            playerNotes.remove(closest);

            // Visual feedback
            var strum = playerStrums[lane];
            strum.color = FlxColor.WHITE;
            FlxTween.color(strum, strum.color, FlxColor.GRAY, 0.15);

            // Score & health
            score += 100;
            health += 0.02;
            health = CoolUtil.clamp(health, 0, 2);
        }
    }

    // =========================
    // SPAWN NOTES
    // =========================
    function spawnRandomNote():Void
    {
        var lane = Math.floor(Math.random() * 4);
        var startY = ClientPrefs.downScroll ? -100 : FlxG.height + 100;

        var note = new FlxSprite(playerStrums[lane].x, startY);
        note.makeGraphic(80, 80, FlxColor.BLUE);
        note.lane = lane;
        note.hit = false;

        playerNotes.push(note);
        add(note);
    }

    // =========================
    // UPDATE NOTES
    // =========================
    function updateNotes(elapsed:Float):Void
    {
        for(note in playerNotes)
        {
            if(note.hit) continue;

            // Move note
            note.y += (ClientPrefs.downScroll ? 1 : -1) * 300 * elapsed * ClientPrefs.scrollSpeed;

            // Miss detection
            var hitLine = playerStrums[note.lane].y;
            if((ClientPrefs.downScroll && note.y > hitLine + 50) || (!ClientPrefs.downScroll && note.y < hitLine - 50))
            {
                missNote(note);
            }
        }
    }

    function missNote(note:FlxSprite):Void
    {
        note.hit = true;
        remove(note);
        playerNotes.remove(note);

        // Penalty
        health -= 0.05;
        health = CoolUtil.clamp(health, 0, 2);

        trace("Missed note on lane: " + note.lane);
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
        for(i in 0...playerStrums.length)
        {
            var yPos = ClientPrefs.downScroll
                ? 100
                : (ClientPrefs.mobileOfficialLayout ? FlxG.height - 200 : 500);
            playerStrums[i].y = yPos;

            if(ClientPrefs.middleScroll)
                playerStrums[i].x = FlxG.width / 2 - 200 + i * 120;
        }

        // Align mobile lane buttons with strums
        if(ClientPrefs.mobileLaneTiles)
        {
            var positions = playerStrums.map(function(s) return s.x);
            mobileControls.alignLanesWithNotes(positions);
        }
    }
}
