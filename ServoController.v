module ServoController (
	input clk,
	input gate_trigger,
	output pwm,
	output reg done_moving
);
	reg [19:0] counter = 0;
	reg [19:0] current_threshold = 20'd50000;
	reg [15:0] step_timer = 0;
	
	assign pwm = (counter < current_threshold);
	
	always @(posedge clk) begin
		
		if (counter == 20'd1000000)
			counter <= 0;
		else
			counter <= counter + 1;
			
		// If Movement is required, start moving
		if ((gate_trigger && current_threshold < 100000) || (!gate_trigger && current_threshold > 50000)) begin
			done_moving <= 1'b0;
		end
		
		step_timer <= step_timer + 1;
		
		if (step_timer >= 16'd1000) begin
			step_timer <= 0;
			
			if (gate_trigger && current_threshold < 20'd100000) begin
				current_threshold <= current_threshold + 1;
				done_moving <= 0;
				
			end else if (!gate_trigger && current_threshold > 20'd50000) begin
				current_threshold <= current_threshold - 1;
				done_moving <= 0;
	
			end else begin
				done_moving <= 1;
			end
		end
		
	end
endmodule
