//verilog Logic Circuit final project
//by Amin Rashidbeigi and Alireza Heidari
//February 2017 

//implementation n bit Counter that counts from initail value to zero.

module nBitCounter(count, clk, rst_n,stop_v,max_num);
  parameter n = 7;
 
  output reg [n:0] count;
  input clk;
  input rst_n;
  input stop_v;
  input [n:0] max_num;
 
  // Set the initial value
  initial
    count = 90;
 
  // Increment count on clock
  always @(posedge clk or negedge rst_n)
    if (!rst_n)
      count = max_num;
    else if (!(count[0] || count[1] || count[2] || count[3] || count[4] || count[5] || count[6] || count[7]))
      #20 count = max_num;
    else if (!stop_v)
      count = count - 1;
 
endmodule

//implementation a counter that counts zero. It used for the traffic control
module nBitCounter_1(count, clk, rst_n,stop_v,max_num);
  parameter n = 7;
 
  output reg [n:0] count;
  input clk;
  input rst_n;
  input stop_v;
  input [n:0] max_num;
 
  // Set the initial value
  initial
    count = 90;
 
  // Increment count on clock
  always @(posedge clk or negedge rst_n)
    if (!rst_n)
      count = max_num;
    else if (!stop_v && (count[0] || count[1] || count[2] || count[3] || count[4] || count[5] || count[6] || count[7]))
      count = count - 1;
 
endmodule

//implementation 4 to 1 Mux that determine the input of counter
module mux3( A_light , B_light , num_1 , num_2 , num_3 , num_4 , q );

input A_light , B_light;
input [7:0] num_1,num_2,num_3,num_4;
output [7:0] q;

reg [7:0] q;
wire A_light , B_light;
wire [7:0] num_1,num_2,num_3,num_4;

initial
    q = 89;

always @(A_light or B_light)
begin
   if( A_light && B_light)
      q = num_4;

   if( A_light && !B_light)
      q = num_2;

   if( !A_light && B_light)
      q = num_3;

   if( !A_light && !B_light)
      q = num_1;
end

endmodule

//This module get the 8-bits input and makes hundreds, tens, ones from the input
module binaryToBCD(number, hundreds, tens, ones);
   // I/O Signal Definitions
   input  [7:0] number;
   output reg [3:0] hundreds;
   output reg [3:0] tens;
   output reg [3:0] ones;
   
   // Internal variable for storing bits
   reg [19:0] shift;
   integer i;
   
   always @(number)
   begin
      // Clear previous number and store new number in shift register
      shift[19:8] = 0;
      shift[7:0] = number;
      
      // Loop eight times
      for (i=0; i<8; i=i+1) begin
         if (shift[11:8] >= 5)
            shift[11:8] = shift[11:8] + 3;
            
         if (shift[15:12] >= 5)
            shift[15:12] = shift[15:12] + 3;
            
         if (shift[19:16] >= 5)
            shift[19:16] = shift[19:16] + 3;
         
         // Shift entire register left once
         shift = shift << 1;
      end
      
      // Push decimal numbers to output
      hundreds = shift[19:16];
      tens     = shift[15:12];
      ones     = shift[11:8];
   end
 
endmodule

//implementation the Mealy State Machine. This module the core of program that get the inputs and predict nextStates from the input ...
// ... and presentStates and determine the output of machine
module stateMachine (R, A, B, CLK, RST, Counter,CounterValue,  A_TIME_L, A_TIME_H, B_TIME_L, B_TIME_H, A_LIGHT, B_LIGHT, TEMP);
	input R, A, B, CLK, RST, Counter;
	input[7:0] CounterValue;
  	output [3:0] A_TIME_L;
	output [3:0] A_TIME_H;
	output [3:0] B_TIME_L;
	output [3:0] B_TIME_H;
	output A_LIGHT , B_LIGHT;
	wire [3:0] A_TIME_L;
	wire [3:0] A_TIME_H;
	wire [3:0] B_TIME_L;
	wire [3:0] B_TIME_H;
	reg A_LIGHT , B_LIGHT;
	reg [3:0] presentState, nextState;
	output[3:0] TEMP;
	wire[3:0] TEMP;
//	parameter reggggg = CounterValue;
	parameter S0 = 3'b000 , S1 = 3'b001 , S2 = 3'b010, S3 = 3'b011, S4 = 3'b100, S5 = 3'b101;
