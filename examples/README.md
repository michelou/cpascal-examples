# <span id="top">Component Pascal Examples</span> <span style="font-size:90%;">[⬆](../README.md)</span>

<table style="font-family:Helvetica,Arial;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;">
    <a href="https://en.wikipedia.org/wiki/Component_Pascal" rel="external"><img style="border:0;width:120px;" src="../docs/images/component-pascal.png" alt="CP project" /></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    Directory <strong><code>examples\</code></strong> contains <a href="https://en.wikipedia.org/wiki/Component_Pascal" rel="external">Component Pascal</a> code examples coming from various websites - mostly from the <a href="https://en.wikipedia.org/wiki/Component_Pascal" rel="external" title="https://en.wikipedia.org/wiki/Component_Pascal">Component Pascal project</a>.
  </td>
  </tr>
</table>

## <span id="hello">`Hello` Example</span>

This project has the following directory structure :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree" rel="external" title="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree"">tree</a> /a /f . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr" rel="external" title="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /v /b [A-Z]</b>
|   <a href="./Hello/build.bat">build.bat</a>
\---<b>src</b>
    \---<b>main</b>
        \---<b>cp</b>
                <a href="./Hello/src/main/cp/Hello.cp">Hello.cp</a>
</pre>

The target is specified using the two build options `-net` (default) and `-jvm` :

<pre style="font-size:80%;">
<b>&gt; <a href="./Hello/build.bat">build</a> -verbose clean run</b>
Compile 1 Component Pascal source file to directory "H:\examples\Hello\target" (DotNet)
Execute main program "Hello.exe"
Hello CP World
&nbsp;
<b>&gt; <a href="./Hello/build.bat">build</a> -verbose -jvm clean run</b>
Delete directory "target"
Compile 1 Component Pascal source file to directory "H:\examples\Hello\target\classes"
Execute main program "CP.Hello.Hello"
Hello CP World
</pre>

<!--=======================================================================-->

## <span id="helloworld">`HelloWorld` Example</span> [**&#x25B4;**](#top)

This project has the following directory structure :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree">tree</a> /a /f . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /v /b [A-Z]</b>
|   <a href="./HelloWorld/build.bat">build.bat</a>
\---<b>src</b>
    \---<b>main</b>
        \---<b>cp</b>
                <a href="./HelloWorld/src/main/cp/HelloWorld.cp">HelloWorld.cp</a>
</pre>

Command [`sh`][sh][`build.sh`](./HelloWorld/build.sh)`-verbose clean run` generates and executes the CP program `target\Helloworld.exe` :

<pre style="font-size:80%;">
<b>&gt; <a href="https://man7.org/linux/man-pages/man1/sh.1p.html" rel="external" title="https://man7.org/linux/man-pages/man1/sh.1p.html">sh</a> <a href="./HelloWorld/build.sh">build.sh</a> -verbose clean run</b>
Delete directory "target"
Compile 1 Component Pascal source file to directory "target"
#gpcp: NET is default target for this build
#gpcp: Created HelloWorld.exe
Copy runtime library to directory "target"
Execute main program "target/HelloWorld.exe"
Hello gpcp world
</pre>

We use option `-jvm` to generate and execute the Java program `target\classes\CP\HelloWord\HelloWorld.class` :

<pre style="font-size:80%;">
<b>&gt; <a href="https://man7.org/linux/man-pages/man1/sh.1p.html" rel="external" title="https://man7.org/linux/man-pages/man1/sh.1p.html">sh</a> <a href="./HelloWorld/build.sh">build.sh</a> -verbose -jvm clean run</b>
Delete directory "target"
Compile 1 Componet Pascal source file to directory "target/classes"
Execute main program "CP.HelloWorld.HelloWorld"
Hello gpcp world
&nbsp;
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree" rel="external" title="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree">tree</a> /a /f target | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr" rel="externl" title="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /v "^[A-Z]"</b>
\---classes
    |   HelloWorld.cps
    \---CP
        \---HelloWorld
                HelloWorld.class
</pre>

<!--=======================================================================-->

## <span id="jvmparams">`JvmParams` Example</span> [**&#x25B4;**](#top)

This project has the following directory structure :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree">tree</a> /a /f . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /v /b [A-Z]</b>
|   <a href="./JvmParams/build.bat">build.bat</a>
\---<b>src</b>
    \---<b>main</b>
        \---<b>cp</b>
                <a href="./JvmParams/src/main/cp/JvmParams.cp">JvmParams.cp</a>
