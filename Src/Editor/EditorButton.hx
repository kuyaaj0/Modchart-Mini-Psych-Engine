package Editor;

import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.input.touch.FlxTouch;

class EditorButton extends FlxGroup
{
    public var bg:FlxSprite;
    public var label:FlxText;
    public var onClick:Void->Void;

    // =========================
    // BUTTON COLORS & STATES
    // =========================
    var baseColor:Int = FlxColor.GRAY;
    var hoverColor:Int = FlxColor.LIGHT_GRAY;
    var pressColor:Int = FlxColor.WHITE;

    var widthSize:Int;
    var heightSize:Int;

    var isPressed:Bool = false;
    var isHover:Bool = false;

    public function new(x:Float, y:Float, text:String, callback:Void->Void, ?w:Int = 150, ?h:Int = 50)
    {
        super();

        widthSize = w;
        heightSize = h;

        // BACKGROUND SPRITE
        bg = new FlxSprite(x, y).makeGraphic(widthSize, heightSize, baseColor);

        // LABEL
        label = new FlxText(x, y, widthSize, text, 16);
        label.alignment = "center";
        centerLabel();

        // CLICK CALLBACK
        onClick = callback;

        add(bg);
        add(label);
    }

    // =========================
    // CENTER LABEL INSIDE BUTTON
    // =========================
    function centerLabel()
    {
        label.x = bg.x;
        label.y = bg.y + (heightSize - label.height) / 2;
    }

    // =========================
    // UPDATE BUTTON STATE
    // =========================
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        isHover = false;
        isPressed = false;

        // =========================
        // MOUSE INPUT
        // =========================
        if(FlxG.mouse.overlaps(bg))
        {
            isHover = true;
            if(FlxG.mouse.pressed) isPressed = true;
            if(FlxG.mouse.justReleased && onClick != null) onClick();
        }

        // =========================
        // TOUCH INPUT (MOBILE)
        // =========================
        for(touch in FlxG.touches.list)
        {
            var pos = touch.getWorldPosition();

            if(bg.overlapsPoint(pos))
            {
                isHover = true;
                if(touch.pressed) isPressed = true;
                if(touch.justReleased && onClick != null) onClick();
            }
        }

        // =========================
        // VISUAL FEEDBACK
        // =========================
        if(isPressed)
        {
            bg.color = pressColor;
            bg.scale.set(0.95, 0.95); // shrink slightly on press
        }
        else if(isHover)
        {
            bg.color = hoverColor;
            bg.scale.set(1.05, 1.05); // enlarge slightly on hover
        }
        else
        {
            bg.color = baseColor;
            bg.scale.set(1, 1); // normal state
        }

        // Keep label centered after scaling
        centerLabel();
    }

    // =========================
    // CHANGE BUTTON COLORS DYNAMICALLY
    // =========================
    public function setColors(base:Int, hover:Int, press:Int):Void
    {
        baseColor = base;
        hoverColor = hover;
        pressColor = press;
        bg.color = baseColor;
    }

    // =========================
    // CHANGE BUTTON SIZE DYNAMICALLY
    // =========================
    public function setSize(w:Int, h:Int):Void
    {
        widthSize = w;
        heightSize = h;
        bg.makeGraphic(widthSize, heightSize, baseColor);
        centerLabel();
    }

    // =========================
    // CHANGE LABEL TEXT
    // =========================
    public function setText(text:String):Void
    {
        label.text = text;
        centerLabel();
    }
}
