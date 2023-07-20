############## I2C ###############3
set_property PACKAGE_PIN BD17 [get_ports SDA] 
set_property PACKAGE_PIN BD18 [get_ports SCL]
set_property IOSTANDARD LVCMOS18 [get_ports SDA]
set_property IOSTANDARD LVCMOS18 [get_ports SCL]
#################### Clock Pins ###################################################################
set_property PACKAGE_PIN BE26 [get_ports CLK_TC_OUT_P]
set_property PACKAGE_PIN BE27 [get_ports CLK_TC_OUT_N]
set_property IOSTANDARD LVDS [get_ports CLK_TC_*]

set_property PACKAGE_PIN AR17 [get_ports clk_tc_p]
set_property PACKAGE_PIN AR16 [get_ports clk_tc_n]
set_property IOSTANDARD LVDS [get_ports clk_tc_*] 
#set_property PACKAGE_PIN AW18 [get_ports CLK_EXT_DBG_P]
#set_property PACKAGE_PIN AY18 [get_ports CLK_EXT_DBG_N]
#set_property PACKAGE_PIN AY17 [get_ports CLK_EXT_DBG_CLEAN_P]
#set_property PACKAGE_PIN BA17 [get_ports CLK_EXT_DBG_CLEAN_N]
set_property PACKAGE_PIN AT17 [get_ports clk_200_p]
set_property PACKAGE_PIN AU16 [get_ports clk_200_n]
#set_property PACKAGE_PIN AR17 [get_ports CLK_TC_IN_P]
#set_property PACKAGE_PIN AR16 [get_ports CLK_TC_IN_N]
set_property IOSTANDARD LVDS [get_ports clk_200*]
set_property DIFF_TERM_ADV TERM_100 [get_ports clk_200*]

