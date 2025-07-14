package states;

import backend.Constants;
import backend.GameState;
import backend.Song;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import objects.Note;
import ui.UIMenuBar;
import ui.UIMenuDropdown;
import ui.UIText;

/**
 * A `GameState` for charting and editing songs.
 */
class ChartEditorState extends GameState
{
    static final gridSize:Int = Constants.CHARTING_GRID_SIZE;
    static final sectionSize:Int = Constants.STEPS_PER_SECTION * gridSize;

    var songId:String = 'test';
    var chart:SongChart = { speeds: { normal: Constants.DEFAULT_SPEED }, notes: { normal: [] } };
    var metadata:SongMetadata = { songName: '', bpm: Constants.DEFAULT_BPM, artist: '', charter: '' };

    var song:FlxSound;

    var bg:FlxBackdrop;
    var separators:FlxTypedGroup<FlxSprite>;

    var notes:FlxTypedGroup<Note>;
    var holdNotes:FlxTypedGroup<Note>;

    var grid:FlxBackdrop;
    var bottomBox:FlxSprite;
    var strumline:FlxSprite;
    var strumlineArrow:FlxSprite;

    var cursorSpr:FlxSprite;
    var menuBar:UIMenuBar;
    var infoText:UIText;

    var camFollow:FlxObject;

    override public function create()
    {
        FlxG.mouse.visible = true;

        song = new FlxSound();
        song.loadEmbedded(Paths.getSong(songId));
        FlxG.sound.list.add(song);

        // Loads the chart
        if (PlayState.chart != null)
            chart = PlayState.chart;
        if (PlayState.metadata != null)
            metadata = PlayState.metadata;

        conductor.time = 0;
        conductor.bpm = metadata.bpm;

        // Background
        bg = new FlxBackdrop(FlxGridOverlay.createGrid(32, 32, 64, 64, true, 0xFF27259F, 0xFF1B1861));
        bg.velocity.set(30, 30);
        bg.scrollFactor.set();
        bg.moves = true;
        add(bg);

        // Grid
        grid = new FlxBackdrop(Paths.getImage('charting/grid'), Y);
        grid.screenCenter();
        grid.active = false;
        add(grid);

        var topBox:FlxSprite = new FlxSprite();
        topBox.makeGraphic(Std.int(grid.width), Std.int(FlxG.height / 1.5), 0xCC000000);
        topBox.active = false;
        topBox.x = grid.x;
        topBox.y = grid.y - topBox.height;
        add(topBox);

        bottomBox = new FlxSprite();
        bottomBox.loadGraphicFromSprite(topBox);
        bottomBox.active = false;
        bottomBox.x = grid.x;
        add(bottomBox);

        separators = new FlxTypedGroup<FlxSprite>();
        add(separators);

        // Notes and strumline
        notes = new FlxTypedGroup<Note>();
        holdNotes = new FlxTypedGroup<Note>();
        add(holdNotes);
        add(notes);

        strumline = new FlxSprite();
        strumline.makeGraphic(Std.int(grid.width), 4, 0xFFFFFFFF);
        strumline.screenCenter(X);
        add(strumline);

        strumlineArrow = new FlxSprite();
        strumlineArrow.loadGraphic(Paths.getImage('charting/arrow'));
        strumlineArrow.setGraphicSize(gridSize / 2);
        strumlineArrow.updateHitbox();
        strumlineArrow.x = getXPos(-strumlineArrow.width - 2);
        add(strumlineArrow);

        cursorSpr = new FlxSprite();
        cursorSpr.makeGraphic(gridSize, gridSize, 0x7EFFFFFF);
        add(cursorSpr);

        super.create();

        reloadGrid();

        // Camera object
        camFollow = new FlxObject();
        camFollow.screenCenter();
        FlxG.camera.follow(camFollow, LOCKON);

        // UI
        addUI();

        infoText = new UIText(0, 0, 0, '', 32);
        infoText.alignment = RIGHT;
        add(infoText);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        // Input and time
        updateInput(elapsed);
        conductor.time = FlxMath.bound(song.playing ? song.time : conductor.time, 0, getSongEnd());

        // Strumline and camera follow
        strumline.y = getYPos(msToGrid(conductor.time));
        strumlineArrow.y = strumline.y - strumlineArrow.height / 2;
        camFollow.y = strumline.y;

        // Info text
        var songTimeStr:String = FlxStringUtil.formatTime(conductor.time / Constants.MS_PER_SEC, true);
        var songLengthStr:String = FlxStringUtil.formatTime(getSongEnd() / Constants.MS_PER_SEC, true);

        infoText.text = 'Time: $songTimeStr/$songLengthStr'
        + '\nStep: ${conductor.step}'
        + '\nBeat: ${conductor.beat}'
        + '\nSection: ${conductor.section}';

        infoText.x = FlxG.width - infoText.width - 4;
        infoText.y = menuBar.back.height + 2;
    }

