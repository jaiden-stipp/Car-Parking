module CarParking (
    input clk,
    input InSig,
    input OutSig,
    input reset,
    output [6:0] HEX0,
    output [6:0] HEX1,
	 output [6:0] HEX4,
    output ClosedLight,
    output OpenLight,
    output reg WarningLight,
    output motor
);

    reg [3:0] tens = 0;
    reg [3:0] ones = 0;
    reg [6:0] CarCount = 0;

    // FSM States
    parameter IDLE = 1'b0;
    
    parameter OPEN = 1'b1;
    

    reg state = IDLE;

	 
	 // Convert CarCount to digits for the 7 seg displays
    always @(*) begin
        tens = 0;
        ones = 0;

        if (CarCount >= 30) begin
            tens = 3;
            ones = CarCount - 30;
        end else if (CarCount >= 20) begin
            tens = 2;
            ones = CarCount - 20;
        end else if (CarCount >= 10) begin
            tens = 1;
            ones = CarCount - 10;
        end else begin
            tens = 0;
            ones = CarCount[3:0];
        end
    end

    assign ClosedLight = (CarCount >= 35);
    assign OpenLight   = !ClosedLight;
	
    Bin_to_Display Display0 (.b_num(ones), .seg(HEX0));
    Bin_to_Display Display1 (.b_num(tens), .seg(HEX1));
	 Bin_to_Display #(.INLEN(1)) Display4 (.b_num(state), .seg(HEX4));
	 
	 
	 wire done_moving;
    reg gate_trigger;
 
    ServoController Motor1 (
        .clk(clk),
        .gate_trigger(gate_trigger),
        .pwm(motor),
        .done_moving(done_moving)
    );

	 // Button Debounce Logic
    reg [19:0] in_db, out_db;
    reg In_Button, Out_Button;
    reg In_Prev, Out_Prev;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            in_db <= 0;
            out_db <= 0;
            In_Button <= 0;
            Out_Button <= 0;
            
        end else begin
            if (!InSig)
                in_db <= (in_db < 20'd1_000_000) ? in_db + 1 : in_db;
            else
                in_db <= 0;
					 
				if (!OutSig)
                out_db <= (out_db < 20'd1_000_000) ? out_db + 1 : out_db;
            else
                out_db <= 0;
				
            In_Button <= (in_db >= 20'd1_000_000);
				Out_Button <= (out_db >= 20'd1_000_000);
        end
    end
	 
	 
	// Warning Light Blink
	
    reg [24:0] blink_count = 0;
	 
	 

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            blink_count <= 0;
            WarningLight <= 0;
        end else begin
            blink_count <= blink_count + 1;

            if (blink_count >= 25'd25_000_000) begin
                blink_count <= 0;

                if (CarCount > 30 && CarCount < 35)
                    WarningLight <= ~WarningLight;
                else
                    WarningLight <= 0;
            end
        end
    end
	 
	 // Timer for opening
	 reg [26:0] open_timer;

    // FSM for gate states
	 
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= IDLE;
            CarCount <= 0;
				gate_trigger <= 0;
        end else begin

            case (state)

               IDLE: begin
						gate_trigger <= 0;
						if ((In_Button && !In_Prev && CarCount < 35) || (Out_Button && !Out_Prev && CarCount > 0)) begin
							if (In_Button) CarCount <= CarCount + 1;
							else CarCount <= CarCount - 1;

							gate_trigger <= 1;
							open_timer   <= 0; // Reset timer right as the gate starts to "open"
							state        <= OPEN;
						end
					end

                
                OPEN: begin
						if (open_timer < 100000000)   // 2s at 50 MHz
							open_timer <= open_timer + 1;
						else if (!In_Button && !Out_Button) begin
							gate_trigger <= 0;
							state <= IDLE;
						end
					 end

            endcase

            // update edge detectors
            In_Prev  <= In_Button;
            Out_Prev <= Out_Button;
        end
    end

endmodule
