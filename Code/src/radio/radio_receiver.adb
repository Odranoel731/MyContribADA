with MicroBit;
with MicroBit.Radio;
with MicroBit.Console; use MicroBit.console;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with Ada.Real_Time; use Ada.Real_Time;
with HAL; use HAL;

package body radio_receiver is

   Frame : MicroBit.Radio.RadioData;
   start : Time;
   elapsed  : Time_Span;
   period : constant Natural := 10; -- ms
   fart : constant := 1200; -- fart
   first : Boolean := True;

   procedure receive is
      procedure init is
      begin
         start := Clock;
         Put_Line("Initializing radio, setting in RX mode.");
         Frame.Length   := 4;
         Frame.Version  := 12;
         Frame.Group    := 1;
         Frame.Protocol := 14;
         MicroBit.Radio.Setup (RadioFrequency => 2467,
                              Length         => Frame.Length,
                              Version        => Frame.Version,
                              Group          => Frame.Group,
                              Protocol       => Frame.Protocol);

      end init;
   begin

      if first then
         first := False;
         init;
         MicroBit.Radio.StartReceiving;
      end if;

      --elapsed := Clock - start;
      --Put_Line(elapsed'Image);
      loop
         if MicroBit.Radio.DataReady then
            Frame := MicroBit.Radio.Receive;
            Put_Line(Frame.Payload(1)'Image);
            --exit; -- If using with rest of realtime system, we exit loop after one reading. Otherwise we use just radio.
            Drive(Directions'Enum_Val(Frame.Payload(1)));

         end if;

         delay until(start + milliseconds(period));
      end loop;

   end receive;

end radio_receiver;