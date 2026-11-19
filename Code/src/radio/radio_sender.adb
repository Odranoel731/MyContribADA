with MicroBit;
with MicroBit.Radio;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with MicroBit.Accelerometer;
with MicroBit.Console; use MicroBit.console;
with Ada.Real_Time; use Ada.Real_Time;
with HAL; use HAL;
with LSM303AGR;

package body radio_sender is

   Frame : MicroBit.Radio.RadioData;
   start : Time;
   data  : LSM303AGR.All_Axes_Data;
   deadLimit : LSM303AGR.Axis_Data := 30; -- Deadzone / sensitivity; Acceleration threshold for below which it doesn't react to.
   driveDir : Directions;
   --elapsed  : Time_Span;
   period : constant Natural := 40; -- ms

   procedure sender is
   use type LSM303AGR.Axis_Data;

      function Direction_Map(data : LSM303AGR.All_Axes_Data) return Directions is
      begin
         if data.X = 0 and data.Y = 0 then -- Should be zero if under deadzones.
            return Stop;
         end if;

         if abs data.X >= abs data.Y then -- Follows the largest axis, for now.
            
            if data.X <= 0 then
               return Right; -- Taped microbit upside down to controller so we flip these.
            else
               return Left;
            end if;
         
         else

            if data.Y <= -30 then -- Negative 30 feels more natural as the threshold for forward/backward when on the PS3 controller.
               return Forward;
            else
               return Backward;
            end if;
            
         end if;

      end Direction_Map;
      

   begin
      start := Clock;
      Put_Line("Initializing radio, setting in TX mode.");
      Frame.Length   := 4;
      Frame.Version  := 12;
      Frame.Group    := 1;
      Frame.Protocol := 14;
      Frame.Payload := (others => 0);
      MicroBit.Radio.Setup (RadioFrequency => 2467,
                           Length         => Frame.Length,
                           Version        => Frame.Version,
                           Group          => Frame.Group,
                           Protocol       => Frame.Protocol);

      loop
         data := MicroBit.Accelerometer.AccelData;

         if abs data.X <= deadLimit then
            data.X := 0;
         end if;
         if abs data.Y <= deadLimit then
            data.X := 0;
         end if;
         if abs data.Z <= deadLimit then
            data.X := 0;
         end if;
         -- Deadzones

         driveDir := Direction_Map(data); -- Uses rules for mapping acceleration data into drive directions.
         Frame.Payload(1) := UInt8 (driveDir'Enum_Rep);
         MicroBit.Radio.Transmit(Frame);
         --elapsed := Clock - start;
         --Put_Line(To_Duration(elapsed)'Image);
         start := start + milliseconds(period);
         delay until(start);
      end loop;
   end sender;

end radio_sender;