# pin name = CLK_FF0_EC_TD_0_N fullname = 10:CLK_FF0_EC_TD_0_N:C335.2:IC14.BD40 
set_property PACKAGE_PIN BD40 [get_ports {clk_ff_N[0]}]
# pin name = CLK_FF0_EC_TD_0_P fullname = 10:CLK_FF0_EC_TD_0_P:C334.2:IC14.BD39 
set_property PACKAGE_PIN BD39 [get_ports {clk_ff_P[0]}]
# pin name = CLK_FF0_EC_TD_1_N fullname = 10:CLK_FF0_EC_TD_1_N:C322.2:IC14.BC42 
set_property PACKAGE_PIN BC42 [get_ports {clk_ff_N[1]}]
# pin name = CLK_FF0_EC_TD_1_P fullname = 10:CLK_FF0_EC_TD_1_P:C321.2:IC14.BC41 
set_property PACKAGE_PIN BC41 [get_ports {clk_ff_P[1]}]
# pin name = CLK_FF0_EC_0_0_N fullname = 10:CLK_FF0_EC_0_0_N:C67.2:IC14.BB40 
set_property PACKAGE_PIN BB40 [get_ports {clk_ff_N[2]}]
# pin name = CLK_FF0_EC_0_0_P fullname = 10:CLK_FF0_EC_0_0_P:C65.2:IC14.BB39 
set_property PACKAGE_PIN BB39 [get_ports {clk_ff_P[2]}]
# pin name = CLK_FF0_EC_0_1_N fullname = 10:CLK_FF0_EC_0_1_N:C71.2:IC14.AY40 
set_property PACKAGE_PIN AY40 [get_ports {clk_ff_N[3]}]
# pin name = CLK_FF0_EC_0_1_P fullname = 10:CLK_FF0_EC_0_1_P:C69.2:IC14.AY39 
set_property PACKAGE_PIN AY39 [get_ports {clk_ff_P[3]}]
# pin name = CLK_FF0_EC_0_2_N fullname = 10:CLK_FF0_EC_0_2_N:C75.2:IC14.AV40 
set_property PACKAGE_PIN AV40 [get_ports {clk_ff_N[4]}]
# pin name = CLK_FF0_EC_0_2_P fullname = 10:CLK_FF0_EC_0_2_P:C73.2:IC14.AV39 
set_property PACKAGE_PIN AV39 [get_ports {clk_ff_P[4]}]
# pin name = CLK_FF0_EC_1_0_N fullname = 10:CLK_FF0_EC_1_0_N:C68.2:IC14.BA42 
set_property PACKAGE_PIN BA42 [get_ports {clk_ff_N[5]}]
# pin name = CLK_FF0_EC_1_0_P fullname = 10:CLK_FF0_EC_1_0_P:C66.2:IC14.BA41 
set_property PACKAGE_PIN BA41 [get_ports {clk_ff_P[5]}]
# pin name = CLK_FF0_EC_1_1_N fullname = 10:CLK_FF0_EC_1_1_N:C72.2:IC14.AW42 
set_property PACKAGE_PIN AW42 [get_ports {clk_ff_N[6]}]
# pin name = CLK_FF0_EC_1_1_P fullname = 10:CLK_FF0_EC_1_1_P:C70.2:IC14.AW41 
set_property PACKAGE_PIN AW41 [get_ports {clk_ff_P[6]}]
# pin name = CLK_FF0_EC_1_2_N fullname = 10:CLK_FF0_EC_1_2_N:C76.2:IC14.AU42 
set_property PACKAGE_PIN AU42 [get_ports {clk_ff_N[7]}]
# pin name = CLK_FF0_EC_1_2_P fullname = 10:CLK_FF0_EC_1_2_P:C74.2:IC14.AU41 
set_property PACKAGE_PIN AU41 [get_ports {clk_ff_P[7]}]
# pin name = CLK_FF1_0_0_N fullname = 10:CLK_FF1_0_0_N:C199.2:IC14.BB12 
set_property PACKAGE_PIN BB12 [get_ports {clk_ff_N[8]}]
# pin name = CLK_FF1_0_0_P fullname = 10:CLK_FF1_0_0_P:C197.2:IC14.BB13 
set_property PACKAGE_PIN BB13 [get_ports {clk_ff_P[8]}]
# pin name = CLK_FF1_0_1_N fullname = 10:CLK_FF1_0_1_N:C203.2:IC14.AY12 
set_property PACKAGE_PIN AY12 [get_ports {clk_ff_N[9]}]
# pin name = CLK_FF1_0_1_P fullname = 10:CLK_FF1_0_1_P:C201.2:IC14.AY13 
set_property PACKAGE_PIN AY13 [get_ports {clk_ff_P[9]}]
# pin name = CLK_FF1_0_2_N fullname = 10:CLK_FF1_0_2_N:C207.2:IC14.AV12 
set_property PACKAGE_PIN AV12 [get_ports {clk_ff_N[10]}]
# pin name = CLK_FF1_0_2_P fullname = 10:CLK_FF1_0_2_P:C205.2:IC14.AV13 
set_property PACKAGE_PIN AV13 [get_ports {clk_ff_P[10]}]
# pin name = CLK_FF1_1_0_N fullname = 10:CLK_FF1_1_0_N:C200.2:IC14.BA10 
set_property PACKAGE_PIN BA10 [get_ports {clk_ff_N[11]}]
# pin name = CLK_FF1_1_0_P fullname = 10:CLK_FF1_1_0_P:C198.2:IC14.BA11 
set_property PACKAGE_PIN BA11 [get_ports {clk_ff_P[11]}]
# pin name = CLK_FF1_1_1_N fullname = 10:CLK_FF1_1_1_N:C204.2:IC14.AW10 
set_property PACKAGE_PIN AW10 [get_ports {clk_ff_N[12]}]
# pin name = CLK_FF1_1_1_P fullname = 10:CLK_FF1_1_1_P:C202.2:IC14.AW11 
set_property PACKAGE_PIN AW11 [get_ports {clk_ff_P[12]}]
# pin name = CLK_FF1_1_2_N fullname = 10:CLK_FF1_1_2_N:C208.2:IC14.AU10 
set_property PACKAGE_PIN AU10 [get_ports {clk_ff_N[13]}]
# pin name = CLK_FF1_1_2_P fullname = 10:CLK_FF1_1_2_P:C206.2:IC14.AU11 
set_property PACKAGE_PIN AU11 [get_ports {clk_ff_P[13]}]
# pin name = CLK_FF8_1_0_N fullname = 10:CLK_FF8_1_0_N:C152.2:IC14.M40 
set_property PACKAGE_PIN M40 [get_ports {clk_ff_N[14]}]
# pin name = CLK_FF8_1_0_P fullname = 10:CLK_FF8_1_0_P:C150.2:IC14.M39 
set_property PACKAGE_PIN M39 [get_ports {clk_ff_P[14]}]
# pin name = CLK_FF2_0_0_N fullname = 10:CLK_FF2_0_0_N:C79.2:IC14.AT40 
set_property PACKAGE_PIN AT40 [get_ports {clk_ff_N[15]}]
# pin name = CLK_FF2_0_0_P fullname = 10:CLK_FF2_0_0_P:C77.2:IC14.AT39 
set_property PACKAGE_PIN AT39 [get_ports {clk_ff_P[15]}]
# pin name = CLK_FF2_0_1_N fullname = 10:CLK_FF2_0_1_N:C83.2:IC14.AP40 
set_property PACKAGE_PIN AP40 [get_ports {clk_ff_N[16]}]
# pin name = CLK_FF2_0_1_P fullname = 10:CLK_FF2_0_1_P:C81.2:IC14.AP39 
set_property PACKAGE_PIN AP39 [get_ports {clk_ff_P[16]}]
# pin name = CLK_FF2_0_2_N fullname = 10:CLK_FF2_0_2_N:C87.2:IC14.AM40 
set_property PACKAGE_PIN AM40 [get_ports {clk_ff_N[17]}]
# pin name = CLK_FF2_0_2_P fullname = 10:CLK_FF2_0_2_P:C85.2:IC14.AM39 
set_property PACKAGE_PIN AM39 [get_ports {clk_ff_P[17]}]
# pin name = CLK_FF2_1_0_N fullname = 10:CLK_FF2_1_0_N:C80.2:IC14.AR42 
set_property PACKAGE_PIN AR42 [get_ports {clk_ff_N[18]}]
# pin name = CLK_FF2_1_0_P fullname = 10:CLK_FF2_1_0_P:C78.2:IC14.AR41 
set_property PACKAGE_PIN AR41 [get_ports {clk_ff_P[18]}]
# pin name = CLK_FF2_1_1_N fullname = 10:CLK_FF2_1_1_N:C84.2:IC14.AN42 
set_property PACKAGE_PIN AN42 [get_ports {clk_ff_N[19]}]
# pin name = CLK_FF2_1_1_P fullname = 10:CLK_FF2_1_1_P:C82.2:IC14.AN41 
set_property PACKAGE_PIN AN41 [get_ports {clk_ff_P[19]}]
# pin name = CLK_FF2_1_2_N fullname = 10:CLK_FF2_1_2_N:C88.2:IC14.AL42 
set_property PACKAGE_PIN AL42 [get_ports {clk_ff_N[20]}]
# pin name = CLK_FF2_1_2_P fullname = 10:CLK_FF2_1_2_P:C86.2:IC14.AL41 
set_property PACKAGE_PIN AL41 [get_ports {clk_ff_P[20]}]
# pin name = CLK_FF3_0_0_N fullname = 10:CLK_FF3_0_0_N:C211.2:IC14.AT12 
set_property PACKAGE_PIN AT12 [get_ports {clk_ff_N[21]}]
# pin name = CLK_FF3_0_0_P fullname = 10:CLK_FF3_0_0_P:C209.2:IC14.AT13 
set_property PACKAGE_PIN AT13 [get_ports {clk_ff_P[21]}]
# pin name = CLK_FF3_0_1_N fullname = 10:CLK_FF3_0_1_N:C215.2:IC14.AP12 
set_property PACKAGE_PIN AP12 [get_ports {clk_ff_N[22]}]
# pin name = CLK_FF3_0_1_P fullname = 10:CLK_FF3_0_1_P:C213.2:IC14.AP13 
set_property PACKAGE_PIN AP13 [get_ports {clk_ff_P[22]}]
# pin name = CLK_FF3_0_2_N fullname = 10:CLK_FF3_0_2_N:C219.2:IC14.AM12 
set_property PACKAGE_PIN AM12 [get_ports {clk_ff_N[23]}]
# pin name = CLK_FF3_0_2_P fullname = 10:CLK_FF3_0_2_P:C217.2:IC14.AM13 
set_property PACKAGE_PIN AM13 [get_ports {clk_ff_P[23]}]
# pin name = CLK_FF3_1_0_N fullname = 10:CLK_FF3_1_0_N:C212.2:IC14.AR10 
set_property PACKAGE_PIN AR10 [get_ports {clk_ff_N[24]}]
# pin name = CLK_FF3_1_0_P fullname = 10:CLK_FF3_1_0_P:C210.2:IC14.AR11 
set_property PACKAGE_PIN AR11 [get_ports {clk_ff_P[24]}]
# pin name = CLK_FF3_1_1_N fullname = 10:CLK_FF3_1_1_N:C216.2:IC14.AN10 
set_property PACKAGE_PIN AN10 [get_ports {clk_ff_N[25]}]
# pin name = CLK_FF3_1_1_P fullname = 10:CLK_FF3_1_1_P:C214.2:IC14.AN11 
set_property PACKAGE_PIN AN11 [get_ports {clk_ff_P[25]}]
# pin name = CLK_FF3_1_2_N fullname = 10:CLK_FF3_1_2_N:C220.2:IC14.AL10 
set_property PACKAGE_PIN AL10 [get_ports {clk_ff_N[26]}]
# pin name = CLK_FF3_1_2_P fullname = 10:CLK_FF3_1_2_P:C218.2:IC14.AL11 
set_property PACKAGE_PIN AL11 [get_ports {clk_ff_P[26]}]
# pin name = CLK_FF4_0_0_N fullname = 10:CLK_FF4_0_0_N:C91.2:IC14.AJ42 
set_property PACKAGE_PIN AJ42 [get_ports {clk_ff_N[27]}]
# pin name = CLK_FF4_0_0_P fullname = 10:CLK_FF4_0_0_P:C89.2:IC14.AJ41 
set_property PACKAGE_PIN AJ41 [get_ports {clk_ff_P[27]}]
# pin name = CLK_FF4_0_1_N fullname = 10:CLK_FF4_0_1_N:C96.2:IC14.AE42 
set_property PACKAGE_PIN AE42 [get_ports {clk_ff_N[28]}]
# pin name = CLK_FF4_0_1_P fullname = 10:CLK_FF4_0_1_P:C93.2:IC14.AE41 
set_property PACKAGE_PIN AE41 [get_ports {clk_ff_P[28]}]
# pin name = CLK_FF4_0_2_N fullname = 10:CLK_FF4_0_2_N:C101.2:IC14.AA42 
set_property PACKAGE_PIN AA42 [get_ports {clk_ff_N[29]}]
# pin name = CLK_FF4_0_2_P fullname = 10:CLK_FF4_0_2_P:C99.2:IC14.AA41 
set_property PACKAGE_PIN AA41 [get_ports {clk_ff_P[29]}]
# pin name = CLK_FF4_1_0_N fullname = 10:CLK_FF4_1_0_N:C92.2:IC14.AG42 
set_property PACKAGE_PIN AG42 [get_ports {clk_ff_N[30]}]
# pin name = CLK_FF4_1_0_P fullname = 10:CLK_FF4_1_0_P:C90.2:IC14.AG41 
set_property PACKAGE_PIN AG41 [get_ports {clk_ff_P[30]}]
# pin name = CLK_FF4_1_1_N fullname = 10:CLK_FF4_1_1_N:C98.2:IC14.AC42 
set_property PACKAGE_PIN AC42 [get_ports {clk_ff_N[31]}]
# pin name = CLK_FF4_1_1_P fullname = 10:CLK_FF4_1_1_P:C94.2:IC14.AC41 
set_property PACKAGE_PIN AC41 [get_ports {clk_ff_P[31]}]
# pin name = CLK_FF4_1_2_N fullname = 10:CLK_FF4_1_2_N:C104.2:IC14.Y40 
set_property PACKAGE_PIN Y40 [get_ports {clk_ff_N[32]}]
# pin name = CLK_FF4_1_2_P fullname = 10:CLK_FF4_1_2_P:C100.2:IC14.Y39 
set_property PACKAGE_PIN Y39 [get_ports {clk_ff_P[32]}]
# pin name = CLK_FF5_0_0_N fullname = 10:CLK_FF5_0_0_N:C223.2:IC14.AJ10 
set_property PACKAGE_PIN AJ10 [get_ports {clk_ff_N[33]}]
# pin name = CLK_FF5_0_0_P fullname = 10:CLK_FF5_0_0_P:C221.2:IC14.AJ11 
set_property PACKAGE_PIN AJ11 [get_ports {clk_ff_P[33]}]
# pin name = CLK_FF5_0_1_N fullname = 10:CLK_FF5_0_1_N:C228.2:IC14.AE10 
set_property PACKAGE_PIN AE10 [get_ports {clk_ff_N[34]}]
# pin name = CLK_FF5_0_1_P fullname = 10:CLK_FF5_0_1_P:C225.2:IC14.AE11 
set_property PACKAGE_PIN AE11 [get_ports {clk_ff_P[34]}]
# pin name = CLK_FF5_0_2_N fullname = 10:CLK_FF5_0_2_N:C233.2:IC14.AA10 
set_property PACKAGE_PIN AA10 [get_ports {clk_ff_N[35]}]
# pin name = CLK_FF5_0_2_P fullname = 10:CLK_FF5_0_2_P:C231.2:IC14.AA11 
set_property PACKAGE_PIN AA11 [get_ports {clk_ff_P[35]}]
# pin name = CLK_FF5_1_0_N fullname = 10:CLK_FF5_1_0_N:C224.2:IC14.AG10 
set_property PACKAGE_PIN AG10 [get_ports {clk_ff_N[36]}]
# pin name = CLK_FF5_1_0_P fullname = 10:CLK_FF5_1_0_P:C222.2:IC14.AG11 
set_property PACKAGE_PIN AG11 [get_ports {clk_ff_P[36]}]
# pin name = CLK_FF5_1_1_N fullname = 10:CLK_FF5_1_1_N:C230.2:IC14.AC10 
set_property PACKAGE_PIN AC10 [get_ports {clk_ff_N[37]}]
# pin name = CLK_FF5_1_1_P fullname = 10:CLK_FF5_1_1_P:C226.2:IC14.AC11 
set_property PACKAGE_PIN AC11 [get_ports {clk_ff_P[37]}]
# pin name = CLK_FF5_1_2_N fullname = 10:CLK_FF5_1_2_N:C236.2:IC14.Y12 
set_property PACKAGE_PIN Y12 [get_ports {clk_ff_N[38]}]
# pin name = CLK_FF5_1_2_P fullname = 10:CLK_FF5_1_2_P:C232.2:IC14.Y13 
set_property PACKAGE_PIN Y13 [get_ports {clk_ff_P[38]}]
# pin name = CLK_FF6_0_0_N fullname = 10:CLK_FF6_0_0_N:C139.2:IC14.W42 
set_property PACKAGE_PIN W42 [get_ports {clk_ff_N[39]}]
# pin name = CLK_FF6_0_0_P fullname = 10:CLK_FF6_0_0_P:C137.2:IC14.W41 
set_property PACKAGE_PIN W41 [get_ports {clk_ff_P[39]}]
# pin name = CLK_FF6_0_1_N fullname = 10:CLK_FF6_0_1_N:C143.2:IC14.U42 
set_property PACKAGE_PIN U42 [get_ports {clk_ff_N[40]}]
# pin name = CLK_FF6_0_1_P fullname = 10:CLK_FF6_0_1_P:C141.2:IC14.U41 
set_property PACKAGE_PIN U41 [get_ports {clk_ff_P[40]}]
# pin name = CLK_FF6_0_2_N fullname = 10:CLK_FF6_0_2_N:C147.2:IC14.R42 
set_property PACKAGE_PIN R42 [get_ports {clk_ff_N[41]}]
# pin name = CLK_FF6_0_2_P fullname = 10:CLK_FF6_0_2_P:C145.2:IC14.R41 
set_property PACKAGE_PIN R41 [get_ports {clk_ff_P[41]}]
# pin name = CLK_FF6_1_0_N fullname = 10:CLK_FF6_1_0_N:C140.2:IC14.V40 
set_property PACKAGE_PIN V40 [get_ports {clk_ff_N[42]}]
# pin name = CLK_FF6_1_0_P fullname = 10:CLK_FF6_1_0_P:C138.2:IC14.V39 
set_property PACKAGE_PIN V39 [get_ports {clk_ff_P[42]}]
# pin name = CLK_FF6_1_1_N fullname = 10:CLK_FF6_1_1_N:C144.2:IC14.T40 
set_property PACKAGE_PIN T40 [get_ports {clk_ff_N[43]}]
# pin name = CLK_FF6_1_1_P fullname = 10:CLK_FF6_1_1_P:C142.2:IC14.T39 
set_property PACKAGE_PIN T39 [get_ports {clk_ff_P[43]}]
# pin name = CLK_FF6_1_2_N fullname = 10:CLK_FF6_1_2_N:C148.2:IC14.P40 
set_property PACKAGE_PIN P40 [get_ports {clk_ff_N[44]}]
# pin name = CLK_FF6_1_2_P fullname = 10:CLK_FF6_1_2_P:C146.2:IC14.P39 
set_property PACKAGE_PIN P39 [get_ports {clk_ff_P[44]}]
# pin name = CLK_FF7_0_0_N fullname = 10:CLK_FF7_0_0_N:C271.2:IC14.W10 
set_property PACKAGE_PIN W10 [get_ports {clk_ff_N[45]}]
# pin name = CLK_FF7_0_0_P fullname = 10:CLK_FF7_0_0_P:C269.2:IC14.W11 
set_property PACKAGE_PIN W11 [get_ports {clk_ff_P[45]}]
# pin name = CLK_FF7_0_1_N fullname = 10:CLK_FF7_0_1_N:C275.2:IC14.U10 
set_property PACKAGE_PIN U10 [get_ports {clk_ff_N[46]}]
# pin name = CLK_FF7_0_1_P fullname = 10:CLK_FF7_0_1_P:C273.2:IC14.U11 
set_property PACKAGE_PIN U11 [get_ports {clk_ff_P[46]}]
# pin name = CLK_FF7_0_2_N fullname = 10:CLK_FF7_0_2_N:C279.2:IC14.R10 
set_property PACKAGE_PIN R10 [get_ports {clk_ff_N[47]}]
# pin name = CLK_FF7_0_2_P fullname = 10:CLK_FF7_0_2_P:C277.2:IC14.R11 
set_property PACKAGE_PIN R11 [get_ports {clk_ff_P[47]}]
# pin name = CLK_FF7_1_0_N fullname = 10:CLK_FF7_1_0_N:C272.2:IC14.V12 
set_property PACKAGE_PIN V12 [get_ports {clk_ff_N[48]}]
# pin name = CLK_FF7_1_0_P fullname = 10:CLK_FF7_1_0_P:C270.2:IC14.V13 
set_property PACKAGE_PIN V13 [get_ports {clk_ff_P[48]}]
# pin name = CLK_FF7_1_1_N fullname = 10:CLK_FF7_1_1_N:C276.2:IC14.T12 
set_property PACKAGE_PIN T12 [get_ports {clk_ff_N[49]}]
# pin name = CLK_FF7_1_1_P fullname = 10:CLK_FF7_1_1_P:C274.2:IC14.T13 
set_property PACKAGE_PIN T13 [get_ports {clk_ff_P[49]}]
# pin name = CLK_FF7_1_2_N fullname = 10:CLK_FF7_1_2_N:C280.2:IC14.P12 
set_property PACKAGE_PIN P12 [get_ports {clk_ff_N[50]}]
# pin name = CLK_FF7_1_2_P fullname = 10:CLK_FF7_1_2_P:C278.2:IC14.P13 
set_property PACKAGE_PIN P13 [get_ports {clk_ff_P[50]}]
# pin name = CLK_FF8_0_0_N fullname = 10:CLK_FF8_0_0_N:C151.2:IC14.N42 
set_property PACKAGE_PIN N42 [get_ports {clk_ff_N[51]}]
# pin name = CLK_FF8_0_0_P fullname = 10:CLK_FF8_0_0_P:C149.2:IC14.N41 
set_property PACKAGE_PIN N41 [get_ports {clk_ff_P[51]}]
# pin name = CLK_FF8_0_1_N fullname = 10:CLK_FF8_0_1_N:C155.2:IC14.L42 
set_property PACKAGE_PIN L42 [get_ports {clk_ff_N[52]}]
# pin name = CLK_FF8_0_1_P fullname = 10:CLK_FF8_0_1_P:C153.2:IC14.L41 
set_property PACKAGE_PIN L41 [get_ports {clk_ff_P[52]}]
# pin name = CLK_FF8_0_2_N fullname = 10:CLK_FF8_0_2_N:C159.2:IC14.J42 
set_property PACKAGE_PIN J42 [get_ports {clk_ff_N[53]}]
# pin name = CLK_FF8_0_2_P fullname = 10:CLK_FF8_0_2_P:C157.2:IC14.J41 
set_property PACKAGE_PIN J41 [get_ports {clk_ff_P[53]}]
# pin name = CLK_FF8_1_1_N fullname = 10:CLK_FF8_1_1_N:C156.2:IC14.K40 
set_property PACKAGE_PIN K40 [get_ports {clk_ff_N[54]}]
# pin name = CLK_FF8_1_1_P fullname = 10:CLK_FF8_1_1_P:C154.2:IC14.K39 
set_property PACKAGE_PIN K39 [get_ports {clk_ff_P[54]}]
# pin name = CLK_FF8_1_2_N fullname = 10:CLK_FF8_1_2_N:C160.2:IC14.H40 
set_property PACKAGE_PIN H40 [get_ports {clk_ff_N[55]}]
# pin name = CLK_FF8_1_2_P fullname = 10:CLK_FF8_1_2_P:C158.2:IC14.H39 
set_property PACKAGE_PIN H39 [get_ports {clk_ff_P[55]}]
# pin name = CLK_FF9_0_0_N fullname = 10:CLK_FF9_0_0_N:C283.2:IC14.N10 
set_property PACKAGE_PIN N10 [get_ports {clk_ff_N[56]}]
# pin name = CLK_FF9_0_0_P fullname = 10:CLK_FF9_0_0_P:C281.2:IC14.N11 
set_property PACKAGE_PIN N11 [get_ports {clk_ff_P[56]}]
# pin name = CLK_FF9_0_1_N fullname = 10:CLK_FF9_0_1_N:C287.2:IC14.L10 
set_property PACKAGE_PIN L10 [get_ports {clk_ff_N[57]}]
# pin name = CLK_FF9_0_1_P fullname = 10:CLK_FF9_0_1_P:C285.2:IC14.L11 
set_property PACKAGE_PIN L11 [get_ports {clk_ff_P[57]}]
# pin name = CLK_FF9_0_2_N fullname = 10:CLK_FF9_0_2_N:C291.2:IC14.J10 
set_property PACKAGE_PIN J10 [get_ports {clk_ff_N[58]}]
# pin name = CLK_FF9_0_2_P fullname = 10:CLK_FF9_0_2_P:C289.2:IC14.J11 
set_property PACKAGE_PIN J11 [get_ports {clk_ff_P[58]}]
# pin name = CLK_FF9_1_0_N fullname = 10:CLK_FF9_1_0_N:C284.2:IC14.M12 
set_property PACKAGE_PIN M12 [get_ports {clk_ff_N[59]}]
# pin name = CLK_FF9_1_0_P fullname = 10:CLK_FF9_1_0_P:C282.2:IC14.M13 
set_property PACKAGE_PIN M13 [get_ports {clk_ff_P[59]}]
# pin name = CLK_FF9_1_1_N fullname = 10:CLK_FF9_1_1_N:C288.2:IC14.K12 
set_property PACKAGE_PIN K12 [get_ports {clk_ff_N[60]}]
# pin name = CLK_FF9_1_1_P fullname = 10:CLK_FF9_1_1_P:C286.2:IC14.K13 
set_property PACKAGE_PIN K13 [get_ports {clk_ff_P[60]}]
# pin name = CLK_FF9_1_2_N fullname = 10:CLK_FF9_1_2_N:C292.2:IC14.H12 
set_property PACKAGE_PIN H12 [get_ports {clk_ff_N[61]}]
# pin name = CLK_FF9_1_2_P fullname = 10:CLK_FF9_1_2_P:C290.2:IC14.H13 
set_property PACKAGE_PIN H13 [get_ports {clk_ff_P[61]}]
# pin name = CLK_SM0_N fullname = 10:CLK_SM0_N:C349.2:IC14.BD12 
#set_property PACKAGE_PIN BD12 [get_ports {CLK_SM0_N}]
# pin name = CLK_SM0_P fullname = 10:CLK_SM0_P:C347.2:IC14.BD13 
#set_property PACKAGE_PIN BD13 [get_ports {CLK_SM0_P}]
# pin name = CLK_SM1_N fullname = 10:CLK_SM1_N:C354.2:IC14.BC10 
#set_property PACKAGE_PIN BC10 [get_ports {CLK_SM1_N}]
# pin name = CLK_SM1_P fullname = 10:CLK_SM1_P:C352.2:IC14.BC11 
#set_property PACKAGE_PIN BC11 [get_ports {CLK_SM1_P}]

