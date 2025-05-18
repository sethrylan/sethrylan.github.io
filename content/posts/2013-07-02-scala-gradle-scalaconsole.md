---
date: "2013-07-02T00:00:00Z"
title: ScalaConsole with Gradle
---

The usual build tool for Scala is [SBT](http://www.scala-sbt.org/), but I've been trying to stay consistent with Gradle builds. Of course, the most lacking feature is a decent REPL for manipulating the main/test classes, and there appear to be two possible solutions to this problem.

--------------------------------------------------

### ScalaConsole in the Gradle scala plugin ###

The [ScalaBasePlugin](http://code-review.gradle.org/browse/Gradle/subprojects/scala/src/main/groovy/org/gradle/api/plugins/scala/ScalaBasePlugin.groovy?hb=true) for Gradle defines the `scalaConsole` and `scalaTestConsole` tasks, which aren't widely used (or documented) due to [known issues](http://forums.gradle.org/gradle/topics/scalaconsole). In particular, you have to make a few changes before the feature is usable. In order the fix the 

    :scalaConsole
    Error: Could not find or load main class scala.tools.nsc.MainGenericRunner

error, the scala-compiler must be added as a runtime dependency. In addition, the task dependencies and classpaths must be changed, as in the gist below.

<script src="https://gist.github.com/sethrylan/5910482.js"> </script>

However, you'll still experience the problem of overlaying the Gradle build output on top of the REPL, unless you use the -q/--quiet switch. Many thanks to [Tim Vergenz](https://github.com/vergenzt) for pointing this out.

    $ gradle scalaConsole -q
    Welcome to Scala version 2.9.2 (Java HotSpot(TM) 64-Bit Server VM, Java 1.7.0_15).
    Type in expressions to have them evaluated.
    Type :help for more information.
    
    scala> var list = List("Lisp-ity List")
    list: List[String] = List(Lisp-ity List)

--------------------------------------------------

### Centaur's ScalaConsole ###

No longer actively developed, [ScalaConsole](https://bitbucket.org/centaur/scalaconsole/wiki/Home) is a Swing application that opens a REPL in a new window. Still a few changes necessary to add the working directories to the classpath:

<script src="https://gist.github.com/sethrylan/5910509.js">  </script>

