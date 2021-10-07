---
layout: post
title: Grad School (the good parts)
---

##### On Abstractions
> Systems designers are abstraction merchants.[^abstractions]

> Nothing is so difficult it cannot be solved by another level of indirection.[^wheeler]

##### On Files
The life of an average file is tedious[^notafile] and brief[^tediousandbrief]. Sequential access is rarely sequential with multiple threads.

##### On Queueing

Little's Law has bizarre and counter-intuitive conclusions. Suppose bank customers take an average (exponential distribution) of 10 minutes to serve and they arrive at the rate of 5.8 per hour. With 1 teller, the average wait time is over 5 hours. With 2 tellers, it is <b>3 minutes</b>.

Anything can be fixed with the words "assume i.i.d."

$P_k$ (number in system at time k), $\bar{N}$ (mean number in system), and $\bar{T}$ (mean time in system) are independent of service disciplines, but the variance and distribution of T are not. I.e., $T_{FCFS} = T_{LCFS}$, but $var_{T,FCFS} \neq var_{T,LCFS}$ since $var = E[T^2] - E^2[T]$.

Poisson only works if your events are truly independent.[^poisson]

<!-- <p class="center">
  <a class="fancybox" href="/images/2017-08/disc-cont.svg"><img src="/images/2017-08/disc-cont.svg" width="40%"/></a>
</p>
 -->
<!-- ##### On Sorting

|                                      | $split(1,n-1), \Theta(n^2)$  | $split(n/2,n/2), \Theta(n\cdot lgn)$  |
| ------------------------------------:|:----------------------------:| :-------------------------------:|
| recurse on input: work on way up     | insertion sort               | merge sort  |
| recurse on output: work on way down  | selection sort               |   Quicksort (kind of) |
 -->

##### On Optimization
> Put broadly, the object of study in mathematics is truth; the object of study in computer science is complexity. [I]t's not enough for a problem to have a solution, if that problem is intractable.[^toliveby]

Everyone is afraid to touch [database] optimizers, because no one knows how they work.

