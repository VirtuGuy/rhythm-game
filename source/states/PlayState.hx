package states;

import backend.Constants;
import backend.GameState;
import backend.Judgement;
import backend.Song;
import backend.Util;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import objects.Note;
import objects.Strumline;
import substates.PauseSubState;
import ui.UIText;

/**
 * A `GameState` where all the game events occur.
 */
class PlayState extends GameState
{
	public static var instance:PlayState;

	public static var songId:String = '';
	public static var chart:SongChart;
	public static var metadata:SongMetadata;
	public static var diff:Difficulty = NORMAL;

	public var strumline:Strumline;
	public var healthBar:FlxBar;
	public var scoreText:UIText;

	public var score:Int = 0;
	public var health:Float = 0.5;

	public var song:FlxSound;
	public var speed(default, set):Float = 0;

	public var songStarted:Bool = false;
	public var songGenerated:Bool = false;
	public var songEnded:Bool = false;

	public var canPause:Bool = true;

	override public function create()
	{
		super.create();

		instance = this;

		var bg:FlxSprite = new FlxSprite();
		bg.makeGraphic(Std.int(FlxG.width * 1.4), Std.int(FlxG.height * 1.4), FlxColor.BLUE);
		bg.scrollFactor.set();
		add(bg);

		song = new FlxSound();
		song.loadEmbedded(Paths.getSong(songId), false);
		song.onComplete = songEnd;
		#if FLX_PITCH
		song.pitch = conductor.playbackRate;
		#end
		FlxG.sound.list.add(song);

		// Strumline
		strumline = new Strumline();
		strumline.onNoteHit.add(calculateScore);
		strumline.onNoteMiss.add(noteMiss);
		strumline.onNoteGhostMiss.add(noteGhostMiss);
		strumline.cameras = [hudCam];
		add(strumline);

		// Health bar
		healthBar = new FlxBar(0, 0, BOTTOM_TO_TOP, 32, 640, null, '', 0, 1);
		healthBar.createFilledBar(0xFFFF0000, 0xFF00FF00, true, 0xFF000000, 6);
		healthBar.screenCenter(Y);
		healthBar.x = FlxG.width - healthBar.width - 24;
		healthBar.value = health;
		healthBar.cameras = [hudCam];
		add(healthBar);

		// Score text
		scoreText = new UIText(10, 0, 0, 'Score: 0', 48);
		scoreText.y = FlxG.height - scoreText.height;
		scoreText.cameras = [hudCam];
		add(scoreText);

		// Generates the song
		generateSong();
	}

	override public function update(elapsed:Float)
	{
		// Song
		conductor.updateTime();

		if (conductor.time > conductor.fixedVisualOffset && !songStarted && songGenerated && !songEnded)
		{
			song.play();
			songStarted = true;
		}
		if (songStarted && !songEnded)
			Song.syncSoundToConductor(song);

		super.update(elapsed);

		// Notes and input
		strumline.updateNotes(speed);
		if (songGenerated)
			strumline.updateInput();

		// HUD
		health = FlxMath.bound(health, 0, 1);
		hudCam.zoom = Util.lerp(hudCam.zoom, 1, 0.2);

		scoreText.text = 'Score: ' + score;
		healthBar.value = health;

		if (controls.RESET)
		{
			canPause = false;
			GameState.resetState();
		}
		if (controls.PAUSE)
			pause();
		
		if (FlxG.keys.justPressed.SEVEN)
			GameState.switchState(() -> new ChartEditorState(), true, true);
	}

	public function pause()
	{
		if (!canPause) return;

		openSubState(new PauseSubState());

		song.pause();
		GameState.pauseGame();
	}

	public function resume()
	{
		if (songStarted && !songEnded)
			song.play();
		GameState.resumeGame();
	}

	function generateSong()
	{
		speed = Song.getSpeed(chart, diff) / conductor.playbackRate;
		conductor.bpm = metadata?.bpm ?? Constants.DEFAULT_BPM;
		conductor.time = -conductor.crotchet * 4 + conductor.fixedVisualOffset;

		strumline.generateNotes(Song.getNotes(chart, diff));
		songGenerated = true;
	}

	function showJudgement(?judgement:Judgement)
	{
		// Creates the sprite
		var spr = Judgement.popup(judgement);
		spr.cameras = [hudCam];
		add(spr);
	}

	function calculateScore(note:Note)
	{
		var timing:Float = note.getTiming();
		var judgement:Judgement = Judgement.judgeTiming(timing);
		var hitScore:Int = 50;

		if (!note.isHold)
		{
			hitScore = judgement.hitScore;
			showJudgement(judgement);
		}

		score += hitScore;
		health += 0.02;
	}

	function noteMiss(note:Note)
	{
		score -= 50;
		health -= 0.01;
		if (!note.isHold) showJudgement();
	}

	function noteGhostMiss(direction:NoteDirection)
	{
		score -= 10;
		health -= 0.01;
	}

	function songEnd()
	{
		songEnded = true;
		song.stop();
	}

	override function beatHit(beat:Int)
	{
		hudCam.zoom = 1.01;
		super.beatHit(beat);
	}

	override public function destroy()
	{
		FlxG.sound.list.remove(song, true);
		super.destroy();
	}

	// Private
	private function set_speed(value:Float):Float
	{
		this.speed = value;
		if (strumline != null)
			strumline.correctHoldScale();
		return value;
	}
}
