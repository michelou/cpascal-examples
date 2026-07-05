# <span id="top">Rosetta Code Examples</span> <span style="font-size:90%;">[⬆](../README.md)</span>

<table style="font-family:Helvetica,Arial;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;">
    <a href="https://en.wikipedia.org/wiki/Component_Pascal" rel="external"><img style="border:0;width:120px;" src="../docs/images/component-pascal.png" alt="CP project" /></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    Directory <strong><code>rosetta-examples\</code></strong> contains <a href="https://en.wikipedia.org/wiki/Component_Pascal" rel="external">Component Pascal</a> code examples coming from the <a href="https://rosettacode.org/wiki/Rosetta_Code" rel="external">Rosetta Code</a> website.
  </td>
  </tr>
</table>

## <span id="AryLen">`AryLen` Example</span>

Example [`AryLen`](./AryLen/) is based on Rosetta's code [`AryLen`][rosetta_arylen] which computes the number of elements in an array. The project has the following directory structure :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree">tree</a> /a /f . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /v /b [A-Z]</b>
|   <a href="./AryLen/build.bat">build.bat</a>
\---<b>src</b>
    \---<b>main</b>
        \---<b>cp</b>
                <a href="./AryLen/src/main/cp/AryLen.cp">AryLen.cp</a>
</pre>

Command [**`build clean run`**](./AryLen/build.bat) produces the following output for project [**`AryLen`**](./AryLen/):

<pre style="font-size:80%;">
<b>&gt; <a href="./AryLen/build.bat">build</a> -verbose clean run</b>
Delete directory "target"
Compile 1 Component Pascal source file to directory "H:\rosetta-examples\AryLen\target" (DotNet)
Execute main program "AryLen.exe"
Length:> 3
</pre>

The output directory `target\` looks as follows :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree">tree</a> /a /f target | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /v /b [A-Z]</b>
    AryLen.cps
    AryLen.exe
    AryLen.il
    AryLen.pdb
    RTS.dll
</pre>

<!--========================================================-->

## <span id="DrivePoint">`DrivePoint` Example</span>

Example [`DrivePoint`](./DrivePoint/) is based on Rosetta's code [`DrivePoint`][rosetta_drive_point] which defines a class. The project has the following directory structure :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree" rel="external">tree</a> /a /f . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr" rel="external">findstr</a> /v /b [A-Z]</b>
|   <a href="./DrivePoint/build.bat">build.bat</a>
\---<b>src</b>
    \---<b>main</b>
        \---<b>cp</b>
                <a href="./DrivePoint/src/main/cp/DrivePoint.cp">DrivePoint.cp</a>
                <a href="./DrivePoint/src/main/cp/Point.cp">Point.cp</a>
</pre>

Command [**`build clean run`**](./DrivePoint/build.bat) produces the following output for project [**`DrivePoint`**](./DrivePoint/):

<pre style="font-size:80%;">

</pre>

The output directory `target\` looks as follows :

<pre style="font-size:80%;">
</pre>

<!--=================================================================================-->

## <span id="footnotes">Footnotes</span> [**&#x25B4;**](#top)

<span id="footnote_01">[1]</span> ***Garden Point Component Pascal for JVM*** [↩](#anchor_01)

<dl><dd>
<pre style="font-size:80%;">
<b>&gt; C:\opt\gpcp-JVM-1.4.08\bin\j2cps.bat" -help</b>
j2cps version 1.4.07 (March 2018)
Usage:
java [VM-opts] j2cps.j2cps [options] PackageNameOrJarFile
java [VM-opts] -jar j2cps.jar [options] PackageNameOrJarFile
J2cps options may be in any order.
  -d[st] dir => symbol file destination directory
  -p[kg] dir => package-root directory
  -jar       => process the named jar file
  -s[ummary] => summary of progress
  -v[erbose] => verbose diagnostic messages
  -version   => show version string
  -nocpsym   => only use sym-files from destination,
                (overrides any CPSYM path setting)
No package-name or jar filename given, terminating
</pre>
</dd></dl>

<!--=======================================================================-->

<span id="footnote_02">[2]</span> ***Implementing the `Strings` library in Java*** [↩](#anchor_02)

<dl><dd>
The <code>Strings</code> library appears as a dependency in the above <code>DrivePoint</code> example but <code>String</code>` is not present in our GPCP environment. We choose to implement the static method <b>IntToString</b> in Java (similar to method <code>WriteString</code> in <code>Console</code>) :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/type">type</a> sources\libs\java\CP\Strings\Strings.java</b>
package CP.Strings;
&nbsp;
public class Strings {
  public static String IntToString(int i) {
    return String.valueOf(i);
  }
}
</pre>

