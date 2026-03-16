package Modchart.Engine.Modifier.List;

import flixel.FlxG;
import Modchart.Backend.Core.ArrowData;
import Modchart.Backend.Parameter.ModifierParameters;
import Backend.Utils
class FieldRotate extends Rotate {
	override public function getOrigin(curPos:Vector3, params:ModifierParameters):Vector3 {
		var x:Float = (WIDTH * 0.5) - ARROW_SIZE - 54 + ARROW_SIZE * 1.5;
		switch (params.player) {
			case 0:
				x -= WIDTH * 0.5 - ARROW_SIZE * 2 - 100;
			case 1:
				x += WIDTH * 0.5 - ARROW_SIZE * 2 - 100;
		}
		x -= 56;

		return new Vector3(x, HEIGHT * 0.5);
	}

	override public function getRotateName():String
		return 'fieldRotate';

	override public function shouldRun(params:ModifierParameters):Bool
		return true;
}
