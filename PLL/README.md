#PLL and Clock Settings in TM4C123GH6PM
The most fundamental element of any Microprocessor or Microcontroller is Clock Source. Its like heart beat that keeps the Microcontroller/Microprocessor alive and running. If the clock source is removed, the Microcontroller/Microprocessor stops executing the application program. The TM4c123 LaunchPad controller provides 4 clock sources to be customized and used in different scenarios. Two of them are internal to TM4C123GH6PM and two external clock ports are provided to add external clock sources or crystal oscillators. The clock sources includes: <br> <br> <br>
•	Main Oscillator (MOSC)                              [External]  <br>
•	Hibernate OSC                                       [External]  <br>
•	Precision Internal Oscillator (PIOSC)               [Internal]  <br>
•	Low Frequency Internal Oscillator (LFIOSC)          [Internal]  <br>

<br>
<p align="center">
  <img src="../Resources/pll2.png"/>
</p>
<br>
On Tiva TM4C123 the PIOSC is 16MHz with 1% accuracy. LFIOSC is 30KHz with 50% accuracy. External clock crystals of 32.768KHz for Hibernate Oscillator and 16MHz as MOSC. 
<br>
<p align="center">
  <img src="../Resources/xtllaunchpad.png"/>
</p>
<br>

Why MOSC is 16MHz????
This is clear from bellow diagram.

<br>
<p align="center">
  <img src="../Resources/pll.png"/>
</p>
<br>
As shown in above diagram, the MOSC sources 480MHz PLL for USB clock. From Datasheet 

> “To function within the clocking requirements of the USB specification, a crystal of 5, 6, 8, 10, 12, or 16 MHz must be used.” <br>


That is one of the reason a standard high precision 16Mhz crystal is attached at MOSC clock source.
<br>
### Registers:
Two Registers are used to setup PLL, system clock and peripheral clock as shown in above figure. i.e. **RCC** and **RCC2**.
<br>
<br>
<p align="center">
  <img src="../Resources/RCC.png"/>
</p>
<br>
<br>
<p align="center">
  <img src="../Resources/RCC2.png"/>
</p>
<br>
We will use on RCC2 to configure PLL. Following are the steps.
<br>
### Steps:
•	Activate RCC2 to ignore RCC register values except Crystal frequency. **RCC2 -> USERCC2 -> 1** <br>
•	Bypass PLL to isolate it. **RCC2 -> BYPASS2 -> 1** <br>
•	Select MOSC as main clock source to PLL. **RCC2 -> OSCSRC2 -> 0x0** <br>
•	Select clock frequency. **RCC -> XTAL -> 0x15** <br>
•	Enable 400MHz PLL. **RCC2 -> DIV400 -> 1** <br>
We want the frequency to be set to maximum clock frequency allowed for TM4C123GH6PM. From bellow table.

<br>
<p align="center">
  <img src="../Resources/tablesysdiv.png"/>
</p>
<br>

•	Clear SYSDIV2LSB (from above table). **RCC2 -> SYSDIV2LSB -> 0 ** <br>
•	Set the Divisor to be 5. From table (0x02). **RCC2 -> SYSDIV2 -> 0x02** <br>
•	Wait for the PLL to Setup. **While (RIS -> PLLRIS  != 1)** <br>
•	Remove Bypass from PLL to source main clock. **RCC2 -> BYPASS2 -> 0** <br>

<br><br><br>
