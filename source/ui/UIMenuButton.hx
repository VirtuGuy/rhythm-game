package ui;

import flixel.FlxG;
import flixel.addons.display.FlxExtendedMouseSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

/**
 * A clickable menu button used for UI.
 */
class UIMenuButton extends FlxSpriteGroup
{
    public var button:FlxExtendedMouseSprite;
    public var label:UIText;

    public var text:String;

    public var onClicked:Void->Void;
    public var onReleased:Void->Void;

    private var _justClicked:Bool = false;

    override public function new(text:String = '', centerLabel:Bool = true, width:Int = 50, height:Int = 48)
    {
        super();
        this.text = text;

        scrollFactor.set();

        label = new UIText(0, 0, 0, text, 24);
        label.y = (height - label.height) / 2;
        if (centerLabel)
            label.alignment = CENTER;

        width = Std.int(Math.max(label.width, width));
        if (centerLabel)
            label.x = (width - label.width) / 2;

        button = new FlxExtendedMouseSprite();
        button.makeGraphic(width, height, 0xFF2A2A2A);
        button.clickable = true;
        button.draggable = false;

        add(button);
        add(label);
    }

    override public function update(elapsed:Float)
    {
        // Button click and hover
        if (button.mouseOver)
        {
            if (!_justClicked)
                setBrightness(0.8);
            if (FlxG.mouse.justPressed)
            {
                if (onClicked != null)
                    onClicked();
                setBrightness(0.6);
                _justClicked = true;
            }
        }
        else
            setBrightness(1);

        // Button release
        if (!FlxG.mouse.pressed || !button.mouseOver)
        {
            if (_justClicked)
            {
                if (onReleased != null)
                    onReleased();
            }
            _justClicked = false;
        }

        super.update(elapsed);
    }

    function setBrightness(brightness:Float = 1)
        button.color = FlxColor.fromHSB(button.color.hue, button.color.saturation, brightness);
}