    function updateInput(elapsed:Float)
    {
        if (!FlxG.keys.pressed.CONTROL)
        {
            if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
            {
                var dir:Int = FlxG.keys.pressed.W ? -1 : 1;
                conductor.time += Constants.FRAMES_PER_SEC * elapsed * 10 * dir;
                if (dir != 0)
                    setSongTime(conductor.time);
            }
            else if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
            {
                var dir:Int = FlxG.keys.justPressed.UP ? -1 : 1;
                conductor.time = conductor.stepCrotchet * (conductor.step + dir);
                setSongTime(conductor.time);
            }
            else if (FlxG.keys.justPressed.PAGEUP || FlxG.keys.justPressed.PAGEDOWN)
            {
                var dir:Int = FlxG.keys.justPressed.PAGEUP ? -1 : 1;
                var time:Float = conductor.stepCrotchet * Constants.STEPS_PER_BEAT;
                conductor.time = time * (conductor.beat + dir);
                setSongTime(conductor.time);
            }
            else if ((FlxG.keys.justPressed.HOME || FlxG.keys.justPressed.END))
            {
                conductor.time = FlxG.keys.justPressed.HOME ? 0 : getSongEnd();
                setSongTime(conductor.time);
            }
            else if (FlxG.keys.justPressed.SPACE)
            {
                if (song.playing)
                    song.pause();
                else
                {
                    song.play(false, conductor.time);
                    Song.syncSoundToConductor(song);
                }
            }
        }
        else
        {
            // Add shortcuts can run while holding control
        }

        // Cursor
        var mouseX:Float = FlxG.mouse.x - grid.x;
        var mouseY:Float = FlxG.mouse.y - grid.y;
        cursorSpr.x = getXPos(Math.floor(mouseX / gridSize) * gridSize);
        cursorSpr.y = getYPos(Math.floor(mouseY / gridSize) * gridSize);

        if (cursorSpr.x < getXPos(0))
            cursorSpr.x = getXPos(0);
        else if (cursorSpr.x > getXPos(grid.width - gridSize))
            cursorSpr.x = getXPos(grid.width - gridSize);
        if (cursorSpr.y < getYPos(0))
            cursorSpr.y = getYPos(0);
        else if (cursorSpr.y > getYPos(msToGrid(getSongEnd())) - gridSize)
            cursorSpr.y = getYPos(msToGrid(getSongEnd())) - gridSize;

        // Note placement
        if (FlxG.mouse.justPressed || FlxG.mouse.justPressedRight)
        {
            var time:Float = gridToMS(cursorSpr.y - grid.y);
            var direction:NoteDirection = getGridDir(cursorSpr.x);
            var length:Float = 0;

            var noteData:NoteData = { t: time, d: direction, l: length }
            var chartNotes:Array<NoteData> = Song.getNotes(chart, PlayState.diff);

            if (FlxG.mouse.justPressed)
            {
                if (mouseX < 0 || mouseX > grid.width) return;
                if (chartNotes.contains(noteData)) return;
                chartNotes.push(noteData);
                chartNotes.sort((note1, note2) -> return FlxSort.byValues(FlxSort.ASCENDING, note1.t, note2.t));
            }
            else
            {
                for (note in notes.members)
                {
                    if (!FlxG.mouse.overlaps(note)) continue;

                    for (data in chartNotes)
                    {
                        if (data.t == note.time && data.d == note.direction)
                        {
                            chartNotes.remove(data);
                            break;
                        }
                    }
                }
            }

            updateSection();
        }
    }

    function reloadGrid()
    {
        conductor.time = 0;
        setSongTime(conductor.time);

        bottomBox.y = getYPos(msToGrid(getSongEnd()));

        // Separators
        while (separators.length != 0)
        {
            separators.members[0].kill();
            separators.members[0].destroy();
            separators.remove(separators.members[0], true);
        }

        for (beat in 0...Std.int(getSongEnd() / conductor.stepCrotchet / Constants.STEPS_PER_BEAT) + 1)
        {
            var sep:FlxSprite = new FlxSprite();
            sep.makeGraphic(Std.int(grid.width), 4, 0xFF000000);
            sep.setPosition(grid.x, getYPos(beat * (gridSize * Constants.STEPS_PER_BEAT)));
            sep.active = false;
            separators.add(sep);
        }
        
        updateSection();
    }