set_property PACKAGE_PIN BD12 [get_ports {clk_ff_N[62]}] 
set_property PACKAGE_PIN BD13 [get_ports {clk_ff_P[62]}] 
set_property PACKAGE_PIN BC10 [get_ports {clk_ff_N[63]}] 
set_property PACKAGE_PIN BC11 [get_ports {clk_ff_P[63]}] 

set_property IOSTANDARD LVDS [get_ports {clk_ff*}]
set_property DIFF_TERM_ADV TERM_100 [get_ports clk_ff*]

#set_property DIFF_TERM_ADV TERM_100 [get_ports CLK_TC_IN*]
#set_property IOSTANDARD LVDS [get_ports CLK_EXT_*]
#set_property DIFF_TERM_ADV TERM_100 [get_ports CLK_EXT_*]
create_clock -period 5.000 -name clk_200 [get_ports clk_200_p]
#create_clock -period 10.000 -name clk_ext_dbg [get_ports CLK_EXT_DBG_P]
#create_clock -period 7.700 -name clk_ext_clean [get_ports CLK_EXT_DBG_CLEAN_P]
create_clock -period 2.500 -name clk_ff0 [get_ports {clk_ff_P[0]}]
create_clock -period 2.500 -name clk_ff1 [get_ports {clk_ff_P[1]}]
create_clock -period 2.500 -name clk_ff2 [get_ports {clk_ff_P[2]}]
create_clock -period 2.500 -name clk_ff3 [get_ports {clk_ff_P[3]}]
create_clock -period 2.500 -name clk_ff4 [get_ports {clk_ff_P[4]}]
create_clock -period 2.500 -name clk_ff5 [get_ports {clk_ff_P[5]}]
create_clock -period 2.500 -name clk_ff6 [get_ports {clk_ff_P[6]}]
create_clock -period 2.500 -name clk_ff7 [get_ports {clk_ff_P[7]}]
create_clock -period 2.500 -name clk_ff8 [get_ports {clk_ff_P[8]}]
create_clock -period 2.500 -name clk_ff9 [get_ports {clk_ff_P[9]}]
create_clock -period 2.500 -name clk_ff10 [get_ports {clk_ff_P[10]}]
create_clock -period 2.500 -name clk_ff11 [get_ports {clk_ff_P[11]}]
create_clock -period 2.500 -name clk_ff12 [get_ports {clk_ff_P[12]}]
create_clock -period 2.500 -name clk_ff13 [get_ports {clk_ff_P[13]}]
create_clock -period 2.500 -name clk_ff14 [get_ports {clk_ff_P[14]}]
create_clock -period 2.500 -name clk_ff15 [get_ports {clk_ff_P[15]}]
create_clock -period 2.500 -name clk_ff16 [get_ports {clk_ff_P[16]}]
create_clock -period 2.500 -name clk_ff17 [get_ports {clk_ff_P[17]}]
create_clock -period 2.500 -name clk_ff18 [get_ports {clk_ff_P[18]}]
create_clock -period 2.500 -name clk_ff19 [get_ports {clk_ff_P[19]}]
create_clock -period 2.500 -name clk_ff20 [get_ports {clk_ff_P[20]}]
create_clock -period 2.500 -name clk_ff21 [get_ports {clk_ff_P[21]}]
create_clock -period 2.500 -name clk_ff22 [get_ports {clk_ff_P[22]}]
create_clock -period 2.500 -name clk_ff23 [get_ports {clk_ff_P[23]}]
create_clock -period 2.500 -name clk_ff24 [get_ports {clk_ff_P[24]}]
create_clock -period 2.500 -name clk_ff25 [get_ports {clk_ff_P[25]}]
create_clock -period 2.500 -name clk_ff26 [get_ports {clk_ff_P[26]}]
create_clock -period 2.500 -name clk_ff27 [get_ports {clk_ff_P[27]}]
create_clock -period 2.500 -name clk_ff28 [get_ports {clk_ff_P[28]}]
create_clock -period 2.500 -name clk_ff29 [get_ports {clk_ff_P[29]}]
create_clock -period 2.500 -name clk_ff30 [get_ports {clk_ff_P[30]}]
create_clock -period 2.500 -name clk_ff31 [get_ports {clk_ff_P[31]}]
create_clock -period 2.500 -name clk_ff32 [get_ports {clk_ff_P[32]}]
create_clock -period 2.500 -name clk_ff33 [get_ports {clk_ff_P[33]}]
create_clock -period 2.500 -name clk_ff34 [get_ports {clk_ff_P[34]}]
create_clock -period 2.500 -name clk_ff35 [get_ports {clk_ff_P[35]}]
create_clock -period 2.500 -name clk_ff36 [get_ports {clk_ff_P[36]}]
create_clock -period 2.500 -name clk_ff37 [get_ports {clk_ff_P[37]}]
create_clock -period 2.500 -name clk_ff38 [get_ports {clk_ff_P[38]}]
create_clock -period 2.500 -name clk_ff39 [get_ports {clk_ff_P[39]}]
create_clock -period 2.500 -name clk_ff40 [get_ports {clk_ff_P[40]}]
create_clock -period 2.500 -name clk_ff41 [get_ports {clk_ff_P[41]}]
create_clock -period 2.500 -name clk_ff42 [get_ports {clk_ff_P[42]}]
create_clock -period 2.500 -name clk_ff43 [get_ports {clk_ff_P[43]}]
create_clock -period 2.500 -name clk_ff44 [get_ports {clk_ff_P[44]}]
create_clock -period 2.500 -name clk_ff45 [get_ports {clk_ff_P[45]}]
create_clock -period 2.500 -name clk_ff46 [get_ports {clk_ff_P[46]}]
create_clock -period 2.500 -name clk_ff47 [get_ports {clk_ff_P[47]}]
create_clock -period 2.500 -name clk_ff48 [get_ports {clk_ff_P[48]}]
create_clock -period 2.500 -name clk_ff49 [get_ports {clk_ff_P[49]}]
create_clock -period 2.500 -name clk_ff50 [get_ports {clk_ff_P[50]}]
create_clock -period 2.500 -name clk_ff51 [get_ports {clk_ff_P[51]}]
create_clock -period 2.500 -name clk_ff52 [get_ports {clk_ff_P[52]}]
create_clock -period 2.500 -name clk_ff53 [get_ports {clk_ff_P[53]}]
create_clock -period 2.500 -name clk_ff54 [get_ports {clk_ff_P[54]}]
create_clock -period 2.500 -name clk_ff55 [get_ports {clk_ff_P[55]}]
create_clock -period 2.500 -name clk_ff56 [get_ports {clk_ff_P[56]}]
create_clock -period 2.500 -name clk_ff57 [get_ports {clk_ff_P[57]}]
create_clock -period 2.500 -name clk_ff58 [get_ports {clk_ff_P[58]}]
create_clock -period 2.500 -name clk_ff59 [get_ports {clk_ff_P[59]}]
create_clock -period 2.500 -name clk_ff60 [get_ports {clk_ff_P[60]}]
create_clock -period 2.500 -name clk_ff61 [get_ports {clk_ff_P[61]}]
create_clock -period 2.500 -name clk_ff62 [get_ports {clk_ff_P[62]}]
create_clock -period 2.500 -name clk_ff63 [get_ports {clk_ff_P[63]}]


