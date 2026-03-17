package Modchart.Backend.Graphics;

import Modchart.Backend.Graphics.Renders.*;
import Backend.Math.View3D;
import Modchart.Engine.PlayField;

class Context {
	public var parent:PlayField;
	public var view:View3D;

	public var arrowRenderer:ArrowRenderer;
	public var holdRenderer:HoldRenderer;
	public var pathRenderer:PathRenderer;

	public function new(parent:PlayField) {
		this.parent = parent;

		arrowRenderer = new ArrowRenderer(parent);
		holdRenderer = new HoldRenderer(parent);
		pathRenderer = new PathRenderer(parent);

		view = new View3D();
	}
}