</pre>

<!--=======================================================================-->

## <span id="typenames">`TypeNames` Example</span>

This project has the following directory structure :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree">tree</a> /a /f . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /v /b [A-Z]</b>
|   <a href="./TypeNames/build.bat">build.bat</a>
\---<b>src</b>
    \---<b>main</b>
        \---<b>cp</b>
                <a href="./TypeNames/src/main/cp/TypeNames.cp">TypeNames.cp</a>
</pre>

Command [**`build -jvm clean run`**](./TypeNames//build.bat) (targeting JVM) produces the following output for project [**`TypeNames`**](./TypeNames/):

<pre style="font-size:80%;">
<b>&gt; <a href="./TypeNames/build.bat">build</a> -verbose -jvm clean run</b>
Delete directory "target"
Compile 1 Component Pascal source file to directory "H:\examples\TypeNames\target\classes"
Execute main program "CP.TypeNames.TypeNames"
Implementation type for ARRAY 4,5 OF CHAR
char[][]

Implementation type of string in Object variable
String

Implementation type of NativeType in Object variable
Class

Implementation type of Object in Object variable
Class

Implementation type for INTEGER
int

Implementation type for ARRAY 16 OF CHAR
char[]

Implementation type for RecF = RECORD ... END
TypeNames_RecF

Implementation type for b field of RecF (SHORTREAL)
float
</pre>

<!--=======================================================================-->

## <span id="vectors">`Vectors` Example</span> [**&#x25B4;**](#top)

This project has the following directory structure :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree">tree</a> /a /f . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /v /b [A-Z]</b>
|   <a href="./Vectors/build.bat">build.bat</a>
\---<b>src</b>
    \---<b>main</b>
        \---<b>cp</b>
                <a href="./Vectors/src/main/cp/Vectors.cp">Vectors.cp</a>
</pre>

Command [**`build clean run`**](./Vectors/build.bat) produces the following output for project [**`Vectors`**](./Vectors/):

<pre style="font-size:80%;">
<b>&gt; <a href="./Vectors/build.bat">build</a> -verbose clean run</b>
Compile 1 Component Pascal source file to directory "H:\examples\Vectors\target" (DotNet)
Execute main program "Vectors.exe"
Integer Vector
 0 1 3 Original vector
 0 1 3 Entire assign copy
 0 1 3 Elem-by-elem copy
Mutated element 1 of original vector
 0 42 3 Original vector
 0 42 3 Entire assign copy
 0 1 3 Elem-by-elem copy

Character Vector
013 Original vector
013 Entire assign copy
013 Elem-by-elem copy
Mutated element [1] of original vector
0X3 Original vector
0X3 Entire assign copy
013 Elem-by-elem copy

Value Record Vector
{0,1} {2,3} {4,5}  Original vector
{0,1} {2,3} {4,5}  Entire assign copy
{0,1} {2,3} {4,5}  Elem-by-elem copy
Mutate elements of copies
{0,1} {77,3} {4,5}  Original vector
{0,1} {77,3} {4,5}  Entire assign copy
{0,1} {2,3} {4,99}  Elem-by-elem copy

Reference Record Vector
{0,1} {2,3} {4,5}  Original vector
{0,1} {2,3} {4,5}  Entire assign copy
{0,1} {2,3} {4,5}  Elem-by-elem copy
Mutate elements of copies
{0,1} {77,3} {4,99}  Original vector
{0,1} {77,3} {4,99}  Entire assign copy
{0,1} {77,3} {4,99}  Elem-by-elem copy
</pre>

The output directory `target\` looks as follows :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree" rel="external" title="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree">tree</a> /a /f target | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr" rel="external">findstr</a> /v /b [A-Z]</b>
        RTS.dll
        Vectors.cps
        Vectors.exe
        Vectors.il
        Vectors.pdb
</pre>

<!--
## <span id="footnotes">Footnotes</span> <sup><sub>[**&#9650;**](#top)</sub></sup>

<span id="footnote_01">[1]</span> ***Batch files and coding conventions*** [↩](#anchor_01)

<dl><dd>

</dd></dl>
-->

***

*[mics](https://lampwww.epfl.ch/~michelou/)/July 2026* [**&#9650;**](#top)  <!-- May 2024 -->
<span id="bottom">&nbsp;</span>

<!-- link refs -->
[sh]: https://man7.org/linux/man-pages/man1/sh.1p.html "https://man7.org/linux/man-pages/man1/sh.1p.html"
