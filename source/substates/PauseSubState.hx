package substates;

import backend.GameSubState;
import states.PlayState;
import ui.UIText;

/**
 * A `GameSubState` used as a pause menu for the game.
 */
class PauseSubState extends GameSubState
{
    var openCooldown:Float = 0;

    override public function new()
    {
        super(0xA0000000);

        var pausedText:UIText = new UIText(0, 0, 0, 'PAUSED', 72);
        pausedText.alignment = CENTER;
        pausedText.y = pausedText.height;
        pausedText.screenCenter(X);
        add(pausedText);

        openCooldown = 1;
    }

    override public function update(elapsed:Float)
    {
        if (openCooldown > 0)
            openCooldown -= elapsed * 10;

        super.update(elapsed);

        if (controls.PAUSE && openCooldown <= 0)
        {
            if (PlayState.instance != null)
                PlayState.instance.resume();
            close();
        }
    }
}