package objects;

import backend.Conductor;
import backend.Constants;
import backend.GameSettings;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import states.PlayState;

enum abstract NoteDirection(Int) to Int from Int
{
    var LEFT:Int = 0;
    var DOWN:Int = 1;
    var UP:Int = 2;
    var RIGHT:Int = 3;
}

/**
 * An `FlxSprite` that scrolls towards a `StrumNote` that the player must hit.
 */
class Note extends FlxSprite
{
    public var direction:NoteDirection;
    public var isHold:Bool;
    public var type:String;

    public var time:Float;
    public var prevNote:Note;

    public var isHoldEnd:Bool = false;
    public var holdNotes:Array<Note> = [];

    public var isHurt:Bool = false;
    public var canMiss:Bool = false;
    public var isChart:Bool = false;

    public var wasHit:Bool = false;
    public var canHit:Bool = false;
    public var isLate:Bool = false;

    public var onChartHit:Void->Void = null;

    private var _ogNoteWidth:Float = 0;
    private var _ogNoteHeight:Float = 0;

    public function new(time:Float, direction:NoteDirection, ?prevNote:Note, ?isHold:Bool = false, ?type:String)
    {
        super(0, -9999);
        this.time = time;
        this.direction = direction % Constants.NOTE_COUNT;
        this.prevNote = prevNote;
        this.isHold = isHold;
        this.type = type;

        // Loads the graphic
        if (!isHold)
        {
            var path:String = '';
            switch (type)
            {
                case 'hurt': path = 'notetypes/hurt'; isHurt = true; canMiss = true;
                default: path = 'notes';
            }

            loadGraphic(Paths.getImage('ui/$path'), true, Constants.NOTE_WIDTH, Constants.NOTE_HEIGHT);
            animation.add('static', [this.direction], 24);
            animation.play('static');
        }
        else
        {
            loadGraphic(Paths.getImage('ui/holdNoteV2'), true, Constants.HOLD_WIDTH, Constants.HOLD_HEIGHT);
            animation.add('hold', [this.direction], 24);
            animation.add('end', [this.direction + Constants.NOTE_COUNT], 24);
            animation.play('hold');
        }

        // Scaling
        setGraphicSize(Std.int(width * Constants.NOTE_SCALE));
        updateHitbox();
        _ogNoteWidth = width;
        _ogNoteHeight = height;

        // Hold
        if (prevNote != null && isHold)
        {
            isHoldEnd = true;

            animation.play('end');
            flipY = GameSettings.downscroll && !isChart;

            updateHoldSize();
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var conductorTime:Float = Conductor.instance?.time ?? 0;
        var inputOffset:Float = Conductor.instance?.fixedInputOffset ?? 0;
        var hitZone:Float = Constants.HIT_ZONE * (Conductor.instance?.playbackRate ?? 1);

        if (!isChart)
        {
            if (isLate && !wasHit)
                canHit = false;
            else
            {
                if (time > conductorTime - inputOffset - hitZone)
                {
                    if (time < conductorTime - inputOffset + hitZone / 2)
                        canHit = true;
                }
                else
                {
                    isLate = true;
                    canHit = true;
                }
            }
        }
        else
        {
            canHit = time <= conductorTime;

            if (canHit)
            {
                if (wasHit) return;
                wasHit = true;

                if (onChartHit != null)
                    onChartHit();
            }
            else
                wasHit = false;
        }
    }

    public function updatePosition(strum:StrumNote)
    {
        // Hides the note if it's offscreen
        visible = !((GameSettings.downscroll && y < -height)
            || (!GameSettings.downscroll && y > FlxG.height + height));
        active = visible;

        // Positions the note
        var strumX:Float = strum.x;
        var strumY:Float = strum.y;

        var songTime:Float = Conductor.instance?.time ?? 0;
        var inputOffset:Float = Conductor.instance?.fixedInputOffset ?? 0;
        var speed:Float = PlayState.instance?.speed ?? Constants.DEFAULT_SPEED;
        var distance:Float = (songTime - time - inputOffset) * (Constants.PIXELS_PER_MS * speed);
        var direction:Int = GameSettings.downscroll ? -1 : 1;
        
        x = strumX;
        if (isHold)
            x += strum.width / 2 - width / 2;
        y = strumY - distance * direction;

        if (isHold)
        {
            y += _ogNoteHeight / 2 * direction;
            if (prevNote != null && isHoldEnd)
                y += (prevNote._ogNoteHeight - height) / 2;
        }

        applyCliprect(strum);
    }

    public function updateHoldSize()
    {
        if (prevNote != null && prevNote.isHold)
        {
            var stepCrotchet:Float = Conductor.instance?.stepCrotchet ?? 0;
            var holdHeight:Float = stepCrotchet * Constants.PIXELS_PER_MS;
            holdHeight *= PlayState.instance?.speed ?? Constants.DEFAULT_SPEED;

            prevNote.animation.play('hold');
            prevNote.isHoldEnd = false;

            prevNote.setGraphicSize(_ogNoteWidth, holdHeight);
            prevNote.updateHitbox();
        }
    }

    public function applyCliprect(strum:StrumNote)
    {
        var strumMid:Float = strum.y + strum.height / 2;

        if (isHold && wasHit && ((!GameSettings.downscroll && y <= strumMid)
            || (GameSettings.downscroll && y - offset.y * scale.y + height >= strumMid)))
        {
            var rect:FlxRect = new FlxRect(0, 0, frameWidth, frameHeight);

            if (GameSettings.downscroll)
            {
                rect.height = (strumMid - y) / scale.y;
                rect.y = frameHeight - rect.height;
            }
            else
            {
                rect.y = (strumMid - y) / scale.y;
                rect.height -= rect.y;
            }
            
            clipRect = rect;
        }
        else
        {
            if (clipRect != null)
                clipRect = null;
        }
    }

    public function getTiming():Float
    {
        var songTime:Float = Conductor.instance?.time ?? 0;
        var inputOffset:Float = Conductor.instance?.fixedInputOffset ?? 0;
        return Math.abs(time - (songTime - inputOffset));
    }

    @:noCompletion
	override function set_clipRect(rect:FlxRect):FlxRect {
		clipRect = rect;
		if (frames != null)
			frame = frames.frames[animation.frameIndex];
		return rect;
	}
}