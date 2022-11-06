module voltage2distance_array2(
  input  logic        clk, 
  input  logic [12:0] voltage,
  output logic [12:0] distance);

  logic [12-1:0] my_rom[2**12-1:0]; // i.e. [data_width-1:0] my_rom[2**addr_width-1:0];
  
  initial begin // normally we don't use initial in RTL code, this is an exception
    $readmemh("v2d_rom.txt",my_rom); // reads hexadecimal data from v2d_rom and places into my_rom
  end
    
  //assign  distance = my_rom[voltage];
  always @(posedge clk) // original, works  
    distance = my_rom[voltage];
  
endmodule

/*
module voltage2distance_array2(
  input  logic [12:0] voltage,
  output logic [12:0] distance);

  logic [12-1:0] my_rom[2**12-1:0]; // i.e. [data_width-1:0] my_rom[2**addr_width-1:0];
  
  initial begin // normally we don't use initial in RTL code, this is an exception
    $readmemh("v2d_rom.txt",my_rom); // reads hexadecimal data from v2d_rom and places into my_rom
  end
  
  assign distance = my_rom[voltage];
  
endmodule
*/