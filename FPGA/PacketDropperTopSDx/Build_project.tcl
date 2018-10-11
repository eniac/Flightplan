set DIR [lindex $argv 0]
setws $DIR/PacketDropperTopSDx
createhw -name HW -hwspec $DIR/../PacketDropperTopVivado/PacketDropperTopVivado/PacketDropperTopVivado.sdk/design_1_wrapper.hdf
createbsp -name BSP -hwproject HW -proc psu_cortexa53_0 -arch 64
createapp -name SW -app {Empty Application} -proc psu_cortexa53_0 -hwproject HW -bsp BSP -lang c -arch 64
importsources -name SW -path $DIR/Sources
projects -build

