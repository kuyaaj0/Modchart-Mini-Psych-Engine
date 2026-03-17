package Backend.Utils;

/**
 * Utility helper functions (clean version)
 */
class CoolUtil
{
    // =========================
    // 🎯 LERP FUNCTIONS
    // =========================

    public static function coolLerp(a:Float, b:Float, ratio:Float):Float
    {
        return a + (b - a) * ratio;
    }

    public static function smoothLerp(a:Float, b:Float, ratio:Float):Float
    {
        return a + (b - a) * ratio;
    }

    // =========================
    // 🔒 CLAMP
    // =========================

    public static function clamp(value:Float, min:Float, max:Float):Float
    {
        if (value < min) return min;
        if (value > max) return max;
        return value;
    }

    // =========================
    // 🔢 NUMBER FORMAT
    // =========================

    public static function formatNumber(value:Int):String
    {
        var str:String = Std.string(value);
        var result:String = "";
        var count:Int = 0;

        for (i in 0...str.length)
        {
            var char = str.charAt(str.length - 1 - i);
            result = char + result;

            count++;
            if (count == 3 && i < str.length - 1)
            {
                result = "," + result;
                count = 0;
            }
        }

        return result;
    }

    // =========================
    // 📊 PERCENT FORMAT
    // =========================

    public static function formatPercent(value:Float):String
    {
        return Std.string(Math.round(value * 10000) / 100) + "%";
    }

    // =========================
    // 🎵 BPM HELPER
    // =========================

    public static function bpmToMs(bpm:Float):Float
    {
        return 60000 / bpm;
    }

    // =========================
    // ⏱️ ROUND
    // =========================

    public static function round(value:Float, decimals:Int):Float
    {
        var mult = Math.pow(10, decimals);
        return Math.round(value * mult) / mult;
    }
}
