package ui;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

/**
 * An `FlxSpriteGroup` designed to work like a dropdown menu for the UI.
 */
class UIMenuDropdown extends FlxSpriteGroup
{
    public var button:UIMenuButton;
    public var menuItems:Array<UIMenuButton> = [];

    public var text:String = '';
    public var items:Array<String> = [];

    public var showingMenu:Bool = false;

    public var onMenuClicked:Int->Void;

    override public function new(text:String = '', items:Array<String>, width:Int = 50, height:Int = 48)
    {
        super();
        this.text = text;
        this.items = items;

        scrollFactor.set();

        button = new UIMenuButton(text, true, width, height);
        button.onClicked = _onClicked;
        add(button);
    }

    override public function update(elapsed:Float)
    {
        // Hide the dropdown menu if the mouse was pressed with hovering over the button
        if (FlxG.mouse.justPressed && !isMouseOver() && showingMenu)
            toggleDropdown();

        super.update(elapsed);
    }

    public function toggleDropdown()
    {
        showingMenu = !showingMenu;

        if (showingMenu)
        {
            var itemY:Float = button.height;

            for (i in 0...items.length)
            {
                var button:UIMenuButton = new UIMenuButton(items[i], false, 100, 32);
                button.y = itemY;
                add(button);

                itemY += button.height;
                menuItems.push(button);

                if (onMenuClicked != null)
                {
                    button.onClicked = () -> {
                        onMenuClicked(i);
                    }
                }
            }
        }
        else
        {
            while (menuItems.length > 0)
            {
                var item:UIMenuButton = menuItems[0];
                item.kill();
                item.destroy();
                menuItems.remove(item);
                remove(item, true);
            }
        }
    }
    
    public function isMouseOver()
    {
        for (item in menuItems)
            if (item.button.mouseOver) return true;
        return button.button.mouseOver;
    }

    private function _onClicked()
        toggleDropdown();
}