Optimization works in cycles:
1. Exploit [assumptions](https://dl.acm.org/citation.cfm?id=313859) and [amortization](https://www.youtube.com/watch?v=3MpzavN3Mco).
1. Divide and conquer until re-computation takes too long.
1. Parallelize until [Amdahl's](https://en.wikipedia.org/wiki/Amdahl%27s_law).
1. Dynamic programming (parenthesization , memoization) until state space complexity takes you back to #1.

##### On Distributed Systems
In [distributed systems](https://github.com/aphyr/distsys-class), it is impossible to tell whether a system is dead or arbitrarily delayed.

##### On Data
Curse of Multidimensionality: as the number of attributes/dimensions in a dataset increases, the average distance becomes larger, making it more difficult to detect outliers[^nimbus] and leading to overfitted models.[^multidimensionality]

The more you look, the more you overfit[^bonferroni].

Tricks in Data Analysis:
1. Add more dimensions: Non-linear SVM
1. Take away dimensions: Random forest, eigenvectors

Data-ink ratio = $\frac{data\ ink}{total\ ink}$

##### On Tools
Typing skill and comprehension are independent. Concurrent tasking does not affect typing much.[^salthouse]

$$
\require{AMScd}
\begin{CD}
CMF @>{smooth}>> CDF;\\
@AA{\sum}A @A{\int_0^x}AA \\
PMF @<{bin}<< PDF;
\end{CD}
$$
[^distributions]

> A long list is no list. [^bobbell]

> When in doubt, draw it out. [^drawitout]

##### On Process and Organization
After accounting for size, other code complexity metrics become noise.[^noise]

In an sufficiently regulated engineering process, the non-work deliverables themselves take on technical rigor with little connection to the product.

"The second is that people tend to inconsistency. The prediction is that methodologies requiring disciplined consistency are fragile in practice... The fourth is that people like to be good citizens, are good at looking around and taking initiative. These combine to form that common success factor, «a few good people stepped in at key moments.»"[^cockburn]

##### On Human Reliability
Human reliability is a log normal distribution.[^nureg]

> The only risks in life are the people and things you depend on.[^bobbell] [^willoughby]

##### On Protocols
Even if a protocol seems great on paper, it may not be used for lots of reasons.[^csma]

##### On Psychophysics
> Sound exists in time and over space, vision exists in space and over time. [^mountfordgaver]

---

[^abstractions]: [On the Design and Evaluation of Abstractions](http://www.cse.nd.edu/Reports/1992/tr-92-7.ps)
[^wheeler]: An [indirect quote](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/turinglecture.pdf) of [David Wheeler](https://en.wikipedia.org/wiki/David_Wheeler_(British_computer_scientist)), later institutionalized as the fundamental theoreum of software engineering ([FTSE](https://en.wikipedia.org/wiki/Fundamental_theorem_of_software_engineering)) and [RFC1925](https://tools.ietf.org/html/rfc1925). E.g., [indirect block addressing](https://lwn.net/Articles/187321/).
[^mountfordgaver]: Mountford, S.J., & Gaver, W.W. (1990). Talking and listening to computers. In B. Laurel (Ed.), [The art of human-computer interface design](http://amzn.to/2vFevAz) (p. 322). Reading, Massachusetts: Addison-Wesley.
[^willoughby]: Willoughby templates, institutionalized as [DoD 4245.7-M](handle.dtic.mil/100.2/ADA303209)
[^bobbell]: Robert (Bob) Bell, personal conversation
[^nureg]: [NUREG/CR-1278](https://www.nrc.gov/docs/ML0712/ML071210299.pdf)
[^csma]: CSMA is more efficient at lower packet sizes, and the 802.11 setting for RTS/CTS/Thres[hold] will revert to CSMA below a a threshold size. But computing the optimum size is hard, and usually RTS/CTS is disabled.
[^tediousandbrief]: From ["Measurements of a Distributed File System"](dl.acm.org/citation.cfm?id=121164); most are small (~50% <1KB) and short lived (74% open for less than .1 second, 50% live ≤1s, ~97% live less than a day).
[^notafile]: From ["A File Is Not A File"](dl.acm.org/citation.cfm?id=2043564); it is actually many many files.
[^poisson]: From ["Wide Area Traffic: The Failure of Poisson Modeling"](www.icir.org/vern/papers/poisson.TON.pdf); TCP traffic, or IP over AAL5 are rarely poisson.
[^toliveby]: [Algorithms to Live By](http://amzn.to/2x5zryq)
[^multidimensionality]: "87% of the population in the United States had reported characteristics that likely made them unique based only on {5-digit ZIP, gender, date of birth}" [Sweeney 2000](https://dataprivacylab.org/projects/identifiability/paper1.pdf).
[^salthouse]: [Salthouse 1986](http://faculty.virginia.edu/cogage/publications2/Pre%201995/Perceptual%20Cognitive%20and%20Motoric%20Aspects%20of%20Transcription%20Typing.pdf)
[^drawitout]: [M&R](http://amzn.to/2wRnqgF), chapter 6.
[^cockburn]: Alistair Cockburn, ["Characterizing People as Non-Linear, First-Order Components in Software Development"](http://alistair.cockburn.us/Characterizing+people+as+non-linear,+first-order+components+in+software+development)
[^noise]: Khaled El Emam, Saida Benlarbi, Nishith Goel, and Shesh N. Rai: "The Confounding Effect of Class Size on the Validity of Object-Oriented Metrics". IEEE Transasctions on Software Engineering, 27(7), July 2001.
[^nimbus]: On anomaly detection: The Nimbus 7 satellite [had anomaly detection software](http://www.nature.com/nature/journal/v322/n6082/abs/322808a0.html) which was dropping valid measurement of ozone depletion over Antarctica.
[^bonferroni]: Bonferroni’s Principle: ["Who searches a lot, finds a lot."](http://rationalwiki.org/wiki/Bonferroni%27s_principle)
[^distributions]: [Think Stats](http://amzn.to/2wRBFC0), chapter 6.

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {
      inlineMath: [ ['$','$'], ["\\(","\\)"] ],
      processEscapes: true
    }
  });
</script>

<script type="text/javascript"
    src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>