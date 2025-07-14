package ui;

import flixel.text.FlxText;

/**
 * An `FlxText` class for UI.
 */
class UIText extends FlxText
{
    override public function new(x:Float = 0, y:Float = 0, fieldWidth:Float = 0, text:String = '',
        size:Int = 32)
    {
        super(x, y, fieldWidth, text, size);
        scrollFactor.set();

        setFormat(Paths.getFont('cutePixel.ttf'), size);
    }
}