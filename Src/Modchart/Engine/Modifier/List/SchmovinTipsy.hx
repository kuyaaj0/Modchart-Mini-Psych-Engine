package Modchart.Engine.Modifier.List;

import Modchart.Backend.Core.ArrowData;
import Modchart.Backend.Parameter.ModifierParameters;

class SchmovinTipsy extends Modifier {
	override public function render(curPos:Vector3, params:ModifierParameters) {
		curPos.y += sin(params.curBeat / 4 * Math.PI + params.lane) * ARROW_SIZEDIV2 * getPercent('schmovinTipsy', params.player);
		return curPos;
	}

	override public function shouldRun(params:ModifierParameters):Bool
		return true;
}
