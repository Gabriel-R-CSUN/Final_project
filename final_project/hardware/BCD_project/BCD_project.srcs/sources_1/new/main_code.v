`timescale 1ns / 1ps
// 7 Segment Display main code
module Seven_segment_LED_Display_Controller(
    input clock_125Mhz, // 
    input reset, // reset
    output reg Anode_Activate, // anode signals of the 7-segment LED display
    output reg [6:0] LED_out// cathode patterns of the 7-segment LED display
    );
    reg [26:0] one_second_counter; // counter for generating 1 second clock enable
    wire one_second_enable;// one second enable for counting numbers
    reg [15:0] displayed_number; // counting number to be displayed
    reg [3:0] LED_BCD;
    reg [19:0] refresh_counter; // 20-bit for creating 10.5ms refresh period or 380Hz refresh rate
    wire LED_activating_counter; 
                 // count     0    ->  1  
              // activates    LED1    LED2
             // and repeat
    always @(posedge clock_125Mhz or posedge reset)
    begin
        if(reset==1)
            one_second_counter <= 0;
        else begin
            if(one_second_counter>=99999999) 
                 one_second_counter <= 0;
            else
                one_second_counter <= one_second_counter + 1;
        end
    end 
    assign one_second_enable = (one_second_counter==99999999)?1:0;
    always @(posedge clock_125Mhz or posedge reset)
    begin
        if(reset==1)
            displayed_number <= 0;
        else if(one_second_enable==1)
            displayed_number <= displayed_number + 1;
    end
    always @(posedge clock_125Mhz or posedge reset)
    begin 
        if(reset==1)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 
    assign LED_activating_counter = refresh_counter[19];
    // decoder to generate anode signals 
    always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            Anode_Activate = 4'b1101; 
            // activate LED1
            LED_BCD = ((displayed_number % 1000)%100)/10;
            // the third digit of the 16-bit number
                end
        2'b01: begin
            Anode_Activate = 4'b1110; 
            // activate LED2
            LED_BCD = ((displayed_number % 1000)%100)%10;
            // the fourth digit of the 16-bit number    
               end
        endcase
    end
    // Cathode patterns of the 7-segment LED display 
    always @(*)
    begin
        case(LED_BCD)
        4'b0000: LED_out = 7'b1111110; // "0" 1111110 opposite 0000001   
        4'b0001: LED_out = 7'b0110000; // "1" 0110000 opposite 1001111
        4'b0010: LED_out = 7'b1101101; // "2" 1101101 opposite 0010010
        4'b0011: LED_out = 7'b1111001; // "3" 1111001 opposite 0000110
        4'b0100: LED_out = 7'b0110011; // "4" 0110011 opposite 1001100
        4'b0101: LED_out = 7'b1011011; // "5" 1011011 opposite 0100100
        4'b0110: LED_out = 7'b1011111; // "6" 1011111 opposite 0100000
        4'b0111: LED_out = 7'b1110000; // "7" 1110000 opposite 0001111
        4'b1000: LED_out = 7'b1111111; // "8" 1111111 opposite 0000000    
        4'b1001: LED_out = 7'b1111011; // "9" 1111011 opposite 0000100
        default: LED_out = 7'b1111110; // "0" 1111110 opposite 0000001
        endcase
    end
 endmodule
 