The following steps aim to provide us both the Java class file `Strings.class` and the GPCP symbol file `Strings.cps` (needed for compilation of example <code>DrivePoint</code>) :

<pre style="font-size:80%;">
<b>&gt; %JAVA_HOME%\bin\<a href="https://docs.oracle.com/en/java/javase/17/docs/specs/man/javac.html" rel="external">javac</a> -d libs sources\libs\java\CP\Strings\Strings.java</b>
&nbsp;
<b>&gt; %JAVA_HOME%\bin\<a href="https://docs.oracle.com/en/java/javase/17/docs/specs/man/jar.html" rel="external">jar</a> cf Strings.jar -C libs .</b>
&nbsp;
<b>&gt; %JAVA_HOME%\bin\<a href="https://docs.oracle.com/en/java/javase/17/docs/specs/man/jar.html" rel="external">jar</a> tf Strings.jar</b>
META-INF/
META-INF/MANIFEST.MF
CP/
CP/Strings/
CP/Strings/Strings.class
&nbsp;
<b>&gt; %JROOT%\bin\j2cps -v -d symfiles -p libs\CP Strings</b>
J2cps args> -v -d symfiles -p libs\CP Strings
Current directory "." is <G:\rosetta-examples\Strings_LOCAL>
Using <.\libs\CP> as package-root directory
Using <.\symfiles> as symbol destination directory
Using "java.class.path" path "C:\opt\gpcp-JVM-1.4.08\jars\J2cps.jar"
Using "CPSYM" path ".;C:\opt\gpcp-JVM-1.4.08\symfiles;C:\opt\gpcp-JVM-1.4.08\symfiles\JvmSystem"
INFO: opened package directory <Strings> from package-root <.\libs\CP>
Reading Pkg Class File <Strings.Strings>
CP/Strings/Strings IS NOT PART OF PACKAGE Strings  qualName = Strings/Strings
INFO: locating dependencies of package <Strings>
INFO: Creating symbolfile <Strings.cps> in directory <.\symfiles>
</pre>

We first disassemble the predefined Java class file `Console.class` and observe that the  class name is `CP.Console.Console` :

<pre style="font-size:80%;">
<b>&gt; %JAVA_HOME%\bin\<a href="https://docs.oracle.com/en/java/javase/17/docs/specs/man/javap.html">javap</a> -cp %JROOT%\libs\CP\Console Console</b>
Warning: File C:\opt\gpcp-JVM-1.4.08\libs\CP\Console\Console.class does not contain class Console
Compiled from "Console.java"
public class CP.Console.Console {
  public CP.Console.Console();
  public static void WriteLn();
  public static void Write(char);
  public static void WriteInt(int, int);
  public static void WriteHex(int, int);
  public static void WriteString(char[]);
}
</pre>

Then we disassemble the generated class file `Strings.class` and observe that the class name `CP.Strings.Strings` looks similar to the one of `Console` :

<pre style="font-size:80%;">
<b>&gt; %JAVA_HOME%\bin\<a href="https://docs.oracle.com/en/java/javase/17/docs/specs/man/javap.html">javap</a> -cp libs\CP\Strings Strings</b>
Warning: File libs\CP\Strings\Strings.class does not contain class Strings
Compiled from "Strings.java"
public class CP.Strings.Strings {
  public CP.Strings.Strings();
  public static java.lang.String IntToString(int);
}
</pre>
</dd></dl>

<!--========================================================================0-->

<span id="footnote_03">[3]</span> ***Adding the `Strings` library to example `DrivePoint`*** [↩](#anchor_03)

<dl><dd>
<pre style="font-size:80%;">
<b>&gt; %JAVA_HOME%\bin\<a href="https://docs.oracle.com/en/java/javase/17/docs/specs/man/javap.html" rel="external">javap</a> -cp target\classes CP.Point.Point CP.Point.Point_Instance</b>
Compiled from "..\..\src\main\cp\Point.cp"
public final class CP.Point.Point {
  public CP.Point.Point();
  public static {};
  public static CP.Point.Point_Instance New(long, long);
}
Compiled from "..\..\src\main\cp\Point.cp"
public class CP.Point.Point_Instance {
  public long x;
  public long y;
  public CP.Point.Point_Instance();
  public void __copy__(CP.Point.Point_Instance);
  public final void Initialize(long, long);
  public final CP.Point.Point_Instance Add(CP.Point.Point_Instance);
  public final char[] ToString();
}
</pre>
</dd></dl>

<!--========================================================================0-->


***

*[mics](https://lampwww.epfl.ch/~michelou/)/July 2026* [**&#9650;**](#top)  <!-- May 2024 -->
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[rosetta_arylen]: https://rosettacode.org/wiki/Array_length#Component_Pascal
[rosetta_drive_point]: https://rosettacode.org/wiki/Classes#Component_Pascal
