package backend;

import flixel.sound.FlxSound;
import haxe.Json;
import states.PlayState;

using StringTools;

enum abstract Difficulty(Int) to Int from Int
{
    var EASY:Int = 0;
    var NORMAL:Int = 1;
    var HARD:Int = 2;
}

typedef SongMetadata = {
    songName:String,
    artist:String,
    charter:String,
    bpm:Float,
}

typedef SongChart = {
    speeds:Dynamic,
    notes:Dynamic
}

typedef NoteData = {
    t:Float,
    d:Int,
    l:Float
}

class Song
{
    // Util
    public static inline function getDifficultyName(diff:Difficulty):String
    {
        return switch (diff)
        {
            case EASY: 'easy';
            case NORMAL: 'normal';
            case HARD: 'hard';
        }
    }

    public static inline function formatSongName(song:String):String
        return song.toLowerCase().trim().replace(' ', '-');

    // Song
    public static inline function loadMetadata(song:String):SongMetadata
    {
        if (!Paths.exists(Paths.getMetadata(song)))
        {
            trace('WARNING: NO METADATA FILE FOUND!');
            return { songName: '', bpm: Constants.DEFAULT_BPM, charter: '', artist: '' }
        }

        var content:String = Paths.getText(Paths.getMetadata(song)).trim();
        var metadata:SongMetadata = cast Json.parse(content);

        return metadata;
    }

    public static inline function loadChart(song:String):SongChart
    {
        if (!Paths.exists(Paths.getChart(song)))
        {
            trace('WARNING: NO CHART FILE FOUND!');
            return { notes: {}, speeds: { hard: Constants.DEFAULT_SPEED } }
        }

        var content:String = Paths.getText(Paths.getChart(song)).trim();
        var chart:SongChart = cast Json.parse(content);
        
        return chart;
    }

    public static inline function loadSongForPlayState(song:String, diff:Difficulty)
    {
        PlayState.songId = formatSongName(song);
        PlayState.chart = loadChart(song);
        PlayState.metadata = loadMetadata(song);
        PlayState.diff = diff;
    }

    public static inline function syncSoundToConductor(sound:FlxSound)
    {
        var time:Float = Conductor.instance?.time ?? 0;
        var offset:Float = Conductor.instance?.fixedVisualOffset ?? 0;

        if (Math.abs(sound.time - (time - offset)) > Constants.SYNC_CHECK && sound.playing)
        {
            sound.pause();
            sound.time = time - offset;
            sound.play();
        }
    }

    // Chart
    public static inline function getNotes(chart:SongChart, diff:Difficulty):Array<NoteData>
    {
        var diffName:String = getDifficultyName(diff);
        return cast Reflect.field(chart?.notes ?? {}, diffName) ?? [];
    }

    public static inline function getSpeed(chart:SongChart, diff:Difficulty):Float
    {
        var diffName:String = getDifficultyName(diff);
        return cast Reflect.field(chart?.speeds ?? {}, diffName) ?? Constants.DEFAULT_SPEED;
    }
}