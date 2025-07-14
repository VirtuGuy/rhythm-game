package backend;

import flixel.FlxSprite;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

/**
 * A class for storing judgements and handling note judging.
 */
class Judgement
{
    // CLASS

    public static var judgements:Array<Judgement> = [];
    public static var defaultJudgement:Judgement = new Judgement('awful', 0, 15);

    public static inline function load()
    {
        judgements.push(new Judgement('excellent', 35, 300, true));
        judgements.push(new Judgement('good', 70, 100));
        judgements.push(new Judgement('bad', 90, 50));
    }

    public static inline function judgeTiming(timing:Float):Judgement
    {
        judgements.sort((j1, j2) -> FlxSort.byValues(FlxSort.ASCENDING, j1.hitWindow, j2.hitWindow));

        // Gets the judgement
        var judgement:Judgement = defaultJudgement;

        for (daJudgement in judgements)
        {
            if (timing < daJudgement.hitWindow)
            {
                judgement = daJudgement;
                break;
            }
        }

        return judgement;
    }

    public static inline function popup(?judgement:Judgement):FlxSprite
    {
        // Creates the sprite
        var spr = new FlxSprite(10, 0);
        var animName:String = 'miss';
        if (judgement != null) animName = judgement.id;

		spr.loadGraphic(Paths.getImage('ui/judgement'), true, 131, 29);

		spr.animation.add('excellent', [0]);
		spr.animation.add('good', [1]);
		spr.animation.add('bad', [2]);
		spr.animation.add('awful', [3]);
		spr.animation.add('miss', [4]);
		spr.animation.play(animName);

		spr.setGraphicSize(Std.int(spr.width * 3));
		spr.updateHitbox();
		spr.screenCenter(Y);

        // Makes the sprite 100% much more appealing
        spr.moves = true;
		spr.velocity.y = 50;
		spr.acceleration.y = -1000;

		new FlxTimer().start(0.3, _ -> {
			spr.kill();
			spr.destroy();
		});

        return spr;
    }

    // INSTANCE

    public var id:String;
    public var hitWindow:Float;
    public var hitScore:Int;
    public var showSplash:Bool;
    
    public function new(id:String, hitWindow:Float, hitScore:Int, ?showSplash:Bool = false)
    {
        this.id = id;
        this.hitWindow = hitWindow;
        this.hitScore = hitScore;
        this.showSplash = showSplash ?? false;
    }
}