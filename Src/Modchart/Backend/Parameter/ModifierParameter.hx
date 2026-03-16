package Src.Modchart.Backend.Core;

@:publicFields
@:structInit
final class ModifierParameter {
	var songTime:Float;
	var hitTime:Float;
	var distance:Float;
	var curBeat:Float;

	var lane:Int = 0;
	var player:Int = 0;
	var isTapArrow:Bool = false;
}
