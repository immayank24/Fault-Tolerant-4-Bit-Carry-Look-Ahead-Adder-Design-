`timescale 1ns / 1ps
        //////////////////// VOTER MODULE ///////////////////
module voter (
    input ci1,ci2,ci,
    output couti
);

wire ByPass;

assign ByPass = ~(ci ^ ci2);

wire w1,w2,w3,w4;
assign w1= ci1 & ci2;   
assign w2= ci1 & ci;   
assign w3= ci2 & ci;   
assign w4 = w1 | w2 | w3;
    
assign couti = ByPass ? ci: w4; // Multiplexer 

endmodule


///////////////////////////// CARRY GENERATION LOGIC/////////////////////////
module CGL (
    input [3:0] A,B,
    input Cin,
    output [3:0] C
);

wire [3:0] G;      // Generate signals
wire [3:0] P;      // Propagate signals

// Generate and Propagate logic
    assign G = A & B;           // Bitwise AND for generate
    assign P = A ^ B;           // Bitwise XOR for propagate

    // Carry logic
    assign C[0] = G[0] | (P[0] & Cin);
    assign C[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Cin);
    assign C[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & Cin);
    assign C[3] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | 
                  (P[3] & P[2] & P[1] & P[0] & Cin);


endmodule

module BitSlice_new (
    input a,b, cini,
    output ci1,ci2,Si
);

assign Si = a ^ b ^ cini;

////// FOr Ci1 ////////
wire w1,w2;

assign w1= a&b;
assign w2= cini & (a ^ b);
assign ci1 = w1 | w2;

////////// FOR Ci2 ///////////

wire w3,w4;

assign w3= a&b;
assign w4= cini & (a ^ b);
assign ci2 = w1 | w2;


endmodule


module bin2bcd_5bit(
    input [4:0] bin,       // 5-bit binary input
    output reg [7:0] bcd   // 2-digit BCD output (8 bits: [7:4] tens, [3:0] ones)
);
    integer i;
    always @(bin) begin
        bcd = 0;
        for (i = 0; i < 5; i = i + 1) begin
            // Add-3 correction if needed
            if (bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;
            if (bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3; 
            // Shift left and insert binary bit
            bcd = {bcd[6:0], bin[4-i]};
        end
    end
endmodule

module bcd_to_7seg_dual(
    input [7:0] bcd_in,        // Two BCD digits: [7:4] tens, [3:0] ones
    output reg [6:0] seg_tens, // 7-seg output for tens digit
    output reg [6:0] seg_ones  // 7-seg output for ones digit
);

    // Function to convert a single BCD digit to 7-seg encoding
    function [6:0] bcd_to_seg;
        input [3:0] bcd;
        begin
            case(bcd)
                4'd0: bcd_to_seg = 7'b1000000; // 0
                4'd1: bcd_to_seg = 7'b1111001; // 1
                4'd2: bcd_to_seg = 7'b0100100; // 2
                4'd3: bcd_to_seg = 7'b0110000; // 3
                4'd4: bcd_to_seg = 7'b0011001; // 4
                4'd5: bcd_to_seg = 7'b0010010; // 5
                4'd6: bcd_to_seg = 7'b0000010; // 6
                4'd7: bcd_to_seg = 7'b1111000; // 7
                4'd8: bcd_to_seg = 7'b0000000; // 8
                4'd9: bcd_to_seg = 7'b0010000; // 9
                default: bcd_to_seg = 7'b0111111; // '-' for error
            endcase
        end
    endfunction

    always @(*) begin
        seg_tens = bcd_to_seg(bcd_in[7:4]); // Upper nibble (tens digit)
        seg_ones = bcd_to_seg(bcd_in[3:0]); // Lower nibble (ones digit)
    end

endmodule




module CLA_FPGA(
    input clk,
    input [3:0] a,b,
    input cin,
//    output [3:0] Sum,
//    output C
    output dp1,
    output reg  [7:0]  an,
    output reg  [6:0]  seg 
    );

wire [3:0] Sum;
wire C;
wire [3:0] ci1;
wire [3:0] ci2;
wire [3:0] c_cgl;
wire [3:0] c_voter;

CGL cgl1 (a,b,cin,c_cgl);

//// FOR 1St BIT SLICE ///////////
BitSlice_new b0 (
                 .a(a[0]),
                 .b(b[0]), 
                 .cini(cin),
                 .ci1(ci1[0]),
                 .ci2(ci2[0]),
                 .Si(Sum[0])
);

voter v0 ( .ci1(ci1[0]),
           .ci2(ci2[0]),
           .ci(cin),
           .couti(c_voter[0]));


//// FOR 2nd BIT SLICE ///////////
BitSlice_new b1 (
                 .a(a[1]),
                 .b(b[1]), 
                 .cini(c_voter[0]),
                 .ci1(ci1[1]),
                 .ci2(ci2[1]),
                 .Si(Sum[1])
);

voter v1 ( .ci1(ci1[1]),
           .ci2(ci2[1]),
           .ci(c_cgl[0]),
           .couti(c_voter[1]));
           

//// FOR 3rd BIT SLICE ///////////
BitSlice_new b2 (
                 .a(a[2]),
                 .b(b[2]), 
                 .cini(c_voter[1]),
                 .ci1(ci1[2]),
                 .ci2(ci2[2]),
                 .Si(Sum[2])
);

voter v2 ( .ci1(ci1[2]),
           .ci2(ci2[2]),
           .ci(c_cgl[1]),
           .couti(c_voter[2]));



//// FOR 4th BIT SLICE ///////////
BitSlice_new b3 (
                 .a(a[3]),
                 .b(b[3]), 
                 .cini(c_voter[2]),
                 .ci1(ci1[3]),
                 .ci2(ci2[3]),
                 .Si(Sum[3])
);

voter v3 ( .ci1(ci1[3]),
           .ci2(ci2[3]),
           .ci(c_cgl[2]),
           .couti(c_voter[3]));

assign C = c_voter[3];

wire[4:0] value;

assign value= {C,Sum};

wire [7:0] bcdop;

bin2bcd_5bit conv (.bin(value),
                  .bcd(bcdop)   
                   );

wire [6:0] seg_tens;
wire [6:0] seg_ones;

bcd_to_7seg_dual(
                 .bcd_in(bcdop),        
                 .seg_tens(seg_tens), 
                 .seg_ones(seg_ones)  
);

reg display_select = 0;
    reg [15:0] refresh_count = 0; // clock divider counter
    parameter REFRESH_RATE = 50000; // Adjust for stable flicker-free display

    always @(posedge clk) begin
        refresh_count <= refresh_count + 1;
        if (refresh_count >= REFRESH_RATE) begin
            refresh_count <= 0;
            display_select <= ~display_select; // toggle between two digits
        end
    end
always @(*) begin
        if (display_select == 1'b0) begin
            an  = 8'b11111110; // enable rightmost digit (ones)
            seg = seg_ones;
        end else begin
            an  = 8'b11111101; // enable next digit (tens)
            seg = seg_tens;
        end
    end    
endmodule
