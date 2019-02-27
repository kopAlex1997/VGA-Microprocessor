#RESET
set_property PACKAGE_PIN V17 [get_ports RESET]
    set_property IOSTANDARD LVCMOS33 [get_ports RESET]

#VGA
set_property PACKAGE_PIN H19 [get_ports {VGA_COLOUR[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[0]}]
    
set_property PACKAGE_PIN J19 [get_ports {VGA_COLOUR[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[1]}]
    
set_property PACKAGE_PIN N19 [get_ports {VGA_COLOUR[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[2]}]
    
set_property PACKAGE_PIN H17 [get_ports {VGA_COLOUR[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[3]}]
    
set_property PACKAGE_PIN G17 [get_ports {VGA_COLOUR[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[4]}]
    
set_property PACKAGE_PIN D17 [get_ports {VGA_COLOUR[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[5]}]
    
set_property PACKAGE_PIN K18 [get_ports {VGA_COLOUR[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[6]}]
    
set_property PACKAGE_PIN J18 [get_ports {VGA_COLOUR[7]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {VGA_COLOUR[7]}]
    
set_property PACKAGE_PIN P19 [get_ports VGA_HS]
    set_property IOSTANDARD LVCMOS33 [get_ports VGA_HS]
    
set_property PACKAGE_PIN R19 [get_ports VGA_VS]
    set_property IOSTANDARD LVCMOS33 [get_ports VGA_VS] 

#SWITCHES
set_property PACKAGE_PIN W17 [get_ports {buf_sel[2]}]
            set_property IOSTANDARD LVCMOS33 [get_ports {buf_sel[2]}] 
            
set_property PACKAGE_PIN W16 [get_ports {buf_sel[1]}]
            set_property IOSTANDARD LVCMOS33 [get_ports {buf_sel[1]}] 
            
set_property PACKAGE_PIN V16 [get_ports {buf_sel[0]}]
            set_property IOSTANDARD LVCMOS33 [get_ports {buf_sel[0]}]              
                
set_property PACKAGE_PIN R2 [get_ports mv_en_hor]
            set_property IOSTANDARD LVCMOS33 [get_ports mv_en_hor] 
            
set_property PACKAGE_PIN T1 [get_ports mv_en_vert]
            set_property IOSTANDARD LVCMOS33 [get_ports mv_en_vert]         

#CLOCK                     
set_property PACKAGE_PIN W5 [get_ports CLK]
    set_property IOSTANDARD LVCMOS33 [get_ports CLK]
