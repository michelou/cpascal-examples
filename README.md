# <span id="top">Playing with Component Pascal on Windows</span>

<table style="font-family:Helvetica,Arial;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:25%;"><a href="https://en.wikipedia.org/wiki/Component_Pascal" rel="external" title="https://en.wikipedia.org/wiki/Component_Pascal"><img src="./docs/images/component-pascal.png" width="100" alt="Component Pascal project"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This repository gathers <a href="https://en.wikipedia.org/wiki/Component_Pascal" rel="external">Component Pascal</a> code examples coming from various websites and books.<br/>
  It also includes several build scripts (<a href="https://en.wikibooks.org/wiki/Windows_Batch_Scripting" rel="external">batch files</a>, <a href="https://docs.gradle.org/current/userguide/writing_build_scripts.html" rel="external">Gradle scripts</a>) for experimenting with <a href="https://en.wikipedia.org/wiki/Component_Pascal" rel="external" title="https://en.wikipedia.org/wiki/Component_Pascal">Component Pascal</a> on a Windows machine.
  </td>
  </tr>
</table>

[Ada][ada_examples], [Akka][akka_examples], [C++][cpp_examples], [COBOL][cobol_examples], [Common&nbsp;Lisp][cl_examples], [Dafny][dafny_examples], [Dart][dart_examples], [Deno][deno_examples], [Erlang][erlang_examples], [Flix][flix_examples], [Golang][golang_examples], [GraalVM][graalvm_examples], [Haskell][haskell_examples], [Kafka][kafka_examples], [Kotlin][kotlin_examples], [LLVM][llvm_examples], [Modula-2][m2_examples], [MySQL][mysql_examples], [Node.js][nodejs_examples], [PowerShell][powershell_examples], [Rust][rust_examples], [Scala&nbsp;3][scala3_examples], [Spark][spark_examples], [Spring][spring_examples], [Standard&nbsp;ML][sml_examples], [TruffleSqueak][trufflesqueak_examples], [WiX&nbsp;Toolset][wix_examples] and [Zig][zig_examples] are other topics we are continuously monitoring.

## <span id="proj_deps">Project dependencies</span>

This project depends on the following external software for the **Microsoft Windows** platform:

- [Gardens Point Component Pascal for Java 1.4][gpcp_java_downloads] <sup id="anchor_01">[1](#footnote_01)</sup>
- [Gardens Point Component Pascal for .NET 1.4][gpcp_downloads]
- [Git 2.55][git_downloads] ([*release notes*][git_relnotes])
- [Temurin OpenJDK 17 LTS][temurin_openjdk17] ([*release notes*][temurin_openjdk17_relnotes], [*bug fixes*][temurin_openjdk17_bugfixes])
<!--
- [OpenJDK8U JRE 8u272][jre_8u272] <sup id="anchor_02">[2](#footnote_02)</sup> ([*release notes*][jre_8u272_relnotes])
-->

Optionally one may also install the following software:

- [ConEmu 2023][conemu_downloads] ([*release notes*][conemu_relnotes])
- [Visual Studio Code 1.127][vscode_downloads] ([*release notes*][vscode_relnotes])

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive][zip_archive] rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [**`/opt/`**][linux_opt] directory on Unix).

