package backend;

import flixel.FlxG;
import flixel.math.FlxMath;

/**
 * A utility class with useful functions.
 */
class Util
{
    /**
     * A framerate-independent lerp function.
     */
    public static inline function lerp(base:Float, target:Float, ratio:Float):Float
        return FlxMath.lerp(base, target, FlxMath.getElapsedLerp(ratio, FlxG.elapsed));
}