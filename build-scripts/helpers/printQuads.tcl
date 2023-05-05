proc QUAD_print_pair {package_pin stream print_all} {
    if { [string first "XP" [get_property -quiet PIN_FUNC ${package_pin}]] >=0  ||
	 [string first "P_" [get_property -quiet PIN_FUNC ${package_pin}]] >=0  } {
	#only look at the _P side of each pair

	#get the signal name of the _P side
	set name_P [get_ports -quiet -of_objects ${package_pin}]

	#find the _N side pin and name
	set pin_pair [get_property -quiet DIFF_PAIR_PIN ${package_pin}]
	set name_N [get_ports -quiet -of_objects [get_package_pins -quiet ${pin_pair}]]
	   
	set site [get_sites -quiet [get_package_pins -quiet ${package_pin}]]
	set function [get_property -quiet PIN_FUNC   ${package_pin}]
	
	#determine if this is a refclk or a TxRx pair
	set IO_type ""    
	if {[string first "REFCLK" [get_property -quiet PIN_FUNC ${package_pin}]] >= 0} {
	        set IO_type "Ref Clk"
	} else {
	        set IO_type "Tx/Rx"
	}

	if {[string first "PS_" [get_property -quiet PIN_FUNC ${package_pin}]] >= 0} {
	    set IO_type "PS ${IO_type}"
	}
	
	#only print pins if they are used or print_all is selected
	if { ${print_all} != 0 } {
	    if {![string length ${name_P}]} {
		set name_P "un-used"
	    }
	    if {![string length ${name_N}]} {
		set name_N "un-used"
	    }
	}
	
	#print the final entry
	if { [string length ${name_P}]} {
	    puts ${stream} [format "     %-11s : %4s / %4s  :  %20s / %-20s (%-20s : %-20s)" ${IO_type} ${package_pin} ${pin_pair} ${name_P} ${name_N} ${site} ${function}]
	}
    }
}

proc print_QUADs { {stream stdout} {print_all 0} } {
    foreach quad [get_iobanks -filter {BANK_TYPE == BT_MGT}] {
	#loop over MGT banks
	puts ${stream} "QUAD: ${quad}"

	#look for refclk pins
	foreach package_pin [get_package_pins -of_objects ${quad}] {
	        #loop over all FPGA package pins in the QUAD
	    if {[string first "REFCLK" [get_property -quiet PIN_FUNC ${package_pin}]] >= 0} {
		[QUAD_print_pair ${package_pin} ${stream} ${print_all} ]
	    }
	}
	#look for transceiver pins
	foreach package_pin [get_package_pins -of_objects ${quad}] {
	        #loop over all FPGA package pins in the QUAD
	    if {[string first "REFCLK" [get_property -quiet PIN_FUNC ${package_pin}]] == -1} {
		[QUAD_print_pair ${package_pin} ${stream} ${print_all} ]
	    }
	}    
    }
}
