set DIR [lindex $argv 0]
set PROJECT [lindex $argv 1]
set SOURCE_DIR [lindex $argv 2]
setws $DIR/$PROJECT
createhw -name HW -hwspec $DIR/../TopLevelVivado/$PROJECT/$PROJECT.sdk/design_1_wrapper.hdf
createbsp -name BSP -hwproject HW -proc psu_cortexa53_0 -arch 64
createapp -name SW -app {Empty Application} -proc psu_cortexa53_0 -hwproject HW -bsp BSP -lang c -arch 64
importsources -name SW -path $DIR/Sources/$SOURCE_DIR
projects -build

