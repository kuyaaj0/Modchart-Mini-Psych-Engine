package Modchart.Engine.Modifier.List.False_Paradise;

import Modchart.Backend.Core.ArrowData;
import Modchart.Backend.Parameter.ModchartParameter;
import Backend.Utils.ModchartUtil;
import openfl.geom.Vector3D;

// i just copy it and change the math.sin to positive to negative so it can make it ClockWise lol

class ClockWise extends Modifier {
	override public function render(curPos:Vector3D, params:ModchartParameter) {
		var strumTime = params.songTime + params.distance;
		var centerX = WIDTH * .5;
		var centerY = HEIGHT * .5;
		var radiusOffset = ARROW_SIZE * (params.lane - 1.5);

		var crochet = Adapter.instance.getStaticCrochet();

		// same as CounterClockWise but change to negative math.sin for direction
		var radius = 200 + radiusOffset * cos(strumTime / crochet * .25 / 16 * Math.PI);
		var outX = centerX + cos(strumTime / crochet / 4 * Math.PI) * radius;
		var outY = centerY - sin(strumTime / crochet / 4 * Math.PI) * radius; // - negative math.sin here

		return ModchartUtil.lerpVector3D(
			curPos,
			new Vector3D(outX, outY, 0, 0),
			getPercent('clockwise', params.player)
		);
	}

	override public function shouldRun(params:ModchartParameter):Bool
		return getPercent('clockwise', params.player) != 0;
}
