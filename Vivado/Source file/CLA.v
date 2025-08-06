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



module CLA_try(
    input [3:0] a,b,
    input cin,
    output [3:0] Sum,
    output C
    
);

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

endmodule
