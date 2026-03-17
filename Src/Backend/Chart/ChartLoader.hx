package Backend.Chart;

import haxe.Json;
import sys.io.File;

typedef ChartNote = {
    var time:Float;
    var lane:Int;
    var hold:Bool;
    var length:Float;
}

typedef ChartData = {
    var bpm:Float;
    var notes:Array<ChartNote>;
}

class ChartLoader
{
    public static function load(path:String):ChartData
    {
        var raw:String = File.getContent(path);
        return Json.parse(raw);
    }
}
