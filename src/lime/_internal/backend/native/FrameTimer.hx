package lime._internal.backend.native;

import haxe.Timer;

class FrameTimer{

    static var __totalTimeMS:Float = 0;
    static var __startTimeSec:Float;
    static var __timeBlockCount:Int = 0;

    // ------------------------------------------------------------------------
	// Name: ResetTime
	// ------------------------------------------------------------------------
    static inline public function GetTime():Float{
        var t = __totalTimeMS;
        ResetTime();
        return t;
    }

    // ------------------------------------------------------------------------
	// Name: ResetTime
	// ------------------------------------------------------------------------
    static inline function ResetTime(){
        __timeBlockCount = 0;
        __totalTimeMS = 0;
    }

    // ------------------------------------------------------------------------
	// Name: StartTiming
	// ------------------------------------------------------------------------
    static #if INLINE_ON inline #end public function StartTiming(){
        if ( __timeBlockCount == 0 ){
            __startTimeSec = Timer.stamp();
        }
        
        __timeBlockCount++;

        if ( __timeBlockCount > 100 )
            throw(" __timeBlockCount is too high");
    }

    // ------------------------------------------------------------------------
	// Name: EndTiming
	// ------------------------------------------------------------------------
    static #if INLINE_ON inline #end public function EndTiming(){
        __timeBlockCount--;

        if ( __timeBlockCount == 0 ){
            var endTimeSec : Float = Timer.stamp();
            var deltaTimeMS = ((endTimeSec - __startTimeSec) * 1000.0);
            __totalTimeMS += deltaTimeMS;
        }

        if ( __timeBlockCount < 0 )
            __timeBlockCount = 0;
    }
}
