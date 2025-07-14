package backend;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionSet;
import flixel.input.keyboard.FlxKey;

enum abstract Action(String) to String from String
{
    var LEFT    = '_left';
    var LEFT_P  = '_left_p';
    var DOWN    = '_down';
    var DOWN_P  = '_down_p';
    var UP      = '_up';
    var UP_P    = '_up_p';
    var RIGHT   = '_right';
    var RIGHT_P = '_right_p';
    var PAUSE   = '_pause';
    var RESET   = '_reset';
}

enum Control
{
    LEFT;
    DOWN;
    UP;
    RIGHT;
    PAUSE;
    RESET;
}

/**
 * A set of actions for hitting notes and menu navigation.
 */
class Controls extends FlxActionSet
{
    public static var instance:Controls;

    var _left:FlxActionDigital     =  new FlxActionDigital(Action.LEFT);
    var _left_p:FlxActionDigital   =  new FlxActionDigital(Action.LEFT_P);
    var _down:FlxActionDigital     =  new FlxActionDigital(Action.DOWN);
    var _down_p:FlxActionDigital   =  new FlxActionDigital(Action.DOWN_P);
    var _up:FlxActionDigital       =  new FlxActionDigital(Action.UP);
    var _up_p:FlxActionDigital     =  new FlxActionDigital(Action.UP_P);
    var _right:FlxActionDigital    =  new FlxActionDigital(Action.RIGHT);
    var _right_p:FlxActionDigital  =  new FlxActionDigital(Action.RIGHT_P);
    var _pause:FlxActionDigital    =  new FlxActionDigital(Action.PAUSE);
    var _reset:FlxActionDigital    =  new FlxActionDigital(Action.RESET);

    public var LEFT(get, never):Bool;    inline function get_LEFT()    return _left.check();
    public var LEFT_P(get, never):Bool;  inline function get_LEFT_P()  return _left_p.check();
    public var DOWN(get, never):Bool;    inline function get_DOWN()    return _down.check();
    public var DOWN_P(get, never):Bool;  inline function get_DOWN_P()  return _down_p.check();
    public var UP(get, never):Bool;      inline function get_UP()      return _up.check();
    public var UP_P(get, never):Bool;    inline function get_UP_P()    return _up_p.check();
    public var RIGHT(get, never):Bool;   inline function get_RIGHT()   return _right.check();
    public var RIGHT_P(get, never):Bool; inline function get_RIGHT_P() return _right_p.check();
    public var PAUSE(get, never):Bool;   inline function get_PAUSE()   return _pause.check();
    public var RESET(get, never):Bool;   inline function get_RESET()   return _reset.check();

    public function new()
    {
        super('controls');

        // Adds the actions
        add(_left);
        add(_left_p);
        add(_down);
        add(_down_p);
        add(_up);
        add(_up_p);
        add(_right);
        add(_right_p);
        add(_pause);
        add(_reset);

        // Binds the keys
        bindKeys(Control.LEFT, [A, FlxKey.LEFT, NUMPADFOUR]);
        bindKeys(Control.DOWN, [S, FlxKey.DOWN, NUMPADTWO]);
        bindKeys(Control.UP, [W, FlxKey.UP, NUMPADEIGHT]);
        bindKeys(Control.RIGHT, [D, FlxKey.RIGHT, NUMPADSIX]);
        bindKeys(Control.PAUSE, [ENTER, P]);
        bindKeys(Control.RESET, [R]);
    }

    public function bindKeys(control:Control, keys:Array<FlxKey>)
    {
        forEachControl(control, (digital, state) -> {
            digital.removeAll(true);
            for (key in keys)
                digital.addKey(key, state);
        });
    }

    public function removeKeys(control:Control)
        bindKeys(control, []);

    function forEachControl(control:Control, func:FlxActionDigital->FlxInputState->Void)
    {
        switch (control)
        {
            case LEFT:
                func(_left, PRESSED);
                func(_left_p, JUST_PRESSED);
            case DOWN:
                func(_down, PRESSED);
                func(_down_p, JUST_PRESSED);
            case UP:
                func(_up, PRESSED);
                func(_up_p, JUST_PRESSED);
            case RIGHT:
                func(_right, PRESSED);
                func(_right_p, JUST_PRESSED);
            case PAUSE:
                func(_pause, JUST_PRESSED);
            case RESET:
                func(_reset, JUST_PRESSED);
        }
    }
}