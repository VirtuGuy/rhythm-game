package backend;

import flixel.FlxSubState;
import flixel.util.FlxColor;

/**
 * An `FlxSubState` class with controls.
 */
class GameSubState extends FlxSubState
{
    public var controls(get, never):Controls;
    inline function get_controls() return Controls.instance;

    override public function new(bgColor:FlxColor = FlxColor.TRANSPARENT)
    {
        super(bgColor);
    }
}