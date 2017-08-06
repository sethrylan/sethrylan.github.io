---
layout: default
title: Projects
---


<ul class="projects">
{% for project in site.projects %}
	<a href="{{ project.url }}">
        <h3 class="post-title">{{ project.title }}</h3>
	    <p class="post-meta"><small>{{project.text}}</small></p>
    </a>
{% endfor %}
</ul>


{% for project in site.projects %}
<div class="post-preview">
</div>
{% endfor %}
