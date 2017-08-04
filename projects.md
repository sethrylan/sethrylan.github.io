---
layout: default
title: Projects
---


<ul class="projects">
{% for project in site.projects %}
    <p>
	<a href="{{ project.url }}">
        <h2 class="post-title">{{ project.title }}</h2>
    </a>
    <p class="post-meta"><small>{{project.text}}</small></p>
    </p>
{% endfor %}
</ul>


{% for project in site.projects %}
<div class="post-preview">
</div>
{% endfor %}
