---
layout: post
title: IntelliJ Scala Plugin
---

# {{ page.title }}

---------------------------------------

The [IntelliJ Scala plugin v0.13.286](http://blog.jetbrains.com/scala/) does a few things which were previously manual steps. This means that following the old documentation can lead to a few unhelpful error messages, when all you want is syntax highligh, autocomplete and the occassional REPL support.

Assuming you start with a Gradle project using the Scala plugin and clean IntelliJ IDEA 12.1.4 install, the steps to add Scala support are:

1. ```File``` -> ```Import Project```. Select folder with parent build.gradle.
2. Import project from external model
<p align="center">
  <a class="fancybox" href="/images/2013-07/intellij-import.png"><img src="/images/2013-07/intellij-import.png" align="center" width="80%"/></a>
</p>
3. Select whether to use the gradle wrapper or a local installation, then finish import with default settings.
4. Right-click parent folder in project structure, select ```Add Framework Support...```.
<p align="center">
  <a class="fancybox" href="/images/2013-07/add-framework.png"><img src="/images/2013-07/add-framework.png" align="center" width="80%"/></a>
</p>
5. Depending on your Scala installation, some expected folders may be missing.
<p align="center">
  <a class="fancybox" href="/images/2013-07/add-scala-framework.png"><img src="/images/2013-07/add-scala-framework.png" align="center" width="80%"/></a>
</p>

Complete. If you had some existing global libraries, or tried following [some](http://devnet.jetbrains.com/thread/290032) of [the older](http://stackoverflow.com/questions/9563342/how-to-run-scala-code-on-intellij-idea-11) plugin [documentation](http://confluence.jetbrains.com/display/SCA/Getting+Started+with+IntelliJ+IDEA+Scala+Plugin), then you will likely find errors such as

```Exception in thread "main" java.lang.NoClassDefFoundError: scala/reflect/internal/Trees```

or

```Please, adjust compiler library in Scala facet: no scala-compiler*.jar found.```


