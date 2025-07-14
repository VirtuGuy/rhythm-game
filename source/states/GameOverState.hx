package states;

import backend.GameState;
import ui.UIText;

/**
 * A `GameState` that appears after losing the game.
 */
class GameOverState extends GameState
{
    override public function create()
    {
        var gameoverText:UIText = new UIText(0, 0, 0, 'Game Over!', 128);
        gameoverText.color = 0xFFFF0000;
        gameoverText.screenCenter();
        add(gameoverText);

        super.create();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}