#create bit file
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force ${apollo_root_path}/bit/top_${build_name}.bit

#create hwdef file
write_hwdef -file ${apollo_root_path}/os/hw/top_${build_name}.hwdef -force

# create the hwdef files
write_sysdef -hwdef ${apollo_root_path}/os/hw/top_${build_name}.hwdef -bit ${apollo_root_path}/bit/top_${build_name}.bit -file ${apollo_root_path}/os/hw/top_${build_name}.hdf -force

#create any debugging files
write_debug_probes -force ${apollo_root_path}/bit/top_${build_name}.ltx                                                                                                                                 
