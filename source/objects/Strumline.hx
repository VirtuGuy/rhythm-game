package objects;

import backend.Conductor;
import backend.Constants;
import backend.Controls;
import backend.GameSettings;
import backend.Judgement;
import backend.Song;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;
import objects.Note.NoteDirection;

/**
 * An `FlxGroup` containing the notes, strums, and player input system.
 */
class Strumline extends FlxGroup
{
    public var strumBack:FlxSprite;
    public var strums:FlxTypedGroup<StrumNote>;
    public var notes:FlxTypedGroup<Note>;

    public var holdCovers:FlxTypedGroup<HoldCover>;
    public var splashes:FlxTypedGroup<NoteSplash>;

    public var unspawnNotes:Array<Note> = [];

    public var onNoteHit:FlxTypedSignal<Note->Void> = new FlxTypedSignal();
    public var onNoteMiss:FlxTypedSignal<Note->Void> = new FlxTypedSignal();
    public var onNoteGhostMiss:FlxTypedSignal<NoteDirection->Void> = new FlxTypedSignal();
    
    var controls(get, never):Controls;
    var conductor(get, never):Conductor;
    inline function get_controls() return Controls.instance;
    inline function get_conductor() return Conductor.instance;

    public function new()
    {
        super();

        // Objects
        strumBack = new FlxSprite();
        add(strumBack);

        strums = new FlxTypedGroup<StrumNote>();
        createStrums();
        add(strums);

        notes = new FlxTypedGroup<Note>();
		add(notes);

        // Hold note covers
        holdCovers = new FlxTypedGroup<HoldCover>();
        createHoldCovers();
        add(holdCovers);

        // Note splashes
        splashes = new FlxTypedGroup<NoteSplash>();
        add(splashes);

        var tempSplash:NoteSplash = new NoteSplash();
        splashes.add(tempSplash);
    }

    public function updateNotes(speed:Float)
    {
        while (unspawnNotes[0] != null
            && unspawnNotes[0].time - conductor.time < 1800 / speed)
        {
            notes.add(unspawnNotes[0]);
            unspawnNotes.shift();
        }

        notes.forEachAlive(note -> {
            // Note positioning
            var strum:StrumNote = strums.members[note.direction];
            note.updatePosition(strum);

            // Destroy the note if it had been hit or it's off screen.
            if (((!GameSettings.downscroll && note.y < -note.height)
                || (GameSettings.downscroll && note.y > FlxG.height + note.height))
                || (note.wasHit && !note.isHold))
            {
                if (!note.wasHit && !note.canMiss)
                    noteMiss(note);

                note.kill();
                notes.remove(note, true);
                note.destroy();
            }
        });

        notes.sort((i, note1, note2) ->
            return FlxSort.byY(i, note1, note2), !GameSettings.downscroll ? FlxSort.DESCENDING : FlxSort.ASCENDING);
    }

    public function generateNotes(notes:Array<NoteData>)
    {
        for (noteData in notes)
        {
            var time:Float = noteData?.t ?? 0;
            var direction:Int = (noteData?.d ?? 0) % Constants.NOTE_COUNT;
            var length:Float = noteData?.l ?? 0;
            var type:String = '';

            if (noteData?.d ?? 0 >= 4)
                continue;

            var prevNote:Note = null;
            if (unspawnNotes.length > 0)
                prevNote = unspawnNotes[unspawnNotes.length - 1];

            var note:Note = new Note(time, direction, prevNote, false, type);
            unspawnNotes.push(note);

            // Hold
            var holdLength:Int = Math.floor(length / conductor.stepCrotchet);
            var holdNotes:Array<Note> = [];

            if (holdLength > 0)
            {
                for (i in 0...holdLength + 1)
                {
                    prevNote = unspawnNotes[unspawnNotes.length - 1];

                    var holdTime:Float = time + (conductor.stepCrotchet * i);
                    var holdNote:Note = new Note(holdTime, direction, prevNote, true);

                    unspawnNotes.push(holdNote);
                    holdNotes.push(holdNote);
                }
            }

            note.holdNotes = holdNotes.copy();
            for (holdNote in holdNotes)
                holdNote.holdNotes = holdNotes.copy();
        }

        unspawnNotes.sort((note1, note2) -> return FlxSort.byValues(FlxSort.ASCENDING, note1.time, note2.time));
    }

