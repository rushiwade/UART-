`timescale 1ns/1ps

module tb_uart;

    // Parameters
    localparam CLK_FREQ = 50_000_000;
    localparam BAUD     = 115200;
    localparam CLK_PERIOD = 20; // 50 MHz = 20ns

    // DUT signals
    logic clk;
    logic reset;

    // TX interface
    logic       tx_start;
    logic [7:0] tx_data;
    logic       tx_busy;
    logic       tx_serial;

    // RX interface
    logic       rx_serial;
    logic [7:0] rx_data;
    logic       rx_done;

    // Instantiate DUT
    uart_core #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) dut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_serial(tx_serial),
        .rx_serial(rx_serial),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Test procedure
    initial begin
        $dumpfile("uart_tb.vcd");   // for GTKWave / VCD viewer
        $dumpvars(0, tb_uart);

        // Init
        clk      = 0;
        reset    = 1;
        tx_start = 0;
        tx_data  = 8'h00;

        #100;
        reset = 0;

        // Loopback connection
        force rx_serial = tx_serial;

        // Send a few test bytes
        repeat (5) begin
            send_byte($urandom_range(0,255));
        end

        #100000; // wait
        $display("Simulation finished.");
        $finish;
    end

    // Task: Send one byte via TX
    task send_byte(input [7:0] data);
        begin
            @(negedge clk);
            tx_data  = data;
            tx_start = 1;
            @(negedge clk);
            tx_start = 0;

            wait (tx_busy == 0); // wait until TX completes

            // Check received byte
            @(posedge rx_done);
            if (rx_data !== data) begin
                $error("DATA MISMATCH: Sent %0h, Received %0h", data, rx_data);
            end else begin
                $display("PASS: Sent %0h, Received %0h", data, rx_data);
            end
        end
    endtask

endmodule
