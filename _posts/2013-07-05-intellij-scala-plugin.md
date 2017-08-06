---
layout: post
title: IntelliJ Scala Plugin
sitemap:
  priority: 0.7
  changefreq: weekly
---

The [IntelliJ Scala plugin v0.13.286](http://blog.jetbrains.com/scala/) does a few things which were previously manual steps. This means that following the old documentation can lead to a few unhelpful error messages, when all you want is syntax highlighting, autocomplete and the occassional REPL support.

Assuming you start with a Gradle project using the Scala plugin and clean IntelliJ IDEA 12.1.4 install, the steps to add Scala support are:

1. ```File``` -> ```Import Project```. Select folder with parent build.gradle.
2. Import project from external model
  <br>
  <a class="fancybox center" href="{{site.url}}/images/2013-07/intellij-import.png"><img src="{{site.url}}/images/2013-07/intellij-import.png" width="80%"/></a>
3. Select whether to use the gradle wrapper or a local installation, then finish import with default settings.
4. Right-click parent folder in project structure, select ```Add Framework Support...```.
  <br>
  <a class="fancybox center" href="{{site.url}}/images/2013-07/add-framework.png"><img src="{{site.url}}/images/2013-07/add-framework.png" width="80%"/></a>
5. Depending on your Scala installation, some expected folders may be missing.
  <br>
  <a class="fancybox center" href="{{site.url}}/images/2013-07/add-scala-framework.png">
  <img src="{{site.url}}/images/2013-07/add-scala-framework.png" width="80%"/></a>

And finished. If you had existing scala-compiler/scala-library global libraries, or tried following [some](http://devnet.jetbrains.com/thread/290032) of [the older](http://stackoverflow.com/questions/9563342/how-to-run-scala-code-on-intellij-idea-11) plugin [documentation](http://confluence.jetbrains.com/display/SCA/Getting+Started+with+IntelliJ+IDEA+Scala+Plugin), then you will likely find errors such as

```Exception in thread "main" java.lang.NoClassDefFoundError: scala/reflect/internal/Trees```

or

```Please, adjust compiler library in Scala facet: no scala-compiler*.jar found.```

This is just IntelliJ's way of saying the the new way is much easier.