//  assign Counter = reggggg;
  always @ (posedge CLK or posedge RST)
      if (RST) presentState = S0;
		else presentState = nextState;
		
	always @ (presentState or Counter or R)
		begin
          if(R) nextState = S0;
			if(~R && A && ~B) nextState = S2;
			if(~R && ~A && B) nextState = S3;
			
			case (presentState)	
				S0:
					begin
						if (~R && ~A && ~B && ~Counter)
							nextState = S0;
						else if (~R && ~A && ~B && Counter)
							nextState = S5;
					end
				S1:
					begin
						if (~R && ~A && ~B && ~Counter)
							nextState = S1;
						else if (~R && ~A && ~B && Counter)
							nextState = S4;
					end
				S2:
					begin
						if (~R && ~A && ~B)
							nextState = S2;
					end
				S3:
					begin
						if (~R && ~A && ~B)
							nextState = S3;
					end
				S4:
					begin
						if (~R && ~A && ~B && ~Counter)
							nextState = S4;
						else if (~R && ~A && ~B && Counter)
							nextState = S0;
					end
				S5:
					begin
						if (~R && ~A && ~B && ~Counter)
							nextState = S5;
						else if (~R && ~A && ~B && Counter)
							nextState = S1;
					end
					
			endcase
		end
  
 	binaryToBCD bbcd1 (CounterValue, TEMP, A_TIME_L, A_TIME_H);
	binaryToBCD bbcd2 (CounterValue, TEMP, B_TIME_L, B_TIME_H);
  
	always @ (presentState or Counter)
		begin
			case(presentState)
				S0:
					begin
						A_LIGHT <= 1;
						B_LIGHT <= 0;
					end
				S1:
					begin
						A_LIGHT <= 0;
						B_LIGHT <= 1;
						
					end
				S2:
					begin
						A_LIGHT <= 1;
						B_LIGHT <= 0;
						
					end
				S3:
					begin
						A_LIGHT <= 0;
						B_LIGHT <= 1;
					end
				S4:
					begin
						A_LIGHT <= 0;
						B_LIGHT <= 0;
					end	
				S5:
					begin
						A_LIGHT <= 0;
						B_LIGHT <= 0;
					end
			endcase
		end
endmodule


//TESTBENCH
module nBitCounter_TB;
   reg clk;
   reg rst_n;
   reg rst_t;
   reg stop_v;
   reg stop_t;
   reg Counter;
   reg A_T;
   reg B_T;
   reg A_L;
   reg B_L;
   wire A_Light,B_Light;
   reg R, A, B,RST;
   reg [7:0] num_1;
   reg [7:0] num_2;
   reg [7:0] num_3;
   reg [7:0] num_4;
   reg [7:0] traffic_num;
   reg [7:0] number;
   wire[3:0] A_TIME_L, A_TIME_H, B_TIME_L, B_TIME_H,TEMP, hundreds, tens, ones;
   
 
   wire [7:0] count;
   wire [7:0] count_t;
   wire [7:0] max_num;
   
   mux3 time_counter ( A_L , B_L , num_1 , num_2 , num_3 , num_4 , max_num );
   nBitCounter uut (count,clk,!R,stop_v,max_num);
   nBitCounter_1 traffic_counter (count_t,clk,rst_t,stop_t,traffic_num);
   stateMachine sm (R, A, B, clk, RST, Counter,count, A_TIME_L, A_TIME_H, B_TIME_L, B_TIME_H, A_Light, B_Light, TEMP);
	 binaryToBCD sms (number, hundreds, tens, ones);

 
   initial begin
      number = 8'b00001111;
			RST = 0;
      R = 0;
			B = 0;
			A = 0;
			num_1 = 4;
      num_2 = 89;
      num_3 = 29;
      num_4 = 9;
      Counter = 0;
      A_L = 1;
      B_L = 0;
      A_T = 0;
      B_T = 0;
      A_L=0;
      A_L=1;
      rst_t = !((A_L && !A_T)||(B_L && !B_T));
      clk = 0;
      rst_n = 1;
      stop_v = 0; 
      stop_t = 0;
      traffic_num = 10;
			#1 RST = 1;
     	#1 RST = 0;
     	#3000 A = 1;
     	#500 R = 1;
     	A=0;
     	#20 R = 0;
     	#3000 B = 1;
     	#500 B =0;
     	R=1;
     	#20 R = 0;
     	#200 A_T = 1;
     	#400 A_T = 0;
      

   end
   always@(A_Light)
      A_L = A_Light;
   always@(B_Light)
      B_L = B_Light;
   always@(count)
      Counter = !(count[0] || count[1] || count[2] || count[3] || count[4] || count[5] || count[6] || count[7]);
   always@(Counter)
      #20 Counter = 0;
   always@(count_t)
      stop_v = !(count_t[0] || count_t[1] || count_t[2] || count_t[3] || count_t[4] || count_t[5] || count_t[6] || count_t[7]);
   always@(A_T or A_L or B_T or B_L)
      rst_t = !((A_L && !A_T)||(B_L && !B_T));
   always
      #10 clk = !clk;
 
endmodule