For instance our development environment looks as follows (*July 2026*) <sup id="anchor_02">[2](#footnote_02)</sup>:

<pre style="font-size:80%;">
C:\opt\ConEmu\                  <i>( 26 MB)</i>
C:\opt\Git\                     <i>(388 MB)</i>
C:\opt\gpcp-JVM-1.4.08\         <i>( 54 MB)</i>
C:\opt\gpcp-NET-1.4.08\         <i>( 22 MB)</i>
C:\opt\jdk-temurin-17.0.19_10\  <i>(302 MB)</i>
C:\opt\VSCode\                  <i>(430 MB)</i>
</pre>

> **:mag_right:** [Git for Windows][git_downloads] provides a BASH emulation used to run [**`git.exe`**][git_cli] from the command line (as well as over 250 Unix commands like [**`awk`**][man1_awk], [**`diff`**][man1_diff], [**`file`**][man1_file], [**`grep`**][man1_grep], [**`more`**][man1_more], [**`mv`**][man1_mv], [**`rmdir`**][man1_rmdir], [**`sed`**][man1_sed] and [**`wc`**][man1_wc]).

## <span id="structure">Directory structure</span> [**&#x25B4;**](#top)

This project is organized as follows:
<pre style="font-size:80%;">
<a href="./bin/">bin\</a>
<a href="./docs/">docs\</a>
<a href="./examples/">examples\</a>{<a href="./examples/README.md">README.md</a>, <a href="./examples/Hello/">Hello</a>, <a href="./examples/JvmParams/">JvmParams</a>, <a href="./examples/TypeNames/">TypeParams</a>, <a href="./examples/Vectors/">Vectors</a>, etc.}
<a href="./rosetta-examples/">rosetta-examples\</a>{<a href="./examples/README.md">README.md</a>, <a href="./rosetta-examples/AryLen/">AryLen</a>, etc.}
README.md
<a href="RESOURCES.md">RESOURCES.md</a>
<a href="setenv.bat">setenv.bat</a>
</pre>

where

- directory [**`bin\`**](bin/) contains .
- directory [**`docs\`**](docs/) contains [Component Pascal][component_pascal] related documents.
- directory [**`examples\`**](examples/) contains [Component Pascal][component_pascal] code examples grabbed from various websites.
- directory [**`rosetta-examples\`**](examples/) contains [Component Pascal][component_pascal] code examples grabbed from the [Rosetta Code][rosetta_code] website.
- file **`README.md`** is the [Markdown][github_markdown] document for this page.
- file [**`RESOURCES.md`**](RESOURCES.md) gathers [Component Pascal][component_pascal] related informations.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.

We also define a virtual drive &ndash; e.g. drive **`K:`** &ndash; in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"][windows_limitation] from Microsoft Support).
> **:mag_right:** We use the Windows external command [**`subst`**][windows_subst] to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst" rel="external">subst</a> K: <a href="https://docs.microsoft.com/en-us/windows/deployment/usmt/usmt-recognized-environment-variables#bkmk-2" rel="external">%USERPROFILE%</a>\workspace-perso\component-pascal-examples</b>
> </pre>

In the next section we give a brief description of the [batch files][windows_batch_file] present in this project.

<!--=======================================================================-->

## <span id="commands">Batch commands</span>

### **`setenv.bat`** <sup id="anchor_04">[4](#footnote_04)</sup>

<pre style="font-size:80%;">
<b>&gt; <a href="./setenv.bat" title="./setenv.bat">setenv</a> -verbose</b>
Select drive G: for which a substitution already exists
Tool versions:
   java 17.0.19, gpcp 1.4.08b3, j2cps 1.4.07,
   make 4.4.1, git 2.55.0, diff 3.12, bash 5.3.15(1)-release
Tool paths:
   C:\opt\jdk-temurin-17.0.19_10\bin\java.exe
   C:\opt\gpcp-NET-1.4.08\bin\gpcp.exe
   C:\opt\msys64\usr\bin\make.exe
   C:\opt\Git\bin\git.exe
   C:\opt\Git\usr\bin\diff.exe
   C:\opt\Git\bin\bash.exe
Environment variables:
   "GIT_HOME=C:\opt\Git"
   "GPCP_HOME=C:\opt\gpcp-NET-1.4.08"
   "JAVA_HOME=C:\opt\jdk-temurin-17.0.19_10"
   "JROOT=C:\opt\gpcp-JVM-1.4.08"
   "MSYS_HOME=C:\opt\msys64"
Path associations:
   H:\: => %USERPROFILE%\workspace-perso\component-pascal-examples
</pre>

<!--=================================================================================-->

## <span id="footnotes">Footnotes</span> [**&#x25B4;**](#top)

<span id="footnote_01">[1]</span> ***Garden Point Component Pascal for JVM*** [↩](#anchor_01)

<dl><dd>
GPCP for JVM version <b>1.4.07</b> supports JRE <a href="https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/tag/jdk8u272-b10"><b>8u272</b></a> <u>or older</u>.

Any newer version of Java VM will throw the exception `java.lang.ClassFormatError`; for instance [**8u282**](https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/tag/jdk8u282-b08) :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/set_1" rel="external" title="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/set_1">set</a> JAVA_HOME=c:\opt\jdk8u282-b08-jre</b>

<b>&gt; <a href="./examples/Hello/build.bat" title="./examples/Hello/build.bat">build</a> -verbose -jvm clean compile</b>
Delete directory "target"
Compile 1 Component Pascal source file to directory "H:\examples\Hello\target\classes"
<span style="color:red;">Exception in thread "main" java.lang.ClassFormatError: Illegal class name "LCP/CPJrts/XHR;" in class file CP/Visitor/Visitor_ImplementedCheck</span>
        at java.lang.ClassLoader.defineClass1(Native Method)
        at java.lang.ClassLoader.defineClass(ClassLoader.java:756)
        at java.security.SecureClassLoader.defineClass(SecureClassLoader.java:142)
        at java.net.URLClassLoader.defineClass(URLClassLoader.java:473)
        at java.net.URLClassLoader.access$100(URLClassLoader.java:74)
        at java.net.URLClassLoader$1.run(URLClassLoader.java:369)
        at java.net.URLClassLoader$1.run(URLClassLoader.java:363)
        at java.security.AccessController.doPrivileged(Native Method)
        at java.net.URLClassLoader.findClass(URLClassLoader.java:362)
        at java.lang.ClassLoader.loadClass(ClassLoader.java:418)
        at sun.misc.Launcher$AppClassLoader.loadClass(Launcher.java:352)
        at java.lang.ClassLoader.loadClass(ClassLoader.java:351)
        at CP.gpcp.gpcp.main(gpcp.cp:40)
Error: Failed to compile 1 Component Pascal source file to directory "H:\examples\Hello\target\classes"
</pre>
Fortunately, version [**1.4.08**][github_gpcp_1408] adds support for **Java 11** and **Java 17**. Andras Pahi has hacked the GPCP compiler to emit local/stack declarations without semicolons. After JDK 1.8.0_275 the JVM follows the spec more rigorously and does not allow semicolons in class names.
</dd></dl>

<span id="footnote_02">[2]</span> ***Downloads*** [↩](#anchor_03)

<dl><dd>
In our case we downloaded the following installation files (see <a href="#proj_deps">section 1</a>):
</dd>
<dd>
<pre style="font-size:80%;">
<a href="https://github.com/Maximus5/ConEmu/releases/tag/v23.07.24" rel="external">ConEmuPack.230724.7z</a>                               <i>(  5 MB)</i>
<a href="https://github.com/pahihu/gpcp-JVM/releases/tag/1.4.08" rel="external">gpcp-JVM-1.4.08.zip</a>                                <i>(  5 MB)</i>
<a href="https://github.com/k-john-gough/gpcp/releases/tag/v1.4.08-beta3" rel="external">gpcp-NET1.4.08b3.zip</a>                               <i>(  4 MB)</i>
<a href="https://adoptium.net/temurin/releases?version=17&os=windows&arch=x64">OpenJDK17U-jdk_x64_windows_hotspot_17.0.19_10.zip</a>  <i>(188 MB)</i>
<a href="https://git-scm.com/download/win" rel="external">PortableGit-2.55.0-64-bit.7z.exe</a>                   <i>( 47 MB)</i>
<a href="https://code.visualstudio.com/Download#" rel="external">VSCode-win32-x64-1.127.0.zip</a>                       <i>(131 MB)</i>
</pre>
</dd></dl>

<span id="footnote_04">[4]</span> **`setenv.bat` *usage*** [↩](#anchor_04)

<dl><dd>
Batch file <a href=./setenv.bat><code><b>setenv.bat</b></code></a> has specific environment variables set that enable us to use command-line developer tools more easily.
</dd>
<dd>It is similar to the setup scripts described on the page <a href="https://learn.microsoft.com/en-us/visualstudio/ide/reference/command-prompt-powershell" rel="external">"Visual Studio Developer Command Prompt and Developer PowerShell"</a> of the <a href="https://learn.microsoft.com/en-us/visualstudio/windows" rel="external">Visual Studio</a> online documentation.
</dd>
<dd>
For instance we can quickly check that the two scripts <code><b>Launch-VsDevShell.ps1</b></code> and <code><b>VsDevCmd.bat</b></code> are indeed available in our Visual Studio 2019 installation :
<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/where" rel="external">where</a> /r "C:\Program Files (x86)\Microsoft Visual Studio" *vsdev*</b>
C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\Launch-VsDevShell.ps1
C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat
C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\vsdevcmd\core\vsdevcmd_end.bat
C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\vsdevcmd\core\vsdevcmd_start.bat
</pre>
</dd>
<dd>
Concretely, in our GitHub projects which depend on Visual Studio (e.g. <a href="https://github.com/michelou/cpp-examples"><code>michelou/cpp-examples</code></a>), <a href="./setenv.bat"><code><b>setenv.bat</b></code></a> does invoke <code><b>VsDevCmd.bat</b></code> (resp. <code><b>vcvarall.bat</b></code> for older Visual Studio versions) to setup the Visual Studio tools on the command prompt. 
</dd></dl>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/July 2026* [**&#9650;**](#top)  <!-- June 2024 -->
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[ada_examples]: https://github.com/michelou/ada-examples#top
[akka_examples]: https://github.com/michelou/akka-examples#top
[cobol_examples]: https://github.com/michelou/cobol-examples#top
[cl_examples]: https://github.com/michelou/cl-examples#top
[conemu_downloads]: https://github.com/Maximus5/ConEmu/releases "https://github.com/Maximus5/ConEmu/releases"
[conemu_relnotes]: https://conemu.github.io/blog/2023/07/24/Build-230724.html
[component_pascal]: https://en.wikipedia.org/wiki/Component_Pascal "https://en.wikipedia.org/wiki/Component_Pascal"
[cpp_examples]: https://github.com/michelou/cpp-examples#top
[dafny_examples]: https://github.com/michelou/dafny-examples#top
[dart_examples]: https://github.com/michelou/dart-examples#top
[deno_examples]: https://github.com/michelou/deno-examples#top
[erlang_examples]: https://github.com/michelou/erlang-examples#top
[flix_examples]: https://github.com/michelou/flix-examples#top
[git_cli]: https://git-scm.com/docs/git "https://git-scm.com/docs/git"
[git_downloads]: https://git-scm.com/download/win "https://git-scm.com/download/win"
[git_relnotes]: https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.55.0.adoc
[github_gpcp_1408]: https://github.com/pahihu/gpcp-JVM/releases/tag/1.4.08 "https://github.com/pahihu/gpcp-JVM/releases/tag/1.4.08"
[github_markdown]: https://github.github.com/gfm/ "https://github.github.com/gfm/"
[golang_examples]: https://github.com/michelou/golang-examples#top
[gpcp_downloads]: https://github.com/k-john-gough/gpcp/releases
[gpcp_java_downloads]: https://github.com/pahihu/gpcp-JVM
[graalvm_examples]: https://github.com/michelou/graalvm-examples#top
[haskell_examples]: https://github.com/michelou/haskell-examples#top
[kafka_examples]: https://github.com/michelou/kafka-examples#top
[kotlin_examples]: https://github.com/michelou/kotlin-examples#top
[linux_opt]: https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html "https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html"
[llvm_examples]: https://github.com/michelou/llvm-examples#top
[m2_examples]: https://github.com/michelou/m2-examples#top
[man1_awk]: https://www.linux.org/docs/man1/awk.html "https://www.linux.org/docs/man1/awk.html"
[man1_diff]: https://www.linux.org/docs/man1/diff.html
[man1_file]: https://www.linux.org/docs/man1/file.html
[man1_grep]: https://www.linux.org/docs/man1/grep.html
[man1_more]: https://www.linux.org/docs/man1/more.html
[man1_mv]: https://www.linux.org/docs/man1/mv.html
[man1_rmdir]: https://www.linux.org/docs/man1/rmdir.html
[man1_sed]: https://www.linux.org/docs/man1/sed.html
[man1_wc]: https://www.linux.org/docs/man1/wc.html "https://www.linux.org/docs/man1/wc.html"
[mysql_examples]: https://github.com/michelou/mysql-examples#top
[nodejs_examples]: https://github.com/michelou/nodejs-examples#top
[powershell_examples]: https://github.com/michelou/powershell-examples#top
[rosetta_code]: https://rosettacode.org/ "https://rosettacode.org/"
[rust_examples]: https://github.com/michelou/rust-examples#top
[scala3_examples]: https://github.com/michelou/scala3-examples#top
[golang_examples]: https://github.com/michelou/sml-examples#top
[sml_examples]: https://github.com/michelou/sml-examples#top
[spark_examples]: https://github.com/michelou/spark-examples#top
[spring_examples]: https://github.com/michelou/spring-examples#top
[jre_8u272]: https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/tag/jdk8u272-b10
[jre_8u272_relnotes]: https://mail.openjdk.org/pipermail/jdk8u-dev/2020-October/012817.html
<!--
### https://mail.openjdk.org/pipermail/jdk-updates-dev/
11.0.3  -> https://mail.openjdk.java.net/pipermail/jdk-updates-dev/2019-April/000951.html
11.0.4  -> https://mail.openjdk.java.net/pipermail/jdk-updates-dev/2019-July/001423.html
11.0.5  -> https://mail.openjdk.java.net/pipermail/jdk-updates-dev/2019-October/002025.html
11.0.6  -> https://mail.openjdk.java.net/pipermail/jdk-updates-dev/2020-January/002374.html
11.0.7  -> https://mail.openjdk.java.net/pipermail/jdk-updates-dev/2020-April/003019.html
11.0.8  -> https://mail.openjdk.java.net/pipermail/jdk-updates-dev/2020-July/003498.html
11.0.9  -> https://mail.openjdk.java.net/pipermail/jdk-updates-dev/2020-October/004007.html
11.0.10 -> https://mail.openjdk.java.net/pipermail/jdk-updates-dev/2021-January/004689.html
11.0.11 -> https://mail.openjdk.java.net/pipermail/jdk-updates-dev/2021-April/005860.html
11.0.12 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2021-July/006954.html
11.0.13 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2021-October/009368.html
11.0.14 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2022-January/011643.html
11.0.15 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2022-April/014104.html
11.0.16 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2022-July/016017.html
11.0.17 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2022-October/018119.html
11.0.18 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2023-January/020111.html
11.0.19 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2023-April/021900.html
11.0.20 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2023-July/024064.html
11.0.21 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2023-October/026351.html
11.0.22 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2024-January/029215.html
11.0.24 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2024-July/035797.html
11.0.25 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2024-October/038512.html
11.0.26 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2025-January/040826.html
11.0.27 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2025-April/043306.html
11.0.28 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2025-July/045612.html
11.0.29 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2025-October/049111.html
11.0.30 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2026-January/051739.html
-->
[temurin_openjdk11]: https://adoptium.net/releases.html?variant=openjdk11&jvmVariant=hotspot
[temurin_openjdk11_bugfixes]: https://www.oracle.com/java/technologies/javase/11-0-19-relnotes.html
[temurin_openjdk11_relnotes]: https://mail.openjdk.org/pipermail/jdk-updates-dev/2025-July/045612.html
<!--
17.0.7  -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2023-April/021899.html
17.0.8  -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2023-July/024063.html
17.0.9  -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2023-October/026352.html
17.0.10 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2024-January/029089.html
17.0.11 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2024-April/032197.html
17.0.12 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2024-July/035798.html
17.0.13 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2024-October/038867.html
17.0.14 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2025-January/040827.html
17.0.15 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2025-April/043307.html
17.0.16 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2025-July/045614.html
17.0.17 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2025-October/049112.html
17.0.18 -> https://mail.openjdk.org/pipermail/jdk-updates-dev/2026-January/051740.html
17.0.19 -> https://mail.openjdk.org/archives/list/jdk-updates-dev@openjdk.org/thread/NPI56ASV64QS2A23ODDPZX4D2BATNZKL/
-->
[temurin_openjdk17]: https://adoptium.net/temurin/releases?version=17&os=windows&arch=x64
[temurin_openjdk17_bugfixes]: https://www.oracle.com/java/technologies/javase/17-0-2-bugfixes.html
[temurin_openjdk17_relnotes]: https://mail.openjdk.org/archives/list/jdk-updates-dev@openjdk.org/thread/NPI56ASV64QS2A23ODDPZX4D2BATNZKL/ "https://mail.openjdk.org/archives/list/jdk-updates-dev@openjdk.org/thread/NPI56ASV64QS2A23ODDPZX4D2BATNZKL/"
[trufflesqueak_examples]: https://github.com/michelou/trufflesqueak-examples#top
[unix_opt]: https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html "https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html"
[vscode_downloads]: https://code.visualstudio.com/Download "https://code.visualstudio.com/Download"
[vscode_relnotes]: https://code.visualstudio.com/updates
[windows_batch_file]: https://en.wikibooks.org/wiki/Windows_Batch_Scripting "https://en.wikibooks.org/wiki/Windows_Batch_Scripting"
[windows_installer]: https://docs.microsoft.com/en-us/windows/win32/msi/windows-installer-portal
[windows_limitation]: https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation
[windows_subst]: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst "https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst"
[wix_examples]: https://github.com/michelou/wix-examples#top
[zig_examples]: https://github.com/michelou/zig-examples#top
[zip_archive]: https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/ "https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/"
