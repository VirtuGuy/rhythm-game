package objects;

import backend.Constants;
import flixel.FlxSprite;

/**
 * An `FlxSprite` that splashes over a `StrumNote` when a note was hit at a good time.
 */
class NoteSplash extends FlxSprite
{
    public function new()
    {
        super();

        loadGraphic(Paths.getImage('ui/splash'), true, 20, 20);
        animation.add('splash', [0, 1, 2, 3, 4, 5], 40, false);
        animation.play('splash');

        setGraphicSize(Std.int(width * Constants.NOTE_SCALE));
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

        animation.play('splash', true);
    }

    public function positionToStrum(strum:StrumNote)
    {
        x = strum.x + strum.width / 2 - width / 2;
        y = strum.y + strum.height / 2 - height / 2;
    }
}