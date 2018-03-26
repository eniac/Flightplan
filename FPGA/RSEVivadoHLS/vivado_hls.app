<project xmlns="com.autoesl.autopilot.project" name="RSEVivadoHLS" top="RSE_core">
    <files>
        <file name="RSEVivadoHLS/Configuration.h" sc="0" tb="false" cflags=""/>
        <file name="RSEVivadoHLS/Encoder.c" sc="0" tb="false" cflags="-std=c99"/>
        <file name="RSEVivadoHLS/Encoder.h" sc="0" tb="false" cflags=""/>
        <file name="RSEVivadoHLS/RSECore.c" sc="0" tb="false" cflags="-std=c99"/>
        <file name="../RSECode/rse.h" sc="0" tb="false" cflags=""/>
        <file name="../RSE_core_test.c" sc="0" tb="1" cflags="-I../../../../../RSECode -I../../../../RSEConfig"/>
        <file name="../RSE_core_test.h" sc="0" tb="1" cflags=" "/>
        <file name="../../../RSECode/rse.c" sc="0" tb="1" cflags="-DVERIFY_HLS -I../../../"/>
        <file name="../rsetest.c" sc="0" tb="1" cflags=" "/>
    </files>
    <includePaths/>
    <libraryPaths/>
    <Simulation argv="">
        <SimFlow name="csim" ldflags="" mflags="" csimMode="2" lastCsimMode="0" compiler="true"/>
    </Simulation>
    <solutions xmlns="">
        <solution name="solution1" status="active"/>
    </solutions>
</project>