set_clock_groups -asynchronous -group [get_clocks clk_200*] -group [get_clocks clk_ff*]

#set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ext_clean] 5.000
#set_max_delay -datapath_only -from [get_clocks clk_ext_clean] -to [get_clocks int_pdct_clk] 5.000

#set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ext_dbg] 5.000
#set_max_delay -datapath_only -from [get_clocks clk_ext_dbg] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff0] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff0] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff1] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff1] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff2] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff2] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff3] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff3] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff4] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff4] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff5] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff5] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff6] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff6] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff7] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff7] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff8] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff8] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff9] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff9] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff10] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff10] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff11] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff11] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff12] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff12] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff13] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff13] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff14] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff14] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff15] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff15] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff16] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff16] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff17] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff17] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff18] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff18] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff19] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff19] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff20] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff20] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff21] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff21] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff22] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff22] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff23] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff23] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff24] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff24] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff25] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff25] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff26] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff26] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff27] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff27] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff28] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff28] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff29] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff29] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff30] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff30] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff31] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff31] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff32] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff32] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff33] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff33] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff34] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff34] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff35] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff35] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff36] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff36] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff37] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff37] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff38] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff38] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff39] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff39] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff40] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff40] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff41] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff41] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff42] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff42] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff43] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff43] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff44] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff44] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff45] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff45] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff46] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff46] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff47] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff47] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff48] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff48] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff49] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff49] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff50] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff50] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff51] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff51] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff52] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff52] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff53] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff53] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff54] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff54] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff55] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff55] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff56] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff56] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff57] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff57] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff58] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff58] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff59] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff59] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff60] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff60] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff61] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff61] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff62] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff62] -to [get_clocks int_pdct_clk] 5.000

