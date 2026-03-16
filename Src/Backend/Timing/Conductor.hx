package backend.timing;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import haxe.ds.ArraySort;
import backend.Utils.ModchartUtil;

/**
 * Conductor
 * Handles all rhythm timing logic
 */
class Conductor
{
    public static var bpm:Float = 120;
    public static var crochet:Float = 0;
    public static var stepCrochet:Float = 0;

    public static var songPosition:Float = 0;
    public static var lastSongPosition:Float = 0;

    public static var curBeat:Int = 0;
    public static var curStep:Int = 0;

    public static var safeZoneOffset:Float = 45;

    public static var bpmChangeMap:Array<BPMChangeEvent> = [];

    public static var started:Bool = false;
    public static var paused:Bool = false;

    public static var playbackRate:Float = 1.0;

    public static var onBeat:Void->Void;
    public static var onStep:Void->Void;

    /**
     * Initialize conductor
     */
    public static function init(startBPM:Float)
    {
        bpm = startBPM;

        crochet = (60 / bpm) * 1000;
        stepCrochet = crochet / 4;

        songPosition = 0;
        lastSongPosition = 0;

        curBeat = 0;
        curStep = 0;

        bpmChangeMap = [];

        started = false;
        paused = false;
    }

    /**
     * Start song timing
     */
    public static function start()
    {
        songPosition = 0;
        lastSongPosition = 0;

        started = true;
        paused = false;
    }

    /**
     * Pause timing
     */
    public static function pause()
    {
        paused = true;
    }

    /**
     * Resume timing
     */
    public static function resume()
    {
        paused = false;
    }

    /**
     * Stop timing
     */
    public static function stop()
    {
        started = false;
        paused = false;
        songPosition = 0;
        lastSongPosition = 0;
    }

    /**
     * Update timing each frame
     */
    public static function update(elapsed:Float)
    {
        if(!started || paused)
            return;

        lastSongPosition = songPosition;

        songPosition += elapsed * 1000 * playbackRate;

        updateStep();
        updateBeat();
    }

    /**
     * Update step
     */
    static function updateStep()
    {
        var newStep:Int = Math.floor(songPosition / stepCrochet);

        if(newStep != curStep)
        {
            curStep = newStep;

            if(onStep != null)
                onStep();
        }
    }

    /**
     * Update beat
     */
    static function updateBeat()
    {
        var newBeat:Int = Math.floor(songPosition / crochet);

        if(newBeat != curBeat)
        {
            curBeat = newBeat;

            if(onBeat != null)
                onBeat();
        }
    }

    /**
     * Returns beat as float
     */
    public static function getBeatFloat():Float
    {
        return songPosition / crochet;
    }

    /**
     * Returns step as float
     */
    public static function getStepFloat():Float
    {
        return songPosition / stepCrochet;
    }

    /**
     * Change BPM mid song
     */
    public static function changeBPM(newBPM:Float)
    {
        bpm = newBPM;

        crochet = (60 / bpm) * 1000;
        stepCrochet = crochet / 4;
    }

    /**
     * Add BPM change event
     */
    public static function addBPMChange(step:Int, newBPM:Float)
    {
        var event = new BPMChangeEvent(step, newBPM);

        bpmChangeMap.push(event);

        ArraySort.sort(bpmChangeMap, function(a, b)
        {
            return a.step - b.step;
        });
    }

    /**
     * Reset conductor
     */
    public static function reset()
    {
        songPosition = 0;
        lastSongPosition = 0;

        curBeat = 0;
        curStep = 0;

        started = false;
        paused = false;
    }

    /**
     * Set playback speed
     */
    public static function setPlaybackRate(rate:Float)
    {
        playbackRate = rate;
    }

    /**
     * Jump to specific time
     */
    public static function setSongPosition(time:Float)
    {
        songPosition = time;
    }

    /**
     * Check if note can be hit
     */
    public static function canHit(noteTime:Float):Bool
    {
        var diff = Math.abs(noteTime - songPosition);
        return diff <= safeZoneOffset;
    }

    /**
     * Debug info
     */
    public static function getDebug():String
    {
        return
            "BPM: " + bpm + "\n" +
            "Beat: " + curBeat + "\n" +
            "Step: " + curStep + "\n" +
            "SongPos: " + songPosition;
    }
}


/**
 * BPM change event
 */
class BPMChangeEvent
{
    public var step:Int;
    public var bpm:Float;

    public function new(step:Int, bpm:Float)
    {
        this.step = step;
        this.bpm = bpm;
    }
}
