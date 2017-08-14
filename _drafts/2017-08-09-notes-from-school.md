---
layout: post
title: Notes from (7 years of graduate) school
---


"AI has by now succeeded in doing essentially everything that requires 'thinking' but has failed to do most of what people and animals do 'without thinking.'"   - Donald Knuth

"When in doubt, draw it out."
	Chapter 6 in M&R (https://www.amazon.com/Applied-Statistics-Probability-Engineers-Montgomery/dp/0470053046/)

In an sufficiently regulated engineering process, the non-work deliverables themselves take on technical rigor with little connection to the product.

On Abstractions
"[S]ystems designers are abstraction merchants." We create and sell abstractions.
  - On the Design and Evaluation of Abstractions
Pearl #5: Nothing is so difficult it cannot be solved by another level of indirection. (For example, indirect block addressing https://lwn.net/Articles/187321/)

On Risk
"The source of all risk is flawed process."
  - Willard Willoughby
The only risks in life are the people/things you depend on.
  - Robert (Bob) Bell


On Human Condition
Human reliability is a log normal distribution (NUREG/CR- 1278 https://www.nrc.gov/docs/ML0712/ML071210299.pdf)
Déformation professionnelle is the hubris of specialists.


On Protocols
Even if a protocol seems great on paper, it may not be used for lots of reasons. E.g., CSMA is more efficient at lower packet sizes, and the 802.11 setting for RTS/CTS/Thres[hold] will revert to CSMA below a a threshold size. But computing the optimum size is hard, and usually RTS/CTS is disabled.


On Distributed Systems
Amdahl’s Law
Lamport Clock
In distributed systems, it is impossible to tell whether a system is dead or arbitrarily delayed


On File Systems
Tedious and Brief. Most files are small (~50% are <1KB) and short lived (74% were open less than .1 second, about 50% live ≤1s, ~97% live less than a day)
  - "Measurements of a Distributed File System" (1991 UC Berkley) 
"A File is Not a File" (Tyler Harter, et al.) It is actually many many files. Sequential access may not be sequential with multiple threads


On Queueing Systems
<div>
\[
P_k (number in system at time k), \overbar{N} (mean number in system), and \overbar{T} (mean time in system) are independent of service disciplines, but the variance and distribution of T are not. \\
e.g., T_{FCFS} = T_{LCFS} \\
but var_{T,FCFS} != var_{T,LCFS} since var = E[T^2] - E^2[T]
\]
</div>

Poisson is a good model only if your events are truly independent (TCP traffic, or IP over AAL5 are not; cf. "Wide Area Traffic: The Failure of Poisson Modeling")
Nothing cannot be fixed with the words "Assume IID"

<img 
    src="images/disc-cont.svg" 
    height="87px"
    width="100px" />


On Sorting
| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |


Another day on the journey of NP-Completeness
Divide and Conquer.
When that fails to give you the time bounds you want (because of re-computation), Dynamic Programming (Parenthesiz-ation , Memo-ization) 

On Data
Curse of Multidimensionality: as the number of attributes/dimensions in a dataset increases, the average distance becomes larger, making it more difficult to detect outliers and leading to overfitted models. See also https://dataprivacylab.org/projects/identifiability/paper1.pdf
Anomaly Detection: The Nimbus 7 satellite had anomaly detection software which was dropping valid measurement of ozone depletion over Antarctica
Data-ink ratio = (data ink)/(total ink)
Bonferroni’s Principle: the more you look, the more you overfit. "Who searches a lot, finds a lot."
Tricks in Data Analysis:
Add more dimensions: non-linear SVM
Take away dimensions: Random forest, eigenvectors (see CSC791)

On Databases
Everyone is afraid to touch optimizers, because no one knows how they work.

Advanced Data Structures
The richest frontiers for optimizations are now amoritization (e.g., Splay trees) and exploiting realistic assumptiosn (Timsort).

On Tools
Typing skill and comprehension are independent.
Concurrent tasking does not affect typing too much.
 [Salthouse 1986]
"A long list is no list"
  - Robert (Bob) Bell

On Psychophysics
Sound exists in time and over space; vision exists in space and over time.



"• When all else fails, standardize "

Hidden Factory is a condition caused by attempting to correct work in progress with a parallel manufacturing process

- ‘…only 67% of originally defined features show up in the finished product, of those 45% are never used’ (Standish)


<script type="text/javascript"
    src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>