# set_max_delay -datapath_only -from [get_clocks int_pdct_clk] -to [get_clocks clk_ff63] 5.000
# set_max_delay -datapath_only -from [get_clocks clk_ff63] -to [get_clocks int_pdct_clk] 5.000


############### UART pins ################################################
#set_property PACKAGE_PIN K28 [get_ports pdct_uart_rx]
#set_property PACKAGE_PIN K27 [get_ports pdct_uart_tx]

#set_property IOSTANDARD LVCMOS18 [get_ports pdct_uart*]





set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]



set_property PACKAGE_PIN BF13 [get_ports {p_mgt_k2z[2]}]
set_property PACKAGE_PIN BF12 [get_ports {n_mgt_k2z[2]}]
set_property PACKAGE_PIN  BH12  [get_ports  {n_mgt_z2k[2]} ]
set_property PACKAGE_PIN  BH13  [get_ports  {p_mgt_z2k[2]} ]

set_property PACKAGE_PIN  BF17  [get_ports  {n_mgt_k2z[1]} ]
set_property PACKAGE_PIN  BF18 [get_ports  {p_mgt_k2z[1]} ]
set_property PACKAGE_PIN BG20 [get_ports {p_mgt_z2k[1]}]
set_property PACKAGE_PIN BG19 [get_ports {n_mgt_z2k[1]}]













