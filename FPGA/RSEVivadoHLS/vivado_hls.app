<project xmlns="com.autoesl.autopilot.project" name="RSEVivadoHLS" top="RSE_core">
    <files>
        <file name="RSEVivadoHLS/rse.h" sc="0" tb="false" cflags=""/>
        <file name="RSEVivadoHLS/RSECore.c" sc="0" tb="false" cflags="-std=c99"/>
        <file name="RSEVivadoHLS/Encoder.c" sc="0" tb="false" cflags="-std=c99"/>
        <file name="../RSE_core_test.c" sc="0" tb="1" cflags=""/>
        <file name="../RSE_core_test.h" sc="0" tb="1" cflags=""/>
        <file name="../rse.c" sc="0" tb="1" cflags=""/>
        <file name="../rsetest.c" sc="0" tb="1" cflags=""/>
    </files>
    <includePaths/>
    <libraryPaths/>
    <Simulation>
        <SimFlow name="csim" csimMode="0" lastCsimMode="0" compiler="true"/>
    </Simulation>
    <solutions xmlns="">
        <solution name="solution1" status="active"/>
    </solutions>
</project>