    function updateSection()
    {
        // Clears all the note objects
        while (notes.length != 0)
        {
            notes.members[0].kill();
            notes.members[0].destroy();
            notes.remove(notes.members[0], true);
        }
        while (holdNotes.length != 0)
        {
            holdNotes.members[0].kill();
            holdNotes.members[0].destroy();
            holdNotes.remove(holdNotes.members[0], true);
        }
        
        buildNotes(-1);
        buildNotes(0);
        buildNotes(1);
    }

    function buildNotes(sec:Int)
    {
        // Generates the note objects
        for (noteData in Song.getNotes(chart, PlayState.diff))
        {
            var time:Float = noteData?.t ?? 0;
            var direction:Int = (noteData?.d ?? 0) % Constants.NOTE_COUNT;
            var length:Float = noteData?.l ?? 0;
            var type:String = '';

            if (noteData?.d ?? 0 >= Constants.NOTE_COUNT)
                continue;
            if (!isInSection(time + 1, conductor.section + sec))
                continue;

            // Note
            var note:Note = new Note(time, direction, null, false, type);
            note.isChart = true;
            notes.add(note);

            if (sec == 0)
            {
                note.onChartHit = () -> {
                    if (song.playing)
                        FlxG.sound.play(Paths.getSound('hit'));
                }
            }

            note.setGraphicSize(gridSize, gridSize);
            note.updateHitbox();
            note.x = getXPos(note.direction * gridSize);
            note.y = getYPos(msToGrid(note.time));

            // Hold
            if (length > 0)
            {
                length += conductor.stepCrotchet;

                var hold:Note = new Note(time, direction, null, true, type);
                hold.active = false;
                hold.isChart = true;
                hold.animation.play('hold');
                holdNotes.add(hold);

                var holdEnd:Note = new Note(time + (length - conductor.stepCrotchet), direction, null, true, type);
                holdEnd.active = false;
                holdEnd.isChart = true;
                holdEnd.animation.play('end');
                holdNotes.add(holdEnd);

                hold.setGraphicSize(gridSize - Std.int(hold.width / Constants.NOTE_SCALE), msToGrid(length - conductor.stepCrotchet));
                hold.updateHitbox();
                hold.x = note.x + note.width / 2 - hold.width / 2;
                hold.y = getYPos(msToGrid(hold.time) + note.height / 2);

                holdEnd.setGraphicSize(hold.width, gridSize - Std.int(holdEnd.height / Constants.NOTE_SCALE));
                holdEnd.updateHitbox();
                holdEnd.x = hold.x;
                holdEnd.y = getYPos(msToGrid(holdEnd.time) + note.height / 2);
            }
        }

        notes.sort((i, note1, note2) -> return FlxSort.byValues(i, note1.time, note2.time), FlxSort.DESCENDING);
    }

    function addUI()
    {
        menuBar = new UIMenuBar();

        var menuFile:UIMenuDropdown = menuBar.addDropdown('File', ['New', 'Save', 'Save As', 'Load', 'Exit']);
        menuFile.onMenuClicked = index -> {
            if (index == 4)
                GameState.switchState(() -> new PlayState(), true, true);
        }

        menuBar.addDropdown('Edit', ['Copy', 'Paste', 'Undo', 'Redo']);
        add(menuBar);
    }

    function setSongTime(time:Float)
    {
        song.pause();
        song.time = time;
    }

    function getXPos(x:Float):Float
        return grid.x + x;

    function getYPos(y:Float):Float
        return grid.y + y;

    function msToGrid(ms:Float):Float
        return ms / ((conductor.stepCrotchet * Constants.STEPS_PER_SECTION) / sectionSize);

    function gridToMS(y:Float):Float
        return y * ((conductor.stepCrotchet * Constants.STEPS_PER_SECTION) / sectionSize);

    function getGridDir(x:Float):NoteDirection
        return Std.int((x - grid.x) / gridSize) % Constants.NOTE_COUNT;

    function getSongEnd():Float
        return Math.round(song.length / conductor.stepCrotchet / Constants.STEPS_PER_BEAT) * conductor.stepCrotchet * Constants.STEPS_PER_BEAT;

    function isInSection(time:Float, section:Int):Bool
    {
        var secStart:Float = conductor.stepCrotchet * Constants.STEPS_PER_SECTION * section;
        var secEnd:Float = secStart + conductor.stepCrotchet * Constants.STEPS_PER_SECTION;
        return time >= secStart && time <= secEnd;
    }

    override function beatHit(beat:Int)
    {
        super.beatHit(beat);

        // Beat hit sfx
        if (song.playing)
            FlxG.sound.play(Paths.getSound('metronome'), 0.5);
    }

    override function sectionHit(section:Int)
    {
        super.sectionHit(section);
        updateSection();
    }

    override public function destroy()
    {
        super.destroy();

        FlxG.mouse.visible = false;
        FlxG.sound.list.remove(song, true);
    }
}