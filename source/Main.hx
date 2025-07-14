package;

import backend.FPS;
import flixel.FlxGame;
import flixel.util.typeLimit.NextState.InitialState;
import openfl.display.Sprite;

class Main extends Sprite
{
	#if SHOW_FPS
	public static var fpsCounter:FPS;
	#end

	public function new()
	{
		super();

		// Sets up the game
		var state:InitialState = states.InitState; // The state the game starts in
		var framerate:Int = 144; // The framerate the game runs at
		var skipSplash:Bool = true; // Whether or not to skip the HaxeFlixel splash
		var startFullscreen:Bool = false; // Whether or not to start the game in fullscreen

		addChild(new FlxGame(0, 0, state, framerate, framerate, skipSplash, startFullscreen));

		// Adds the FPS counter
		#if SHOW_FPS
		fpsCounter = new FPS(5, 5, 0xFFFFFF);
		// addChild(fpsCounter);
		#end
	}
}
