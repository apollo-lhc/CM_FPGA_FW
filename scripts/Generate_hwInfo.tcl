#create bit file
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force ../bit/top.bit

#create hwdef file
write_hwdef -file ../os/hw/top.hwdef -force

# create the hwdef files
write_sysdef -hwdef ../os/hw/top.hwdef -bit ../bit/top.bit -file ../os/hw/top.hdf -force

#create any debugging files
write_debug_probes -force ../bit/top.ltx                                                                                                                                 
