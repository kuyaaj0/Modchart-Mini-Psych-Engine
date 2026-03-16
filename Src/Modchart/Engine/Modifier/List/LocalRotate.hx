package Modchart.Engine.Modifier.List;

import flixel.FlxG;
import Modchart.Backend.Core.ArrowData;
import Modchart.Backend.Parameter.ModifierParameters;
import Backend.Utils.ModchartUtil;

class LocalRotate extends Rotate {
	override public function getOrigin(curPos:Vector3, params:ModifierParameters):Vector3 {
		var fixedLane = Math.round(getKeyCount(params.player) * .5);
		return new Vector3(getReceptorX(fixedLane, params.player), getReceptorY(fixedLane, params.player));
	}

	override public function getRotateName():String
		return 'localRotate';

	override public function shouldRun(params:ModifierParameters):Bool
		return true;
}
