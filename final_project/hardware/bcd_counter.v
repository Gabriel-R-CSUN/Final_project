`timescale 1ns / 1ps

module bcd_cnt(
             input MHZ,
             output reg DP = 1'b1,
             output reg [6:0] A_TO_G,
             output reg [7:0] AN
             );

localparam divisor = 50000000;
reg [25:0] counter = 0;
reg clock = 0;

always@(posedge MHZ) begin
if (counter < divisor) begin
    counter <= counter + 1;
    clock <= clock; 
end

else begin
    counter <= 0;
    clock <= ~clock; end
 end

reg [16:0] refresh_counter = 0; //17 bits wide
always@(posedge MHZ) begin
    refresh_counter <= refresh_counter + 1;
end

reg [3:0] num_one, num_two;
always@(posedge clock) begin

        if(num_one == 4'd9) begin
               num_one <= 0;
        
               if (num_two == 4'd9)
                      num_two <= 0;
             
               else
                      num_two <= num_two + 1; 
         end
                    
         else 
            num_one <= num_one + 1; 
 end                          

 reg [3:0] NUMBER;
 always@(refresh_counter or num_one or num_two) begin

 // digit_per = 0.5 ms ---> digit_freq = 2000 Hz

 // mhz_freq = 100*10^6 Hz

 // bit = log(mhz_freq/digit_freq)/log(2)

 // bit_position = bit - 1

 // refresh_counter[bit_position]

 case(refresh_counter[15]) 
    1'b0: begin
         AN = 8'b11111110;
         NUMBER  = num_one;
    end
    1'b1: begin
         AN = 8'b11111101;
         NUMBER = num_two;
    end
endcase   
end

always@(NUMBER) begin
case(NUMBER)
    0: A_TO_G = 7'b0000001;
    1: A_TO_G = 7'b1001111;
    2: A_TO_G = 7'b0010010;
    3: A_TO_G = 7'b0000110;
    4: A_TO_G = 7'b1001100;
    5: A_TO_G = 7'b0100100;
    6: A_TO_G = 7'b0100000;
    7: A_TO_G = 7'b0001111;
    8: A_TO_G = 7'b0000000;
    9: A_TO_G = 7'b0000100;
    default: A_TO_G = 7'b0000001;
endcase
end


endmodule