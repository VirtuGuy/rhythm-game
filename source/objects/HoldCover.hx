package objects;

import backend.Constants;
import flixel.FlxSprite;

/**
 * An `FlxSprite` designed to go directly over where a hold note gets cut off.
 */
class HoldCover extends FlxSprite
{
    public var lifetime:Float = 0;

    public function new()
    {
        super();

        loadGraphic(Paths.getImage('ui/holdCover'), true, 14, 4);
        animation.add('hold', [0, 1, 2, 3, 4, 5], 90, false);
        animation.play('hold');

        setGraphicSize(Std.int(width * Constants.NOTE_SCALE + 4));
        updateHitbox();

        kill();
    }

    override public function update(elapsed:Float)
    {
        if (animation.curAnim?.finished)
            kill();
        super.update(elapsed);
    }

    override public function revive()
    {
        super.revive();
        animation.play('hold');
    }

    public function positionToStrum(strum:StrumNote)
    {
        x = strum.x + strum.width / 2 - width / 2;
        y = strum.y + strum.height / 2 - height / 2;
    }
}