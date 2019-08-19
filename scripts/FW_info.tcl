proc build_fw_version {path } {
    ## Set output filename
    set outFile $path/fw_version.vhd
    set outFile_fd [open $outFile "w"]

    ## Get timestamp
    set unixtime [clock seconds]
    set cent  [string map {" " "0"} [clock format $unixtime -format {%C}]]
    set year  [string map {" " "0"} [clock format $unixtime -format {%y}]]
    set month [string map {" " "0"} [clock format $unixtime -format {%m}]]
    set day   [string map {" " "0"} [clock format $unixtime -format {%d}]]
    set hour  [string map {" " "0"} [clock format $unixtime -format {%k}]]
    set min   [string map {" " "0"} [clock format $unixtime -format {%M}]]
    set sec   [string map {" " "0"} [clock format $unixtime -format {%S}]]

    ## Get git hash
    set hash_valid 0
    set hash_word_1 "FFFFFFFF"
    set hash_word_2 "FFFFFFFF"
    set hash_word_3 "FFFFFFFF"
    set hash_word_4 "FFFFFFFF"
    set hash_word_5 "FFFFFFFF"
    set git_hash_string [exec git rev-parse HEAD]
    if {[string length ${git_hash_string}] == 40 } {
	#valid hash
	set hash_valid 1
	set hash_word_5 [string range ${git_hash_string}  0  7]
	set hash_word_4 [string range ${git_hash_string}  8 15]
	set hash_word_3 [string range ${git_hash_string} 16 23]
	set hash_word_2 [string range ${git_hash_string} 24 31]
	set hash_word_1 [string range ${git_hash_string} 32 39]
    }

    
    ## write vhdl file
    puts $outFile_fd "library ieee;"
    puts $outFile_fd "use ieee.std_logic_1164.all;"    
    puts $outFile_fd "-- timestamp package"
    puts $outFile_fd "package FW_TIMESTAMP is"
    puts $outFile_fd "  constant TS_CENT     : std_logic_vector(7 downto 0) := x\"${cent}\";"
    puts $outFile_fd "  constant TS_YEAR     : std_logic_vector(7 downto 0) := x\"${year}\";"
    puts $outFile_fd "  constant TS_MONTH    : std_logic_vector(7 downto 0) := x\"${month}\";"
    puts $outFile_fd "  constant TS_DAY      : std_logic_vector(7 downto 0) := x\"${day}\";"
    puts $outFile_fd "  constant TS_HOUR     : std_logic_vector(7 downto 0) := x\"${hour}\";"
    puts $outFile_fd "  constant TS_MIN      : std_logic_vector(7 downto 0) := x\"${min}\";"
    puts $outFile_fd "  constant TS_SEC      : std_logic_vector(7 downto 0) := x\"${sec}\";"
    puts $outFile_fd "end package FW_TIMESTAMP;"
    puts $outFile_fd " "
    puts $outFile_fd " "    
    puts $outFile_fd "library ieee;"
    puts $outFile_fd "use ieee.std_logic_1164.all;"
    puts $outFile_fd "-- fw version package"
    puts $outFile_fd "package FW_VERSION is"
    puts $outFile_fd "  constant FW_HASH_VALID : std_logic                      := \'${hash_valid}\';"
    puts $outFile_fd "  constant FW_HASH_1     : std_logic_vector(31 downto  0) := x\"${hash_word_1}\";"
    puts $outFile_fd "  constant FW_HASH_2     : std_logic_vector(31 downto  0) := x\"${hash_word_2}\";"
    puts $outFile_fd "  constant FW_HASH_3     : std_logic_vector(31 downto  0) := x\"${hash_word_3}\";"
    puts $outFile_fd "  constant FW_HASH_4     : std_logic_vector(31 downto  0) := x\"${hash_word_4}\";"
    puts $outFile_fd "  constant FW_HASH_5     : std_logic_vector(31 downto  0) := x\"${hash_word_5}\";"
    puts $outFile_fd "end package FW_VERSION;"

    ## Print out info to user
    puts "Recording build @ ${cent}${year}-${month}-${day} ${hour}:${min}:${sec} "
    puts "Hash (${hash_valid}): 0x${hash_word_5}${hash_word_4}${hash_word_3}${hash_word_2}${hash_word_1}"
    puts "Written to ${outFile}"
    
    close $outFile_fd
};
