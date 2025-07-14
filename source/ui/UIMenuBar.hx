package ui;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * An `FlxGroup` class used as a menu bar with an intended purpose of containing dropdown menus.
 */
class UIMenuBar extends FlxGroup
{
    public var back:FlxSprite;
    public var items:Array<FlxObject> = [];
    public var spacing:Float = 5;

    override public function new()
    {
        super();

        back = new FlxSprite();
        back.makeGraphic(FlxG.width, 48, 0xFF000000);
        back.alpha = 0.8;
        back.scrollFactor.set();
        add(back);
    }

    public function addItem(item:FlxObject):FlxObject
    {
        var width:Float = 0;

        for (obj in items)
            width += obj.width + spacing;

        item.x = width;
        item.y = back.y;
        add(item);

        items.push(item);

        return item;
    }

    public function addDropdown(text:String = '', items:Array<String>):UIMenuDropdown
        return cast addItem(new UIMenuDropdown(text, items, 50, Std.int(back.height)));
}