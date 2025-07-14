package backend;

import states.PlayState;
import flixel.util.typeLimit.NextState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class GameState extends FlxTransitionableState
{
    // CLASS

    public static inline function switchState(nextState:NextState, transIn:Bool = true, transOut:Bool = true)
    {
        FlxTransitionableState.skipNextTransIn = !transOut;
        FlxTransitionableState.skipNextTransOut = !transIn;

        FlxG.switchState(nextState);
    }

    public static inline function resetState(transIn:Bool = true, transOut:Bool = true)
    {
        FlxTransitionableState.skipNextTransIn = !transOut;
        FlxTransitionableState.skipNextTransOut = !transIn;
        FlxG.resetState();
    }

    public static inline function pauseGame()
    {
        FlxG.state.persistentUpdate = false;
        FlxTimer.globalManager.active = false;
        FlxTween.globalManager.active = false;
    }

    public static inline function resumeGame()
    {
        FlxG.state.persistentUpdate = true;
        FlxTimer.globalManager.active = true;
        FlxTween.globalManager.active = true;
    }

    // INSTANCE

    public var hudCam:FlxCamera;
    public var subMenuCam:FlxCamera;

    public var conductor(get, never):Conductor;
    public var controls(get, never):Controls;
    inline function get_conductor() return Conductor.instance;
    inline function get_controls() return Controls.instance;

    override public function create()
    {   
        conductor.onStepHit.add(stepHit);
        conductor.onBeatHit.add(beatHit);
        conductor.onSectionHit.add(sectionHit);

        hudCam = new FlxCamera();
        subMenuCam = new FlxCamera();
        hudCam.bgColor = 0x000000;
        subMenuCam.bgColor = 0x000000;

        FlxG.cameras.add(hudCam, false);
        FlxG.cameras.add(subMenuCam, false);

        super.create();
    }

    override public function update(elapsed:Float)
    {
        conductor.update();
        super.update(elapsed);
    }

    override public function openSubState(subState:FlxSubState)
    {
        subState.camera = subMenuCam;
        super.openSubState(subState);
    }

    override public function destroy()
    {
        FlxG.cameras.remove(hudCam);
        FlxG.cameras.remove(subMenuCam);

        conductor.onStepHit.remove(stepHit);
        conductor.onBeatHit.remove(beatHit);
        conductor.onSectionHit.remove(sectionHit);

        super.destroy();
    }

    private function stepHit(step:Int) {}
    private function beatHit(beat:Int) {}
    private function sectionHit(section:Int) {}
}