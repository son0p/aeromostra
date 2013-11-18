/*
  Assignent 4 :: Mental landscape of a phonoaudiologyst ::

for helping evaluation, first appearance of :
    Use of Oscillator: lines 28
    Use of SndBuf : lines 32
    Use of if/else statements : line 149 
    Use of for loop or while : line 140
    Use of variables : line 36
    Use of comments : line 1
    Std.mtof() : line 145
    Random Number : line 185
    Use of Arrays : line 80
    Use of Panning : line 178
    Use of right timing (.6::second quarter notes) : line 63
    Use of right melodic notes (Eb Mixolydian scale) : line 99
    Use of at least three defined functions : line 110 

   */

// Sound chain
Gain master => NRev r => dac;
SndBuf kick => master;
SndBuf hihat => master;
SndBuf snare => master;

// Two basses for phase vibrato (incrementing 1hz to one of them)
TriOsc bass => master; 
TriOsc bass2 => master; 

TriOsc melo  => NRev r2 =>Pan2 p  => dac;
SndBuf2 fx1 => master;
SndBuf2 fx2 => master;

// Audio mixer gain initialization 
.8 => float kickGain;
kickGain => kick.gain;
.1 => float hihatGain;
hihatGain => hihat.gain;
1 => float snareGain;
snareGain => snare.gain;
.3 => float bassGain;
bassGain => bass.gain;
.3 => float bass2Gain;
bass2Gain => bass2.gain;
.1 => float meloGain;
meloGain => melo.gain;
.2 => fx1.gain;
.2 => fx2.gain;
1 => float masterGain;
masterGain => master.gain;
.8 => float  fadeOutGain;
.2 => r.mix;
.2 => r2.mix;

// initialize panning
0 => p.pan;

//set a duration from current time+30 sec
30::second + now => time end;

//define duration
.6::second => dur quarter;

// load soundfiles into path
me.dir() + "/audio/kick_02.wav" => kick.read; // directly to file read
me.dir() + "/audio/hihat_02.wav" => hihat.read;
me.dir() + "/audio/snare_02.wav" => snare.read;
me.dir() + "/audio/stereo_fx_03.wav" => fx1.read;
me.dir() + "/audio/stereo_fx_01.wav" =>  fx2.read;

// set all playheads to end so no sound is made
kick.samples() => kick.pos;
hihat.samples() => hihat.pos;
snare.samples() => snare.pos;
fx1.samples() => fx1.pos;
fx2.samples() => fx2.pos;

// initialize pattern arrays for a  16 step secuencer, with 1's and 0's visual feedback
[1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0] @=> int kickPat1[];
[1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0] @=> int kickPat2[];

[0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0] @=> int snarePat1[];
[0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0] @=> int snarePat2[];

[0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0] @=> int hihatPat1[];
[0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0] @=> int hihatPat2[];

[1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1] @=> int bassPat1[];
[1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1] @=> int bassPat2[];

[0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1] @=> int vibratoPat1[];

[0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0] @=> int meloPat1[];
[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0] @=> int meloPat2[];


// definition of scale
[51, 53, 55, 56, 58, 60, 61, 63, 51, 53, 55, 56, 58, 60, 61, 63] @=> int notes[];

// initialize counter variable
0 => int counter;


/*
  A function (not fully  working yet) to slide bass, 
  I need to pass time to make audible the transition
  in frequency,  
*/
fun void bassSlide(  float interval )
{
  bass.freq() => float freqFrom;
  freqFrom / interval => float freqTo;
  while( freqFrom >= freqTo ) 
    {
      freqFrom - .01  => bass.freq;
      bass.freq() => freqFrom;
    }
}

/*
 for two identical oscillator at same gain, 
 if we shift small amount of hertz in one of them
 then we have a vibrato
*/ 
fun void bassVibrato( int rate )
{
  bass.freq() + rate => bass2.freq; 
}


/*
This function take patterns from MAIN PROGRAM
and instantiate the patterns to play
*/

fun void section( int kickArray[], int snareArray[], int hihatArray[], int bassArray[], int meloArray[] )
{
  //secuencer for bass drume and snare
   for( 0 => int i; i < kickArray.cap(); i++)
     {
       // reset gains
       0 => bass.gain;
       0 => bass2.gain;
       Std.mtof(-200) => melo.freq;
       0 => r.mix;

       // if 1 in array then play kick
       if( kickArray[i] == 1 )
	 {
	   0 => kick.pos;
	 }
       if( snareArray[i] == 1 )
	 {
	   0 => snare.pos;
	 }
       if( hihatArray[i] == 1 )
	 {
	   0 => hihat.pos;
	 }
       /* take gains from top gain initialization
	play root first of note array (root note) */
       if( bassArray[i] == 1 )
	 {
	   bassGain => bass.gain; 
	   bass2Gain => bass2.gain;
	   Std.mtof( notes[0] )/2 => bass.freq;
	   Std.mtof( notes[0] )/2 => bass2.freq;
	   
	 }
        /* take gain from top gain initialization,
	play notes from scale in very high octave, 
	modulate panning*/
        if( meloArray[i] == 1 )
	 {
	   meloGain => melo.gain; 
	   Std.mtof( notes[i]*4 ) => melo.freq;
	   Math.sin( now/1::second*4*pi) => p.pan; // modulate pan 
	 }

	// --- Effects -----
	// Open reverb in part of the pattern
       if ( i > 4 && i < 8)
	 {
	   Math.random2f( .1, .4) => r.mix;
	 }
       // call bassVibrato function adding 2 hertz to one of the basses
       if( i > 8 && i < 12 )
	 {
	   bassVibrato( 2 );
	 }
       // call bassSlide to change octave
       if( i == 12 )
	 {
	   bassSlide( 2 );
	 }
       // play some fx's when counter reach some points
       if( counter == 30)
	 {
	   0 => fx1.pos; 
	 }
       if( counter == 46)
	 {
	   0 => fx2.pos; 
	 }

       // run time
       1::quarter => now;

       // Nasty fadout
       while ( counter > 34)
	 {
	   fadeOutGain - 0.05 => fadeOutGain;
	   fadeOutGain => master.gain ;
	   if ( fadeOutGain < 0)
	     {
	       0 => master.gain;
	     }
	   break;
	 }

       //increment counter to trigger some things
       counter++;  
     }
}


// MAIN PROGRAM 

while( now < end )
{
  // Pattern construction for each section
   <<< " Assignment 4" >>>;
   <<< " Mental landscape of a phonoaudiologyst " >>>;
  
  section(kickPat1, snarePat1, hihatPat1, bassPat1, meloPat1);
  section(kickPat2, snarePat2, hihatPat2, bassPat2, meloPat1);
  section(kickPat1, snarePat2, hihatPat1, bassPat1, meloPat2);  
  
  <<< " _.oOo._" >>>; 
  
  0 => fx2.pos; 
  
  <<< now/second >>>; 
  
  // nasty extra time to fill 30 seconds
  2::second => now;

  <<<  "END, Now ->", now/second >>>;
    
}



