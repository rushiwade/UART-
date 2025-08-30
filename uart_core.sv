module uart_core #(
    parameter CLK_FREQ = 50_000_000,   // 50 MHz
    parameter BAUD     = 115200
)(
    input  logic       clk,
    input  logic       reset,

    // Transmitter interface
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx_busy,
    output logic       tx_serial,

    // Receiver interface
    input  logic       rx_serial,
    output logic [7:0] rx_data,
    output logic       rx_done
);

    // Baud rate divisor
    localparam integer BAUD_DIV = CLK_FREQ / BAUD;

    //-------------------------------
    // UART Transmitter
    //-------------------------------
    logic [$clog2(BAUD_DIV)-1:0] tx_cnt;
    logic [3:0]                  tx_bit_idx;
    logic [9:0]                  tx_shift;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_cnt     <= 0;
            tx_bit_idx <= 0;
            tx_shift   <= 10'b1111111111;
            tx_busy    <= 0;
            tx_serial  <= 1;   // idle line = 1
        end else begin
            if (tx_start && !tx_busy) begin
                // Load frame: {stop=1, data[7:0], start=0}
                tx_shift   <= {1'b1, tx_data, 1'b0};
                tx_busy    <= 1;
                tx_bit_idx <= 0;
                tx_cnt     <= 0;
            end else if (tx_busy) begin
                if (tx_cnt == BAUD_DIV-1) begin
                    tx_cnt    <= 0;
                    tx_serial <= tx_shift[0];
                    tx_shift  <= {1'b1, tx_shift[9:1]}; // shift right, keep stop=1
                    tx_bit_idx <= tx_bit_idx + 1;

                    if (tx_bit_idx == 9) begin
                        tx_busy <= 0; // Done transmitting
                    end
                end else begin
                    tx_cnt <= tx_cnt + 1;
                end
            end
        end
    end

    //-------------------------------
    // UART Receiver
    //-------------------------------
    logic [$clog2(BAUD_DIV)-1:0] rx_cnt;
    logic [3:0]                  rx_bit_idx;
    logic [7:0]                  rx_shift;
    logic                        rx_busy;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_cnt     <= 0;
            rx_bit_idx <= 0;
            rx_shift   <= 0;
            rx_busy    <= 0;
            rx_done    <= 0;
            rx_data    <= 0;
        end else begin
            rx_done <= 0; // default

            if (!rx_busy) begin
                // Look for start bit
                if (rx_serial == 0) begin
                    rx_busy    <= 1;
                    rx_cnt     <= BAUD_DIV/2; // start sampling mid-bit
                    rx_bit_idx <= 0;
                end
            end else begin
                if (rx_cnt == BAUD_DIV-1) begin
                    rx_cnt <= 0;
                    rx_bit_idx <= rx_bit_idx + 1;

                    if (rx_bit_idx < 8) begin
                        // Sample 8 data bits LSB-first
                        rx_shift[rx_bit_idx] <= rx_serial;
                    end else if (rx_bit_idx == 8) begin
                        // Stop bit (ideally check if 1, but ignored for simplicity)
                        rx_data <= rx_shift;
                        rx_done <= 1;
                        rx_busy <= 0;
                    end
                end else begin
                    rx_cnt <= rx_cnt + 1;
                end
            end
        end
    end

endmodule
