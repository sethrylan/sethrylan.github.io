---
layout: post
title: FindBugs for Android
sitemap:
  priority: 0.7
  changefreq: weekly
---

The very useful code quality plugins for Gradle ([Checksytle](http://www.gradle.org/docs/current/userguide/checkstyle_plugin.html), [FindBugs](http://www.gradle.org/docs/current/userguide/findbugs_plugin.html), [PMD](http://www.gradle.org/docs/current/userguide/pmd_plugin.html), [etc](http://www.gradle.org/docs/current/userguide/userguide.html)) expect to have the Java plugin applied, which is incompatible with the new [Android gradle build system](http://tools.android.com/tech-docs/new-build-system/).
Some developers, like Netflix, resolve this problem by [omitting the plugins](https://github.com/Netflix/denominator/blob/8ca41a1434276c9927c406f436aa95928782275b/gradle/check.gradle) from their otherwise [standardized build](https://github.com/Netflix/gradle-template) process. [Others](http://flow.apphance.com/) have tried to create a build system inside another build system, at which point you can have whatever plugins you want, and most use a [wrapper](https://github.com/grails/grails-core/blob/master/gradle/findbugs.gradle) around the Ant tasks which predate Gradle. Behind the scenes, this is what the Gradle plugins do anyway.

Manually adding sourcesets will allow us to add the plugins, but FindBugs depends on the tasks configured as part of the Java plugin. Obviously, the task dependencies are not going to work, unless you want to configure a Java build parallel to an Android build.

    Verification tasks
    check - Runs all checks.
        classes - Assembles binary 'main'.
        compileJava - Compiles source set 'main:java'.
        findbugsMain - Run FindBugs analysis for main classes
        processResources - Processes source set 'main:resources'.
		
Alternatively, one can write a [Task](http://www.gradle.org/docs/current/javadoc/org/gradle/api/Task.html) class which understands Android SourceSets and wraps the Ant task.

This is pretty straightforward for Checkstyle:

<script src="https://gist.github.com/sethrylan/6002657.js?file=checkstyle.gradle" type="text/javascript"> </script>

and PMD:
		
<script src="https://gist.github.com/sethrylan/6002657.js?file=pmd.gradle" type="text/javascript"> </script>

These are included like any other tasks or plugin definition:

    ...
	buildscript {
        dependencies {
            classpath "com.android.tools.build:gradle:$versions.android"
        }
    }

    apply plugin: 'android'
    apply from : "$rootDir/gradle/checkstyle.gradle"
    ...
	
FindBugs is a little more difficult, since it [expects](http://findbugs.sourceforge.net/manual/anttask.html#d0e1192) to have the library JAR files locally installed or included in the source distribution. This isn't very Gradle-y, but since a Gradle [Configuration](http://www.gradle.org/docs/current/javadoc/org/gradle/api/artifacts/Configuration.html) is also FileCollection, we can <a href="http://www.gradle.org/docs/current/javadoc/org/gradle/api/file/FileCollection.html#addToAntBuilder(java.lang.Object, java.lang.String)">add</a> the files from the Gradle cache as an Ant node.

<script src="https://gist.github.com/sethrylan/6002657.js?file=findbugs.gradle" type="text/javascript"> </script>

See the full examples on [GitHub](https://github.com/sethrylan/rosette).