    public function updateInput()
    {
        var presses:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
        var holds:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

        var hitNotes:Array<Note> = notes.members.filter(note ->
            note.canHit && !note.isHold && !note.wasHit && !note.isLate && note.alive);
        var holdNotes:Array<Note> = notes.members.filter(note ->
            note.canHit && note.isHold && !note.wasHit && note.prevNote?.wasHit && note.alive);

        // Hold note pressing
        if (holds.contains(true))
        {
            for (note in holdNotes)
            {
                if (holds[note.direction])
                    noteHit(note);
            }
        }

        // Destroys hold notes that the player fails to properly hit and hold
        var badHoldNotes:Array<Note> = notes.members.filter(note ->
            note.isHold && note.alive && ((note.wasHit && !holds[note.direction])
            /*|| (!note.prevNote?.wasHit && !note.prevNote?.alive)*/));

        for (note in badHoldNotes)
        {
            for (hold in note.holdNotes)
            {
                hold.kill();
                hold.destroy();
            }
            // noteMiss(note);
            break;
        }

        // Note pressing
        if (presses.contains(true))
        {
            var goodNotes:Array<Note> = [];
            var directions:Array<NoteDirection> = [];

            for (note in hitNotes)
            {
                if (directions.contains(note.direction))
                {
                    for (goodNote in goodNotes)
                    {
                        if (goodNote.direction == note.direction && note.time < goodNote.time)
                        {
                            goodNotes.remove(goodNote);
                            goodNotes.push(note);
                            break;
                        }
                    }
                }
                else
                {
                    goodNotes.push(note);
                    directions.push(note.direction);
                }
            }
            
            goodNotes.sort((note1, note2) -> Std.int(note1.time - note2.time));

            if (goodNotes.length != 0)
            {
                // Ghost miss
                if (!GameSettings.ghostTapping)
                {
                    for (direction in 0...presses.length)
                    {
                        if (presses[direction] && !directions.contains(direction))
                            onNoteGhostMiss.dispatch(direction);
                    }
                } 

                // Note press check
                for (goodNote in goodNotes)
                {
                    if (presses[goodNote.direction])
                        noteHit(goodNote);
                }
            }
            else
            {
                // Ghost miss
                if (!GameSettings.ghostTapping)
                {
                    for (direction in 0...presses.length)
                    {
                        if (presses[direction])
                            onNoteGhostMiss.dispatch(direction);
                    }
                }
            }
        }

        // Strum animation
        strums.forEachAlive(strum -> {
            if (holds[strum.direction])
            {
                if (strum.animation.curAnim?.name != 'glow')
                    strum.animation.play('press');
            }
            else
                strum.animation.play('static');
        });
    }

    public function correctHoldScale()
    {
        var holds:Array<Note> = unspawnNotes.filter(note -> note.isHold);
        holds.concat(notes.members.filter(note -> note.isHold));
        for (hold in holds)
            hold.updateHoldSize();
    }

    function noteHit(note:Note)
    {
        if (note.wasHit) return;
        note.wasHit = true;

        // Strum glow
        var strum:StrumNote = strums.members[note.direction];
        strum.animation.play('glow', true);

        // Hold cover
        var holdCover:HoldCover = holdCovers.members[note.direction];
        if (note.isHold)
            holdCover.revive();

        // Miss the note if it was a hurt note instead
        if (note.isHurt)
        {
            noteMiss(note);
            return;
        }

        // Note splash
        var timing:Float = note.getTiming();
		var judgement:Judgement = Judgement.judgeTiming(timing);

        if (judgement.showSplash && !note.isHold)
        {
            var splash:NoteSplash = splashes.recycle(NoteSplash);
            splash.positionToStrum(strum);
        }

        // Note hit sound
        if (!note.isHold && GameSettings.hitSound)
            FlxG.sound.play(Paths.getSound('hit'));

        // Signal
        onNoteHit.dispatch(note);
    }

    function noteMiss(note:Note)
    {
        onNoteMiss.dispatch(note);
    }

    function createStrums()
    {
        // Creates the strums
        for (i in 0...Constants.NOTE_COUNT)
        {
            var strum:StrumNote = new StrumNote(i);
            var spacing:Float = Constants.STRUM_SPACING;
            var yoff:Float = Constants.STRUM_YOFF;
            var width:Float = strum.width + spacing;

            strum.x = (FlxG.width / 2 + width * i) - ((width - spacing / Constants.NOTE_COUNT) * Constants.NOTE_COUNT) / 2;
            strum.y = strum.height / 2;

            if (GameSettings.downscroll)
                strum.y = FlxG.height - (strum.y + strum.height);
            strum.y += yoff * (GameSettings.downscroll ? -1 : 1);
            
            strums.add(strum);
        }

        // Strum background
        var width:Float = (Constants.NOTE_WIDTH * Constants.NOTE_SCALE) + Constants.STRUM_SPACING;
        width *= Constants.NOTE_COUNT;
        width += Constants.STRUM_SPACING * 2;

        strumBack.makeGraphic(Std.int(width), Std.int(FlxG.height * 1.4), 0xFF000000);
        strumBack.screenCenter();

        strumBack.alpha = GameSettings.strumBackground / 100;
    }

    function createHoldCovers()
    {
        for (i in 0...Constants.NOTE_COUNT)
        {
            var holdCover:HoldCover = new HoldCover();
            holdCover.positionToStrum(strums.members[i]);
            holdCovers.add(holdCover);
        }
    }
}