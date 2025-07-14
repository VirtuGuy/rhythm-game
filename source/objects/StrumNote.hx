package objects;

import backend.Constants;
import flixel.FlxSprite;
import objects.Note.NoteDirection;

/**
 * An `FlxSprite` that the notes will scroll to in the game.
 */
class StrumNote extends FlxSprite
{
    public var direction:NoteDirection;

    public function new(direction:NoteDirection)
    {
        super();
        this.direction = direction % Constants.NOTE_COUNT;

        // Loads the graphic
        loadGraphic(Paths.getImage('ui/strums'), true, Constants.NOTE_WIDTH, Constants.NOTE_HEIGHT);
        
        animation.add('static', [this.direction], 24);
        animation.add('press', [this.direction + Constants.NOTE_COUNT], 24);
        animation.add('glow', [this.direction + Constants.NOTE_COUNT * 2], 24);

        animation.play('static');

        // Scaling
        setGraphicSize(Std.int(width * Constants.NOTE_SCALE));
        updateHitbox();
    }
}