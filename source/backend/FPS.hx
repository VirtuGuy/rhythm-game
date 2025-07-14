package backend;

import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * An `FPS` class extension to display memory usage.
 * Originally class extension made by `Kirill Poletaev`
 * with some edits to fit with the game.
 */
class FPS extends TextField
{
	private var times:Array<Float>;
	private var memPeak:Float = 0;

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0x000000) 
	{
		super();
		x = inX;
		y = inY;

		selectable = false;

		defaultTextFormat = new TextFormat(Paths.getFont("cutePixel.ttf"), 16, inCol);

		text = "FPS: ";
		times = [];

		addEventListener(Event.ENTER_FRAME, onEnter);

		width = 170;
		height = 35;
	}
	
	private function onEnter(_)
	{	
		var now = Timer.stamp();
		times.push(now);

		while (times[0] < now - 1)
			times.shift();

		var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
		if (mem > memPeak) memPeak = mem;

		if (visible)
			text = 'FPS: ${times.length}\nMEM: $mem mb / $memPeak mb';
	}
}