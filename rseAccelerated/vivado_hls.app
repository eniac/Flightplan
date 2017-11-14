<project xmlns="com.autoesl.autopilot.project" name="rseAccelerated" top="Matrix_multiply_HW">
    <files>
        <file name="../rsetest.c" sc="0" tb="1" cflags=" "/>
        <file name="../rseAcceleratedTest.h" sc="0" tb="1" cflags=" "/>
        <file name="../rseAcceleratedTest.c" sc="0" tb="1" cflags=" "/>
        <file name="../rse.c" sc="0" tb="1" cflags=" "/>
        <file name="rseAccelerated/rseAccelerated.c" sc="0" tb="false" cflags="-std=c99"/>
        <file name="rseAccelerated/rse.h" sc="0" tb="false" cflags=""/>
    </files>
    <includePaths/>
    <libraryPaths/>
    <Simulation>
        <SimFlow name="csim" clean="true" csimMode="0" lastCsimMode="0" compiler="true"/>
    </Simulation>
    <solutions xmlns="">
        <solution name="solution1" status="active"/>
    </solutions>
</project>

