`timescale 1ns/1ps
module tristate_buffer_bus #(parameter WIDTH = 8)
   (
    input  [WIDTH-1:0] data_in,
    input              enable,
    output [WIDTH-1:0] data_out
    );
   assign data_out = enable ? data_in : {WIDTH{1'bz}};
endmodule // tristate_buffer_bus
