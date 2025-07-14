package backend;

import flixel.FlxG;
import flixel.util.FlxSignal.FlxTypedSignal;

/**
 * A class for handling musical timings.
 */
class Conductor
{
    // CLASS

    public static var instance:Conductor;

    // INSTANCE

    public var time:Float = 0;
    public var bpm:Float = 100;

    public var crotchet(get, never):Float;
    public var stepCrotchet(get, never):Float;
    inline function get_crotchet():Float
        return Constants.BEATS_PER_MIN / bpm * Constants.MS_PER_SEC;
    inline function get_stepCrotchet():Float
        return crotchet / Constants.STEPS_PER_BEAT;

    public var fixedVisualOffset(get, never):Float;
    public var fixedInputOffset(get, never):Float;
    inline function get_fixedVisualOffset():Float
        return visualOffset / playbackRate;
    inline function get_fixedInputOffset():Float
        return inputOffset / playbackRate;

    public var step:Int = 0;
    public var beat:Int = 0;
    public var section:Int = 0;

    public var visualOffset:Float = 0;
    public var inputOffset:Float = 0;
    public var playbackRate:Float = 1;

    public var onStepHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
    public var onBeatHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
    public var onSectionHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

    public function new() {}

    public function update()
    {
        var lastStep:Int = step;
        var lastSec:Int = section;

        step = Math.floor(time / stepCrotchet);
        beat = Math.floor(step / Constants.STEPS_PER_BEAT);
        section = Math.floor(step / Constants.STEPS_PER_SECTION);

        if (time > 0)
        {
            if (step != lastStep)
            {
                onStepHit.dispatch(step);
                if (step % Constants.STEPS_PER_BEAT == 0)
                    onBeatHit.dispatch(beat);
            }
        }
        
        if (section != lastSec)
            onSectionHit.dispatch(section);
    }

    public function updateTime()
    {
        time += FlxG.elapsed * Constants.MS_PER_SEC * playbackRate;
    }
}