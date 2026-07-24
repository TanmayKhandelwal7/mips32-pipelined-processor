
`timescale 1ns / 1ps


module test_mips;
  reg clk1, clk2;
  integer k;

  // Instantiate your processor (make sure the name matches your design)
  pipe_MIPS32 mips (clk1, clk2);

  initial begin
    clk1 = 0; clk2 = 0;
    repeat (200) begin // Increased clock cycles to allow full sorting
      #5 clk1 = 1; #5 clk1 = 0;
      #5 clk2 = 1; #5 clk2 = 0;
    end
  end

  initial begin
    for (k=0; k<31; k=k+1)
      mips.Reg[k] = 0;

    // Load the UNSORTED array into Data Memory
    mips.Mem[100] = 88;
    mips.Mem[101] = 42; 
    mips.Mem[102] = 95;
    mips.Mem[103] = 12;

    // Load the Machine Code
    mips.Mem[0]  = 32'h280a0064; // ADDI R10, R0, 100
    mips.Mem[1]  = 32'h28040003; // ADDI R4, R0, 3
    mips.Mem[2]  = 32'h00000000; // NOP
    mips.Mem[3]  = 32'h38800014; // BEQZ R4, 20 (Jumps to HLT)
    mips.Mem[4]  = 32'h01405800; // ADD R11, R10, R0
    mips.Mem[5]  = 32'h00802800; // ADD R5, R4, R0
    mips.Mem[6]  = 32'h00000000; // NOP
    mips.Mem[7]  = 32'h21610000; // LW R1, 0(R11)
    mips.Mem[8]  = 32'h00000000; // NOP
    mips.Mem[9]  = 32'h21620001; // LW R2, 1(R11)
    mips.Mem[10] = 32'h00000000; // NOP
    mips.Mem[11] = 32'h10411800; // SLT R3, R2, R1
    mips.Mem[12] = 32'h00000000; // NOP
    mips.Mem[13] = 32'h38600002; // BEQZ R3, 2 (Skips swap)
    mips.Mem[14] = 32'h25620000; // SW R2, 0(R11)
    mips.Mem[15] = 32'h25610001; // SW R1, 1(R11)
    mips.Mem[16] = 32'h296b0001; // ADDI R11, R11, 1
    mips.Mem[17] = 32'h2ca50001; // SUBI R5, R5, 1
    mips.Mem[18] = 32'h00000000; // NOP
    mips.Mem[19] = 32'h34a0fff3; // BNEQZ R5, -13 (Jumps to InnerLoop)
    mips.Mem[20] = 32'h2c840001; // SUBI R4, R4, 1
    mips.Mem[21] = 32'h00000000; // NOP
    mips.Mem[22] = 32'h3480ffec; // BNEQZ R4, -20 (Jumps to OuterLoop)
    mips.Mem[23] = 32'hfc000000; // HLT

    mips.PC = 0;
    mips.HALTED = 0;
    mips.TAKEN_BRANCH = 0;

    // Print initial array state
    $display("BEFORE: [%0d, %0d, %0d, %0d]", mips.Mem[100], mips.Mem[101], mips.Mem[102], mips.Mem[103]);
    
    // Wait for the math to finish, then print final array state
    #3500; 
    $display("AFTER:  [%0d, %0d, %0d, %0d]", mips.Mem[100], mips.Mem[101], mips.Mem[102], mips.Mem[103]);
    $finish;
  end
endmodule